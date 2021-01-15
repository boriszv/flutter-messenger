import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/models/conversation.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';

class ConversationList extends StatelessWidget {

  Future<List<Conversation>> _buildQuery() async {
    final result = await FirebaseFirestore.instance
      .collection('conversations')
      .where('userIds', arrayContains: FirebaseAuth.instance.currentUser.uid)
      .orderBy('latestMessageTimestamp', descending: true)
      .limit(10)
      .get();

    return Conversation.fromMapList(result.docs.map((x) => x.data()).toList());
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
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          )
        ],
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _buildQuery(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting || state.connectionState == ConnectionState.active) {
            return Center(child: CircularProgressIndicator());
          }

          final list = state.data;

          return ListView.builder(
            itemBuilder: (context, index) {
              return _ConversationListItem(list[index]);
            },
            itemCount: list.length,
          );
        },
      ),
      
    );
  }
}

class _ConversationListItem extends StatelessWidget {

  final Conversation conversation;

  _ConversationListItem(this.conversation);

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.users.firstWhere((x) => x.userId != FirebaseAuth.instance.currentUser.uid);

    return InkWell(
      onTap: () {},
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
                        _latestMessageText(context, conversation.latestMessage)
                      ]),
                ),
              ],
            ),
            _timestamp(context, _calculateTimestamp(conversation.latestMessageTimestamp.toDate()))
          ],
        ),
      ),
    );
  }

  _image(String imageUrl) => AppRoundImage(
        imageUrl,
        width: 60,
        height: 60,
      );

  _title(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .headline6
            .apply(fontSizeDelta: -2, fontWeightDelta: 2));
  }

  _latestMessageText(BuildContext context, String text) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Text(text, style: Theme.of(context).textTheme.caption, maxLines: 1, overflow: TextOverflow.ellipsis)
    );
  }

  _timestamp(BuildContext context, String timestamp) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, right: 4),
      child: Text(timestamp, style: Theme.of(context).textTheme.caption),
    );
  }

  _calculateTimestamp(DateTime date) {
    return '${_stringifyNumber(date.hour)}:${_stringifyNumber(date.minute)}';
  }

  _stringifyNumber(int number) {
    if (number < 10) {
      return '0' + number.toString();
    }
    return number.toString();
  }
}
