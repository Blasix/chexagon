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
    return ChessPiece(
      type: ChessPieceType.values.firstWhere(
          (type) => type.toString().split('.').last == json['type']),
      isWhite: json['isWhite'],
      imagePath: json['imagePath'],
    );
  }
}
