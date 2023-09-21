import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../components/user.dart';
import '../consts/colors.dart';

// TODO: add ability to change profile picture
// TODO: add ability to change username/email
// for picture: https://github.com/Blasix/group_planner_app/blob/master/lib/screens/user.dart

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
              SizedBox(
                height: 60,
                width: 60,
                child: InkWell(
                  onTap: () {
                    print('avatar');
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: (user.pfpUrl != '')
                              ? null
                              : const AssetImage('images/pfp_placeholder.jpg'),
                          foregroundImage: (user.pfpUrl == '')
                              ? null
                              : NetworkImage(user.pfpUrl),
                          radius: 30,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe3e3e3),
                            border: Border.all(color: cardColor!),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            FontAwesomeIcons.pen,
                            color: bgColor,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              print('username');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: cardColor!),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    FontAwesomeIcons.pen,
                    color: bgColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              print('mail');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: cardColor!),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    FontAwesomeIcons.pen,
                    color: bgColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.arrowRightFromBracket,
                    color: Colors.red, size: 20),
                SizedBox(width: 6),
                Text('Logout'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO delete account
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.trash, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
