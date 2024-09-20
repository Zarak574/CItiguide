class UserModel {
  String? email;
  String? role;
  String? uid;

  String? username;

// receiving data
  UserModel({this.uid, this.email, this.username});
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],

    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
    };
  }
}