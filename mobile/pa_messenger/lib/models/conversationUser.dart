class ConversationUser {

  String userId;
  String userName;
  String imageUrl;

  ConversationUser({
    this.userId,
    this.userName,
    this.imageUrl,
  });

  factory ConversationUser.fromMap(Map<String, dynamic> map) {
    return ConversationUser(
      userId: map['userId'],
      userName: map['userName'],
      imageUrl: map['imageUrl'],
    );
  }

  static List<ConversationUser> fromMapList(List<dynamic> list) {
    return list.map((x) => ConversationUser.fromMap(x)).toList();
  }
}
