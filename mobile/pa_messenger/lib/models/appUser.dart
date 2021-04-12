class AppUser {
  String id;
  String bio;
  String imageUrl;
  String name;
  String phoneNumber;
  String email;

  AppUser({
    this.bio,
    this.imageUrl,
    this.name,
    this.phoneNumber,
    this.email,
    this.id,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      bio: map['bio'],
      imageUrl: map['imageUrl'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() => {
    'bio': bio,
    'imageUrl': imageUrl,
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
  };
}
