import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/user.dart';

final userProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
  ref.onDispose(() {
    userStream.drain();
  });
  final Stream<UserModel?> userModelStream = userStream.map((snapshot) {
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data()!);
    }
    return null;
  });
  return userModelStream;
});
