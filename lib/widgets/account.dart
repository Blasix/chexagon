import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../components/user.dart';
import '../consts/colors.dart';
import '../helper/message_helper.dart';

// TODO: add ability to change username/email

String calculateAccountAge(Timestamp createdAt) {
  final now = DateTime.now();
  final createdAtDate = createdAt.toDate();
  final difference = now.difference(createdAtDate);
  switch (difference.inSeconds) {
    case > 29030400:
      return '${difference.inDays ~/ 365} years ago';
    case > 2592000:
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

Future<void> deleteAccount(BuildContext context) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // TODO dispose providers
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await FirebaseStorage.instance
        .ref()
        .child('profile_pictures/$uid.jpg')
        .delete();
    await FirebaseAuth.instance.currentUser!.delete();
    if (context.mounted) {
      Navigator.pop(context);
      context.go('/login');
    }
  } catch (error) {
    if (context.mounted) showErrorSnackbar(context, error.toString());
  }
}

Future<void> changePfp(BuildContext context) async {
  try {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Reference ref =
        FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
    if (image == null) return;
    await ref.putData(
        await image.readAsBytes(),
        SettableMetadata(
          contentType: 'image/jpeg',
        ));
    ref.getDownloadURL().then((value) async {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'pfpUrl': value,
      });
    });
  } catch (error) {
    if (context.mounted) showErrorSnackbar(context, error.toString());
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
                  onTap: () async {
                    await changePfp(context);
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
          Text(
            user.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // TODO dispose providers
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
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  await deleteAccount(context);
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
        ],
      ),
    ),
  );
}
