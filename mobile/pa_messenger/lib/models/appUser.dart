class AppUser {
  String bio;
  String imageUrl;
  String name;
  String phoneNumber;

  AppUser({
    this.bio,
    this.imageUrl,
    this.name,
    this.phoneNumber,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      bio: map['bio'],
      imageUrl: map['imageUrl'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() => {
    'bio': bio,
    'imageUrl': imageUrl,
    'name': name,
    'phoneNumber': phoneNumber,
  };
}
