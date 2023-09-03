import '../components/piece.dart';
import '../consts/images.dart';

bool isInBoard(int q, int r) {
  return q >= 0 &&
      q < 11 &&
      r >= 0 &&
      r < 11 &&
      !(r == 0 && q <= 4) &&
      !(r == 1 && q <= 3) &&
      !(r == 2 && q <= 2) &&
      !(r == 3 && q <= 1) &&
      !(r == 4 && q == 0) &&
      !(r == 6 && q == 10) &&
      !(r == 7 && q >= 9) &&
      !(r == 8 && q >= 8) &&
      !(r == 9 && q >= 7) &&
      !(r == 10 && q >= 6);
}

bool isPawnAtInitialPosition(int q, int r, bool isWhite) {
  return isWhite
      ? (q == 1 && r == 10) ||
          (q == 2 && r == 9) ||
          (q == 3 && r == 8) ||
          (q == 4 && r == 7) ||
          (q == 5 && r == 6) ||
          (q == 6 && r == 6) ||
          (q == 7 && r == 6) ||
          (q == 8 && r == 6) ||
          (q == 9 && r == 6)
      : (q == 1 && r == 4) ||
          (q == 2 && r == 4) ||
          (q == 3 && r == 4) ||
          (q == 4 && r == 4) ||
          (q == 5 && r == 4) ||
          (q == 6 && r == 3) ||
          (q == 7 && r == 2) ||
          (q == 8 && r == 1) ||
          (q == 9 && r == 0);
}

List<List<ChessPiece?>> initBoard() {
  List<List<ChessPiece?>> newBoard =
      List.generate(11, (_) => List.filled(11, null));

  // place pawns
  ChessPiece bPawn = ChessPiece(
    type: ChessPieceType.pawn,
    isWhite: false,
    imagePath: pieceImagePaths[ChessPieceType.pawn]!,
  );
  ChessPiece wPawn = ChessPiece(
    type: ChessPieceType.pawn,
    isWhite: true,
    imagePath: pieceImagePaths[ChessPieceType.pawn]!,
  );
  for (int i = 1; i <= 5; i++) {
    newBoard[i][4] = bPawn;
  }
  for (int i = 1; i <= 4; i++) {
    newBoard[5 + i][4 - i] = bPawn;
  }
  for (int i = 1; i <= 5; i++) {
    newBoard[4 + i][6] = wPawn;
  }
  for (int i = 1; i <= 4; i++) {
    newBoard[i][11 - i] = wPawn;
  }

  // place rooks
  ChessPiece bRook = ChessPiece(
    type: ChessPieceType.rook,
    isWhite: false,
    imagePath: pieceImagePaths[ChessPieceType.rook]!,
  );
  ChessPiece wRook = ChessPiece(
    type: ChessPieceType.rook,
    isWhite: true,
    imagePath: pieceImagePaths[ChessPieceType.rook]!,
  );
  newBoard[2][3] = bRook;
  newBoard[8][0] = bRook;
  newBoard[2][10] = wRook;
  newBoard[8][7] = wRook;

  // place knights
  ChessPiece bKnight = ChessPiece(
    type: ChessPieceType.knight,
    isWhite: false,
    imagePath: pieceImagePaths[ChessPieceType.knight]!,
  );
  ChessPiece wKnight = ChessPiece(
    type: ChessPieceType.knight,
    isWhite: true,
    imagePath: pieceImagePaths[ChessPieceType.knight]!,
  );
  newBoard[3][2] = bKnight;
  newBoard[7][0] = bKnight;
  newBoard[3][10] = wKnight;
  newBoard[7][8] = wKnight;

  // place bishops
  ChessPiece bBishop = ChessPiece(
    type: ChessPieceType.bishop,
    isWhite: false,
    imagePath: pieceImagePaths[ChessPieceType.bishop]!,
  );
  ChessPiece wBishop = ChessPiece(
    type: ChessPieceType.bishop,
    isWhite: true,
    imagePath: pieceImagePaths[ChessPieceType.bishop]!,
  );
  for (int i = 0; i <= 2; i++) {
    newBoard[5][i] = bBishop;
    newBoard[5][10 - i] = wBishop;
  }

  // place queen
  newBoard[4][1] = ChessPiece(
    type: ChessPieceType.queen,
    isWhite: false,
    imagePath: pieceImagePaths[ChessPieceType.queen]!,
  );
  newBoard[4][10] = ChessPiece(
    type: ChessPieceType.queen,
    isWhite: true,
    imagePath: pieceImagePaths[ChessPieceType.queen]!,
  );

  // place king
  newBoard[6][0] = ChessPiece(
    type: ChessPieceType.king,
    isWhite: false,
    imagePath: pieceImagePaths[ChessPieceType.king]!,
  );
  newBoard[6][9] = ChessPiece(
    type: ChessPieceType.king,
    isWhite: true,
    imagePath: pieceImagePaths[ChessPieceType.king]!,
  );

  return newBoard;
}

List<Map<String, dynamic>> convertBoardToListOfMaps(
    List<List<ChessPiece?>> board) {
  List<Map<String, dynamic>> boardData = [];
  for (int i = 0; i < board.length; i++) {
    List<ChessPiece?> row = board[i];
    Map<String, dynamic> rowData = {};
    for (int j = 0; j < row.length; j++) {
      if (row[j] != null) {
        rowData[j.toString()] = row[j]!.toJson();
      }
    }
    boardData.add(rowData);
  }
  return boardData;
}

//TODO: this function should convert the output of this function: convertBoardToListOfMaps() back to a board (List<List<ChessPiece?>>)
List<List<ChessPiece?>> convertListOfMapsToBoard(
    List<Map<String, dynamic>> boardData) {
  Map<String, ChessPieceType> typeMap = {
    'king': ChessPieceType.king,
    'queen': ChessPieceType.queen,
    'rook': ChessPieceType.rook,
    'bishop': ChessPieceType.bishop,
    'knight': ChessPieceType.knight,
    'pawn': ChessPieceType.pawn,
  };

  List<List<ChessPiece?>> board =
      List.generate(11, (_) => List.filled(11, null));
  for (int i = 0; i < boardData.length; i++) {
    Map<String, dynamic> row = boardData[i];
    for (int j = 0; j < row.length; j++) {
      if (row.containsKey(j.toString())) {
        Map<String, dynamic> pieceData = row[j.toString()];
        ChessPiece piece = ChessPiece(
          type: typeMap[pieceData['type']]!,
          isWhite: pieceData['isWhite'],
          imagePath: pieceData['imagePath'],
        );
        board[i][j] = piece;
      }
    }
  }
  return board;
}

List<Map<String, dynamic>> convertCapturedListToListOfMaps(
    List<ChessPiece> pieces) {
  return pieces.map((piece) => piece.toJson()).toList();
}
