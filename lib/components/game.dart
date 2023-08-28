import 'package:chexagon/components/piece.dart';

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
