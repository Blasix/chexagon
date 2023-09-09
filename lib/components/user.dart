import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.pfpUrl,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final String pfpUrl;
  final Timestamp createdAt;

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      pfpUrl: map['pfpUrl'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}
