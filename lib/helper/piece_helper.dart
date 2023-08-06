import '../components/piece.dart';

int calculateWorth(List blackPieces, List whitePieces) {
  int worth = 0;

  for (int i = 0; i < blackPieces.length; i++) {
    if (blackPieces[i].type == ChessPieceType.pawn) {
      worth -= 1;
    } else if (blackPieces[i].type == ChessPieceType.rook) {
      worth -= 5;
    } else if (blackPieces[i].type == ChessPieceType.knight) {
      worth -= 3;
    } else if (blackPieces[i].type == ChessPieceType.bishop) {
      worth -= 3;
    } else if (blackPieces[i].type == ChessPieceType.queen) {
      worth -= 9;
    }
  }
  for (int i = 0; i < whitePieces.length; i++) {
    if (whitePieces[i].type == ChessPieceType.pawn) {
      worth += 1;
    } else if (whitePieces[i].type == ChessPieceType.rook) {
      worth += 5;
    } else if (whitePieces[i].type == ChessPieceType.knight) {
      worth += 3;
    } else if (whitePieces[i].type == ChessPieceType.bishop) {
      worth += 3;
    } else if (whitePieces[i].type == ChessPieceType.queen) {
      worth += 9;
    }
  }

  return worth;
}
