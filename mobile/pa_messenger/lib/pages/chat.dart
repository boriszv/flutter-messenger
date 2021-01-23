import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pa_messenger/models/conversation.dart';
import 'package:pa_messenger/models/message.dart';

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

  static const PAGE_SIZE = 10;

  final _controller = TextEditingController();

  Conversation conversation;
  List<Message> firstPageOfMessages = [];
  List<Message> otherPagesOfMessages = [];

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
        firstPageOfMessages = Message.fromMapList(result.docs.map((x) => x.data()).toList());
        if (firstPageOfMessages.length != 0) {
          lastDocument = result.docs.last;
        }
        if (firstPageOfMessages.length != PAGE_SIZE) {
          loadedAll = true;
        }
        showLoading = false;
      });
    });
  }

  Future<void> _fetchMoreMessages() async {
    if (args.chatType != ChatType.Default) return;

    setState(() { isLoadingMore = true; });

    final result = await _buildQuery(startAfter: lastDocument).get();
    final newMessages = Message.fromMapList(result.docs.map((x) => x.data()).toList());

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
        'userId': FirebaseAuth.instance.currentUser.uid,
        'createTime': Timestamp.now() // this is sent only so it's recieved quick by clients - this field is set to a correct time by a cloud function
      });
  }

  Future<void> _createConversation() async {
    final reference = await FirebaseFirestore.instance.collection('conversations').add({
      'userIds': [FirebaseAuth.instance.currentUser.uid, args.userToSendMessageToId],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Messages'),
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
                      if (index != messages.length) return _MessageItem(messages[index]);
                      if (args != null && args.chatType != ChatType.Default || loadedAll) return Container();

                      return Center(child: CircularProgressIndicator());
                    },
                    itemCount: loadedAll ? messages.length : messages.length + 1,
                  ),
                ),

                _ChatTextField(_controller, onSubmitted: () { _sendClicked(); }),
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

  final Message message;

  _MessageItem(this.message);

  @override
  Widget build(BuildContext context) {
    final margin = MediaQuery.of(context).size.width * 0.3;
    
    return Container(
      margin: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: FirebaseAuth.instance.currentUser.uid == message.userId ? margin : 10,
        right: FirebaseAuth.instance.currentUser.uid != message.userId ? margin : 10,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey, width: 1)
      ),
      child: Text(message.messageText),
    );
  }
}

class _ChatTextField extends StatelessWidget {

  final TextEditingController _controller;
  final Function onSubmitted;

  _ChatTextField(this._controller, {this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          // IconButton(
          //   onPressed: () {
          //     // _selectImageHandler(vm);
          //   },
          //   icon: Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor,),
          // ),
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
