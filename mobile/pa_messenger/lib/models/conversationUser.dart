class ConversationUser {

  String userId;
  String userName;
  String imageUrl;
  String latestMessageSeen;

  ConversationUser({
    this.userId,
    this.userName,
    this.imageUrl,
    this.latestMessageSeen
  });

  factory ConversationUser.fromMap(Map<String, dynamic> map) {
    return ConversationUser(
      userId: map['userId'],
      userName: map['userName'],
      imageUrl: map['imageUrl'],
      latestMessageSeen: map['latestMessageSeen'] ?? '',
    );
  }

  static List<ConversationUser> fromMapList(List<dynamic> list) {
    return list.map((x) => ConversationUser.fromMap(x)).toList();
  }
}
