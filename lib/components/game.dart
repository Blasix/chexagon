import 'package:chexagon/components/piece.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final bool isLocal;
  final DateTime startedAt;
  final List<List<ChessPiece?>> board;
  final bool isWhiteTurn;
  final bool isPlayer1White;
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
    required this.isPlayer1White,
    required this.whiteCaptured,
    required this.blackCaptured,
  });
}

// TODO: change all dynamic to appropriate types
class OnlineGameModel {
  final String id;
  final String player1;
  final String player2;
  final bool isPlayer1White;
  final Timestamp startedAt;
  final List<dynamic> board;
  final bool isWhiteTurn;
  final List<dynamic> whiteCaptured;
  final List<dynamic> blackCaptured;

  OnlineGameModel({
    required this.id,
    required this.player1,
    required this.player2,
    required this.board,
    required this.isPlayer1White,
    required this.startedAt,
    required this.isWhiteTurn,
    required this.whiteCaptured,
    required this.blackCaptured,
  });

  factory OnlineGameModel.fromJson(Map<String, dynamic> json) {
    return OnlineGameModel(
      id: json['id'] as String,
      player1: json['player1'] as String,
      player2: json['player2'] as String,
      isPlayer1White: json['isPlayer1White'] as bool,
      startedAt: json['startedAt'] as Timestamp,
      board: json['board'] as List<dynamic>,
      isWhiteTurn: json['isWhiteTurn'] as bool,
      whiteCaptured: json['whiteCaptured'] as List<dynamic>,
      blackCaptured: json['blackCaptured'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player1': player1,
      'player2': player2,
      'isPlayer1White': isPlayer1White,
      'startedAt': DateTime.now(),
      'board': board,
      'isWhiteTurn': isWhiteTurn,
      'whiteCaptured': whiteCaptured,
      'blackCaptured': blackCaptured,
    };
  }
}
