enum ChessPieceType { pawn, rook, knight, bishop, queen, king, enPassant }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'isWhite': isWhite,
      'imagePath': imagePath,
    };
  }

  factory ChessPiece.fromJson(Map<String, dynamic> json) {
    Map<String, ChessPieceType> typeMap = {
      'king': ChessPieceType.king,
      'queen': ChessPieceType.queen,
      'rook': ChessPieceType.rook,
      'bishop': ChessPieceType.bishop,
      'knight': ChessPieceType.knight,
      'pawn': ChessPieceType.pawn,
    };
    final type = json['type'] as String;
    return ChessPiece(
      type: typeMap[type]!,
      isWhite: json['isWhite'],
      imagePath: json['imagePath'],
    );
  }
}
