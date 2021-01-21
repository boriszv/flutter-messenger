import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String messageText;
  String imageUrl;
  String userId;
  Timestamp createTime;

  Message({
    this.messageText,
    this.imageUrl,
    this.userId,
    this.createTime,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageText: map['messageText'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
      createTime: map['createTime']
    );
  }

  static List<Message> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((x) => Message.fromMap(x)).toList();
  }
}