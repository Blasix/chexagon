enum ChessPieceType { pawn, rook, knight, bishop, queen, king, enPassant }

class ChessPiece {
  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });

  factory ChessPiece.fromJson(Map<String, dynamic> json) {
    final Map<String, ChessPieceType> typeMap = {
      'king': ChessPieceType.king,
      'queen': ChessPieceType.queen,
      'rook': ChessPieceType.rook,
      'bishop': ChessPieceType.bishop,
      'knight': ChessPieceType.knight,
      'pawn': ChessPieceType.pawn,
      'enPassant': ChessPieceType.enPassant,
    };
    final String type = json['type'] as String;
    return ChessPiece(
      type: typeMap[type]!,
      isWhite: json['isWhite'] as bool,
      imagePath: json['imagePath'] as String,
    );
  }

  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'isWhite': isWhite,
      'imagePath': imagePath,
    };
  }
}
