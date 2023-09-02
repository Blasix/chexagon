// get all games of wich the current user their id is either player1 or player2

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/game.dart';

// TODO: make getCurrentGames() into listenToCurrentGames() so it updates in real time

class GameService {
  final CollectionReference _gamesCollection =
      FirebaseFirestore.instance.collection('games');

  Future<List<OnlineGameModel>> getCurrentGames() async {
    final QuerySnapshot player1GamesSnapshot = await _gamesCollection
        .where('player1', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final List<OnlineGameModel> player1Games = player1GamesSnapshot.docs
        .map((QueryDocumentSnapshot doc) =>
            OnlineGameModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    final QuerySnapshot player2GamesSnapshot = await _gamesCollection
        .where('player2', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final List<OnlineGameModel> player2Games = player2GamesSnapshot.docs
        .map((QueryDocumentSnapshot doc) =>
            OnlineGameModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    final List<OnlineGameModel> games = [...player1Games, ...player2Games];
    return games;
  }
}
