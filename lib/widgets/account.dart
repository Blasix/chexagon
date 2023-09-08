import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../components/user.dart';

String calculateAccountAge(Timestamp createdAt) {
  final now = DateTime.now();
  final createdAtDate = createdAt.toDate();
  final difference = now.difference(createdAtDate);
  switch (difference.inSeconds) {
    case > 29030400:
      return '${difference.inDays ~/ 365} years ago';
    case > 2419200:
      return '${difference.inDays ~/ 30} months ago';
    case > 604800:
      return '${difference.inDays ~/ 7} weeks ago';
    case > 86400:
      return '${difference.inDays} days ago';
    case > 3600:
      return '${difference.inHours} hours ago';
    case > 60:
      return '${difference.inMinutes} minutes ago';
    default:
      return '${difference.inSeconds} seconds ago';
  }
}

void showAccountDialog(BuildContext context, UserModel user) {
  if (FirebaseAuth.instance.currentUser == null) {
    return;
  }
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Joined'),
                        Text(
                          calculateAccountAge(user.createdAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.arrowRightFromBracket,
                            color: Colors.red, size: 20),
                        SizedBox(width: 6),
                        Text('Logout'),
                      ],
                    )),
              ],
            ),
          ));
}
