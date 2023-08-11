import 'package:chexagon/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showAccountDialog(BuildContext context) {
  if (FirebaseAuth.instance.currentUser == null) {
    return;
  }
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('${FirebaseAuth.instance.currentUser!.displayName}'),
            actions: [
              // play game again
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                    FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Logout')),
            ],
          ));
}
