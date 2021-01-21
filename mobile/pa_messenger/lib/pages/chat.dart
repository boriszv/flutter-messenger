import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pa_messenger/models/conversation.dart';
import 'package:pa_messenger/models/message.dart';

class ChatArgs {
  Conversation conversation;
  ChatArgs(this.conversation);
}

class Chat extends StatefulWidget {

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  Conversation conversation;
  List<Message> messages = [];
  bool showLoading = false;
  bool isLoadingMore = false;
  bool loadedAll = false;

  QueryDocumentSnapshot lastDocument;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        conversation = (ModalRoute.of(context).settings.arguments as ChatArgs).conversation;
      });
      _fetchMessages();
    });
  }

  Query _buildQuery({QueryDocumentSnapshot startAfter}) {
    var query = FirebaseFirestore.instance
        .collection('conversations/${conversation.id}/messages')
        .orderBy('createTime', descending: true);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(10);
  }

  Future<void> _fetchMessages() async {
    setState(() { showLoading = true; });

    final result = await _buildQuery().get();

    setState(() {
      messages = Message.fromMapList(result.docs.map((x) => x.data()).toList());
      if (messages.length != 0) {
        lastDocument = result.docs.last;
      }
      showLoading = false;
    });
  }

  Future<void> _fetchMoreMessages() async {
    setState(() { isLoadingMore = true; });

    final result = await _buildQuery(startAfter: lastDocument).get();
    final newMessages = Message.fromMapList(result.docs.map((x) => x.data()).toList());

    setState(() {
      if (newMessages.length != 0) {
        messages.addAll(newMessages);
        lastDocument = result.docs.last;

      } else {
        loadedAll = true;
      }
      isLoadingMore = false;
    });
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
            child: ListView.builder(
              reverse: true,
              itemBuilder: (context, index) {
                if (index != messages.length) {
                  return _MessageItem(messages[index]);
                }

                return Center(child: CircularProgressIndicator());
              },
              itemCount: loadedAll ? messages.length : messages.length + 1,
            ),
          );
        },
      ),
    );
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
