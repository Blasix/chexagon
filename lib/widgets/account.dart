import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/user.dart';

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
                  children: [
                    const CircleAvatar(),
                    const SizedBox(width: 10),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ));
}
