import 'package:chexagon/components/piece.dart';

class GameModel {
  final String id;
  final bool isLocal;
  final DateTime startedAt;
  final List<List<ChessPiece?>> board;
  final bool isWhiteTurn;
  // final List<int> whiteKingPosition;
  // final List<int> blackKingPosition;
  final List<ChessPiece> whiteCaptured;
  final List<ChessPiece> blackCaptured;

  GameModel({
    required this.id,
    required this.isLocal,
    required this.startedAt,
    required this.board,
    required this.isWhiteTurn,
    required this.whiteCaptured,
    required this.blackCaptured,
  });

  Map<String, dynamic> toJson() {
    return {
      'startedAt': startedAt.toIso8601String(),
      'board': board
          .map((row) => row.map((piece) => piece?.toJson()).toList())
          .toList(),
      'isWhiteTurn': isWhiteTurn,
      'whiteCaptured': whiteCaptured.map((piece) => piece.toJson()).toList(),
      'blackCaptured': blackCaptured.map((piece) => piece.toJson()).toList(),
    };
  }
}

// TODO: Implement this (saving in shared preferences)
// TODO: also adding saving to database

// // Store the game object in SharedPreferences
// void saveGame(Game game) async {
//   final prefs = await SharedPreferences.getInstance();
//   final gameJson = jsonEncode(game.toJson());
//   await prefs.setString('game', gameJson);
// }

// // Retrieve the game object from SharedPreferences
// Future<Game?> loadGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   final gameJson = prefs.getString('game');
//   if (gameJson != null) {
//     final gameMap = jsonDecode(gameJson);
//     return Game(
//       startedAt: DateTime.parse(gameMap['startedAt']),
//       board: List<List<ChessPiece?>>.from(gameMap['board'].map((row) => List<ChessPiece?>.from(row.map((piece) => piece != null ? ChessPiece.fromJson(piece) : null)))),
//       isWhiteTurn: gameMap['isWhiteTurn'],
//       whiteCaptured: List<ChessPiece>.from(gameMap['whiteCaptured'].map((piece) => ChessPiece.fromJson(piece))),
//       blackCaptured: List<ChessPiece>.from(gameMap['blackCaptured'].map((piece) => ChessPiece.fromJson(piece))),
//     );
//   } else {
//     return null;
//   }
// }