import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String pfpUrl;
  final Timestamp createdAt;
  // final List<int> currentGames;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.pfpUrl,
    required this.createdAt,
    // required this.currentGames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'pfpUrl': pfpUrl,
      'createdAt': createdAt,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      pfpUrl: map['pfpUrl'],
      createdAt: map['createdAt'],
    );
  }
}
