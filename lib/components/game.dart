import 'package:cloud_firestore/cloud_firestore.dart';

import 'piece.dart';

class OnlineGameModel {
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
    final whiteCaptured = (json['whiteCaptured'] as List<dynamic>)
        .map((piece) => ChessPiece.fromJson(piece as Map<String, dynamic>))
        .toList();
    final blackCaptured = (json['blackCaptured'] as List<dynamic>)
        .map((piece) => ChessPiece.fromJson(piece as Map<String, dynamic>))
        .toList();

    final board = (json['board'] as List<dynamic>).map((row) {
      return List<ChessPiece?>.generate(11, (index) {
        final piece = row[index.toString()];
        if (piece == null) {
          return null;
        } else {
          return ChessPiece.fromJson(piece as Map<String, dynamic>);
        }
      });
    }).toList();

    return OnlineGameModel(
      id: json['id'] as String,
      player1: json['player1'] as String,
      player2: json['player2'] as String,
      isPlayer1White: json['isPlayer1White'] as bool,
      startedAt: json['startedAt'] as Timestamp,
      board: board,
      isWhiteTurn: json['isWhiteTurn'] as bool,
      whiteCaptured: whiteCaptured,
      blackCaptured: blackCaptured,
    );
  }

  final String id;
  final String player1;
  final String player2;
  final bool isPlayer1White;
  final Timestamp startedAt;
  final List<List<ChessPiece?>> board;
  final bool isWhiteTurn;
  final List<ChessPiece> whiteCaptured;
  final List<ChessPiece> blackCaptured;
}
