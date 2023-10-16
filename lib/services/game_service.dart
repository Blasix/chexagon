import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../components/game.dart';

final gamesProvider = StreamProvider.autoDispose<List<OnlineGameModel>>((ref) {
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection('games');

  final Stream<QuerySnapshot> player1GamesStream = gamesCollection
      .where('player1', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  final Stream<QuerySnapshot> player2GamesStream = gamesCollection
      .where('player2', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  ref.onDispose(() {
    player1GamesStream.drain();
    player2GamesStream.drain();
  });
  final Stream<List<OnlineGameModel>> gamesStream = Rx.combineLatest2(
      player1GamesStream, player2GamesStream,
      (QuerySnapshot player1GamesSnapshot, QuerySnapshot player2GamesSnapshot) {
    final List<OnlineGameModel> player1Games = player1GamesSnapshot.docs
        .map((QueryDocumentSnapshot doc) =>
            OnlineGameModel.fromJson(doc.data()! as Map<String, dynamic>))
        .toList();
    final List<OnlineGameModel> player2Games = player2GamesSnapshot.docs
        .map((QueryDocumentSnapshot doc) =>
            OnlineGameModel.fromJson(doc.data()! as Map<String, dynamic>))
        .toList();
    return [...player1Games, ...player2Games];
  });
  return gamesStream;
});
