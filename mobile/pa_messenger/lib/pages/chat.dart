import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pa_messenger/models/conversation.dart';
import 'package:pa_messenger/models/conversationUser.dart';
import 'package:pa_messenger/models/message.dart';
import 'package:pa_messenger/pages/fullscreen_image.dart';
import 'package:pa_messenger/pages/take_picture.dart';
import 'package:pa_messenger/services/file_uploading_service.dart';
import 'package:pa_messenger/services/ifile_uploading_service.dart';
import 'package:pa_messenger/services/iimage_compressing_service.dart';
import 'package:pa_messenger/services/iimage_cropping_service.dart';
import 'package:pa_messenger/services/image_compressing_service.dart';
import 'package:pa_messenger/services/image_cropping_service.dart';
import 'package:pa_messenger/utils/time_utils.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:path/path.dart' as p;

enum ChatType {
  Default,
  CreateConversation,
}

class ChatArgs {
  Conversation conversation;

  ChatType chatType;
  String userToSendMessageToId;

  ChatArgs({this.conversation, this.chatType = ChatType.Default, this.userToSendMessageToId});
}

class Chat extends StatefulWidget {

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  static final IFileUploadingService _fileUploadingService = FileUploadingService();
  static final IImageCroppingService _imageCroppingService = ImageCroppingService();
  static final IImageCompressingService _imageCompressingService = ImageCompressingService();

  static const PAGE_SIZE = 10;

  final currentUserId = FirebaseAuth.instance.currentUser.uid;

  final _controller = TextEditingController();

  Conversation conversation;
  ConversationUser otherUser;

  List<Message> firstPageOfMessages = [];
  List<Message> otherPagesOfMessages = [];

  final ImagePicker _picker = ImagePicker();

  List<Message> get messages => [...firstPageOfMessages, ...otherPagesOfMessages];

  bool showLoading = false;
  bool isLoadingMore = false;
  bool loadedAll = false;

  QueryDocumentSnapshot lastDocument;

  ChatArgs args;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {

      setState(() {
        args = ModalRoute.of(context).settings.arguments as ChatArgs;
        conversation = args.conversation;
        otherUser = conversation.users.firstWhere((x) => x.userId != FirebaseAuth.instance.currentUser.uid, orElse: () => null);
      });
      if (args.chatType == ChatType.Default) _fetchMessages();
    });
  }

  Query _buildQuery({QueryDocumentSnapshot startAfter}) {
    var query = FirebaseFirestore.instance
        .collection('conversations/${conversation.id}/messages')
        .orderBy('createTime', descending: true);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(PAGE_SIZE);
  }

  StreamSubscription<QuerySnapshot> subscription;
  Future<void> _fetchMessages() async {
    setState(() { showLoading = true; });

    subscription = _buildQuery().snapshots().listen((result) {
      setState(() {
        firstPageOfMessages = Message.fromMapList(result.docs.map((x) => x.data()..addAll({'id': x.id})).toList());
        if (firstPageOfMessages.length != 0) {
          lastDocument = result.docs.last;
        }
        if (firstPageOfMessages.length != PAGE_SIZE) {
          loadedAll = true;
        }
        showLoading = false;
      });

      _markLatestMessageAsSeen();
    });
  }

  Future<void> _fetchMoreMessages() async {
    if (args.chatType != ChatType.Default) return;

    setState(() { isLoadingMore = true; });

    final result = await _buildQuery(startAfter: lastDocument).get();
    final newMessages = Message.fromMapList(result.docs.map((x) => x.data()..addAll({'id': x.id})).toList());

    setState(() {
      if (newMessages.length != 0) {
        otherPagesOfMessages.addAll(newMessages);
        lastDocument = result.docs.last;

      } else {
        loadedAll = true;
      }
      isLoadingMore = false;
    });
  }

  Future<void> _sendClicked() async {
    switch (args.chatType) {
      case ChatType.Default:
        await _sendMessage(args.conversation.id);
        break;
      case ChatType.CreateConversation:
        await _createConversation();
        break;
    }
  }

  Future<void> _sendMessage(String conversationId) async {
    final messageText = _controller.text; 
    _controller.clear();

    await FirebaseFirestore.instance
      .collection('conversations/$conversationId/messages')
      .add({
        'messageText': messageText,
        'userId': currentUserId,
        'createTime': Timestamp.now() // this is sent only so it's recieved quick by clients - this field is set to a correct time by a cloud function
      });
  }

  Future<void> _createConversation() async {
    final reference = await FirebaseFirestore.instance.collection('conversations').add({
      'userIds': [currentUserId, args.userToSendMessageToId],
    });

    await _sendMessage(reference.id);

    final map = (await reference.get()).data();
    final conversation = Conversation.fromMap(map);
    conversation.id = reference.id;

    setState(() {
      args = ChatArgs(
        conversation: conversation,
        chatType: ChatType.Default,
      );
      this.conversation = conversation;
    });
    await _fetchMessages();
  }

  Future<void> _markLatestMessageAsSeen() async {
    await FirebaseFirestore.instance.doc('conversations/${conversation.id}').update({
      'seen.$currentUserId': messages.first.id
    });
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(context: context, builder: (context) => BottomSheet(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.camera), title: Text('Camera'), onTap: () {
            Navigator.of(context).pop();
            _selectPhotoWithCamera();
          }),
          ListTile(leading: Icon(Icons.filter), title: Text('Pick a file'), onTap: () {
            Navigator.of(context).pop();
            _selectPhotoWithGallery();
          }),
        ],
      ),
      onClosing: () {},
    ));
  }

  Future _selectPhotoWithCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    final path = await Navigator.of(context).pushNamed('/take-picture', arguments: TakePictureArgs(cropImage: true, cropRatioX: 4, cropRatioY: 3)) as String;
    if (path == null || path.trim().isEmpty) {
      return;
    }

    await _uploadFile(path);
  }

  Future _selectPhotoWithGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) {
      return;
    }

    var file = await _imageCroppingService.cropImage(pickedFile.path, 4, 3);
    if (file == null) {
      return;
    }

    file = await _imageCompressingService.compressImagePath(file.path, 35);

    await _uploadFile(file.path);
  }

  Future _uploadFile(String path) async {
    final pathToUploadTo = '/users/$currentUserId/${p.basename(path)}';
    final fileUrl = await _fileUploadingService.uploadFileAndGetUrl(path, pathToUploadTo: pathToUploadTo);

    final messageToCreate = {
      'imageUrl': fileUrl,
      'userId': currentUserId,
      'createTime': Timestamp.now() // this is sent only so it's recieved quick by clients - this field is set to a correct time by a cloud function
    };

    if (_controller.text != null && _controller.text.trim().isNotEmpty) {
      messageToCreate['messageText'] = _controller.text;
      _controller.clear();
    }

    try {
      await FirebaseFirestore.instance.collection('conversations/${conversation.id}/messages').add(messageToCreate);

    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Message wasn't sent")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            if (otherUser.imageUrl != null && otherUser.imageUrl.trim().isNotEmpty) ...[
              AppRoundImage.url(otherUser.imageUrl, height: 30, width: 30),
              SizedBox(width: 15)
            ],

            Text(otherUser.userName)
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (showLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !isLoadingMore && !loadedAll) {
                _fetchMoreMessages();
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemBuilder: (context, index) {
                      final previousMessage = index > 0 ? messages[index - 1] : null;

                      if (index != messages.length) return _MessageItem(messages[index], previousMessage, conversation);
                      if (args != null && args.chatType != ChatType.Default || loadedAll) return Container();

                      return Center(child: CircularProgressIndicator());
                    },
                    itemCount: loadedAll ? messages.length : messages.length + 1,
                  ),
                ),

                _ChatTextField(_controller, onSubmitted: () { _sendClicked(); }, onImageClick: () { _selectPhoto(); },),
              ],
            ),
          );
        },
      ),
    );
  }

  @override 
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}

class _MessageItem extends StatelessWidget {

  final Conversation conversation;
  final Message message;
  final Message previousMessage;

  _MessageItem(this.message, this.previousMessage, this.conversation);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser.uid;
    final isCurrentUserSender = currentUserId  == message.userId;
    final otherUser = conversation.users.firstWhere((x) => x.userId != currentUserId);

    final showTimestamp = previousMessage == null || previousMessage.userId != message.userId;

    return Container(
      margin: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: 10,
        right: 10,
      ),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: isCurrentUserSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _ChatBubble(message, showTimestamp: showTimestamp, isCurrentUserSender: isCurrentUserSender),

          if (message.id == conversation.seen[otherUser.userId]) ...[
            Container(height: 5),
            Text('Seen', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
          ]
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {

  final Message message;
  final bool showTimestamp;
  final bool isCurrentUserSender;

  _ChatBubble(this.message, {this.showTimestamp, this.isCurrentUserSender});

  _openFullscreenImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullscreenImage.url(message.imageUrl)));
  }

  @override
  Widget build(BuildContext context) {
    final showImage = message.imageUrl != null && message.imageUrl.trim().isNotEmpty;
    final showText = message.messageText != null && message.messageText.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: isCurrentUserSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7
          ),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey, width: 1)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showImage)
                InkWell(child: Image.network(message.imageUrl), onTap: () => _openFullscreenImage(context)),

              if (showImage && showText)
                Container(height: 5),

              if (showText)
                Text(message.messageText),
            ],
          ),
        ),
        if (showTimestamp) ...[
          Container(height: 5),
          Text(calculateTimestamp(message.createTime.toDate()), style: TextStyle(color: Colors.grey.shade600),),
        ]
      ],
    );
  }
}

class _ChatTextField extends StatelessWidget {

  final TextEditingController _controller;
  final Function onSubmitted;
  final Function onImageClick;

  _ChatTextField(this._controller, {this.onSubmitted, this.onImageClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              onImageClick();
            },
            icon: Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor,),
          ),
          Container(width: 4),
          Flexible(
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Send message',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_controller.text == null || _controller.text.trim().isEmpty) return;
              onSubmitted();
            },
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor,),
          )
        ],
      ),
    );
  }
}
