import 'package:cloud_firestore/cloud_firestore.dart';

import 'conversationUser.dart';

class Conversation {

  String id = '';

  List<ConversationUser> users;
  List<String> userIds;
  String latestMessage;
  String latestMessageId;
  Timestamp latestMessageTimestamp;
  String latestMessageSentBy;

  Map<String, dynamic> seen; // { userId: messageId }

  Conversation({
    this.id,
    this.users,
    this.userIds,
    this.latestMessage,
    this.latestMessageId,
    this.latestMessageTimestamp,
    this.latestMessageSentBy,
    this.seen,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      users: ConversationUser.fromMapList(map['users'] ?? []),
      seen: map['seen'] ?? {},
      userIds: List<String>.from(map['userIds'] ?? []),
      latestMessage: map['latestMessage'],
      latestMessageId: map['latestMessageId'] ?? null,
      latestMessageTimestamp: map['latestMessageTimestamp'],
      latestMessageSentBy: map['latestMessageSentBy'],
    );
  }

  static List<Conversation> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((x) => Conversation.fromMap(x)).toList();
  }
}
