import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/models/conversation.dart';
import 'package:pa_messenger/pages/chat.dart';
import 'package:pa_messenger/utils/time_utils.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';

class ConversationList extends StatefulWidget {

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {

  List<Conversation> firstPageOfConversations = [];
  List<Conversation> otherPagesOfConversations = [];
  List<Conversation> get conversations => [...firstPageOfConversations, ...otherPagesOfConversations];

  bool showLoading = false;
  bool isLoadingMore = false;
  bool loadedAll = false;

  QueryDocumentSnapshot lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Query _buildQuery({QueryDocumentSnapshot startAfter}) {
    var query = FirebaseFirestore.instance
      .collection('conversations')
      .where('userIds', arrayContains: FirebaseAuth.instance.currentUser.uid)
      .orderBy('latestMessageTimestamp', descending: true);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(10);
  }

  StreamSubscription<QuerySnapshot> subscription;

  Future<void> _fetchConversations() async {
    setState(() { showLoading = true; });
    subscription = _buildQuery().snapshots().listen((result) {
      setState(() {
        firstPageOfConversations = Conversation.fromMapList(result.docs.map((x) => x.data()..addAll({'id': x.id})).toList());
        if (conversations.length != 0) {
          lastDocument = result.docs.last;
        }
        showLoading = false;
      });
    });
  }

  Future<void> _fetchMoreConversations() async {
    setState(() { isLoadingMore = true; });

    final result = await _buildQuery(startAfter: lastDocument).get();
    final newConversations = Conversation.fromMapList(result.docs.map((x) => x.data()..addAll({'id': x.id})).toList());

    setState(() {
      if (newConversations.length != 0) {
        conversations.addAll(newConversations);
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
        title: Text('Conversations'),
        actions: [
          FlatButton(
            child: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/phone-login', (route) => false);
            },
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          if (showLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !isLoadingMore && !loadedAll) {
                _fetchMoreConversations();
              }
            },
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (index != conversations.length) {
                  return _ConversationListItem(conversations[index]);
                }

                return Center(child: CircularProgressIndicator());
              },
              itemCount: loadedAll ? conversations.length : conversations.length + 1,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
}

class _ConversationListItem extends StatelessWidget {

  final Conversation conversation;

  _ConversationListItem(this.conversation);

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.users.firstWhere((x) => x.userId != FirebaseAuth.instance.currentUser.uid);
    
    var latestMessage = conversation.latestMessage;
    if (conversation.latestMessageSentBy == FirebaseAuth.instance.currentUser.uid) {
      latestMessage = 'You: ' + conversation.latestMessage;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/chat', arguments: ChatArgs(conversation: conversation));
      },
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _image(otherUser.imageUrl),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title(context, otherUser.userName),
                        Container(height: 2),
                        _latestMessageText(context, latestMessage)
                      ]),
                ),
              ],
            ),
            _timestamp(context, calculateTimestamp(conversation.latestMessageTimestamp.toDate()))
          ],
        ),
      ),
    );
  }

  _image(String imageUrl) => AppRoundImage.url(
    imageUrl,
    width: 60,
    height: 60,
  );

  bool get didUserSee => conversation.latestMessageId == conversation.seen[FirebaseAuth.instance.currentUser.uid] || conversation.latestMessageSentBy == FirebaseAuth.instance.currentUser.uid;

  _title(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .headline6
            .apply(fontSizeDelta: -2, fontWeightDelta: didUserSee ? 1 : 2));
  }

  _latestMessageText(BuildContext context, String text) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Text(text,
        style: Theme.of(context).textTheme.caption.apply(
          fontWeightDelta: didUserSee ? 0 : 4,
          color: didUserSee ? Colors.grey.shade600 : Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis
      )
    );
  }

  _timestamp(BuildContext context, String timestamp) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, right: 4),
      child: Text(timestamp, style: Theme.of(context).textTheme.caption.apply(
        fontWeightDelta: didUserSee ? 0 : 4,
        color: didUserSee ? Colors.grey.shade600 : Colors.black,
      )),
    );
  }

}
