import 'package:cloud_firestore/cloud_firestore.dart';

import 'conversationUser.dart';

class Conversation {

  String id = '';

  List<ConversationUser> users;
  List<String> userIds;
  String latestMessage;
  Timestamp latestMessageTimestamp;
  String latestMessageSentBy;

  Conversation({
    this.id,
    this.users,
    this.userIds,
    this.latestMessage,
    this.latestMessageTimestamp,
    this.latestMessageSentBy,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      users: ConversationUser.fromMapList(map['users']),
      userIds: List<String>.from(map['userIds']),
      latestMessage: map['latestMessage'],
      latestMessageTimestamp: map['latestMessageTimestamp'],
      latestMessageSentBy: map['latestMessageSentBy'],
    );
  }

  static List<Conversation> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((x) => Conversation.fromMap(x)).toList();
  }
}
