import 'package:chexagon/components/piece.dart';
import 'package:chexagon/helper/board_helper.dart';
import 'package:chexagon/helper/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-dimensional list representing the chessboard,
  // with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  // initialize board
  void _initBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(11, (_) => List.filled(11, null));

    // place pawns
    ChessPiece bPawn = ChessPiece(
      type: ChessPieceType.pawn,
      isWhite: false,
      imagePath: 'images/pawn.png',
    );
    ChessPiece wPawn = ChessPiece(
      type: ChessPieceType.pawn,
      isWhite: true,
      imagePath: 'images/pawn.png',
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
      imagePath: 'images/rook.png',
    );
    ChessPiece wRook = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'images/rook.png',
    );
    newBoard[2][3] = bRook;
    newBoard[8][0] = bRook;
    newBoard[2][10] = wRook;
    newBoard[8][7] = wRook;

    // place knights
    ChessPiece bKnight = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'images/knight.png',
    );
    ChessPiece wKnight = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'images/knight.png',
    );
    newBoard[3][2] = bKnight;
    newBoard[7][0] = bKnight;
    newBoard[3][10] = wKnight;
    newBoard[7][8] = wKnight;

    // place bishops
    ChessPiece bBishop = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'images/bishop.png',
    );
    ChessPiece wBishop = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'images/bishop.png',
    );
    for (int i = 0; i <= 2; i++) {
      newBoard[5][i] = bBishop;
      newBoard[5][10 - i] = wBishop;
    }

    // place queen
    newBoard[4][1] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'images/queen.png',
    );
    newBoard[4][10] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'images/queen.png',
    );

    // place king
    newBoard[6][0] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'images/king.png',
    );
    newBoard[6][9] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'images/king.png',
    );

    board = newBoard;
  }

  // user selects a piece
  void pieceSelected(Coordinates coordinates) {
    setState(() {
      int q = 5 + coordinates.q;
      int r = 5 + coordinates.r;
      // selected a piece if there is one
      if (board[q][r] != null) {
        selectedPiece = board[q][r];
        selectedCoordinates = coordinates;
      }
      validMoves = calculateRawValidMoves(q, r, selectedPiece!);
    });
  }

  // calculate the raw valid moves for a piece
  List<List<int>> calculateRawValidMoves(int q, int r, ChessPiece? piece) {
    List<List<int>> canidateMoves = [];

    // different moves for different color
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn can move forward
        if (isInBoard(q, r + direction) && board[q][r + direction] == null) {
          canidateMoves.add([q, r + direction]);
        }
        // pawn can move 2 hexagons foreward if it is the first move
        if (isPawnAtInitialPosition(q, r, piece.isWhite)) {
          if (isInBoard(q, r + 2 * direction) &&
              board[q][r + 2 * direction] == null) {
            canidateMoves.add([q, r + 2 * direction]);
          }
        }
        // pawn can move diagonally if there is an enemy piece
        if (isInBoard(q - direction, r + direction) &&
            board[q - direction][r + direction] != null &&
            board[q - direction][r + direction]!.isWhite != piece.isWhite) {
          canidateMoves.add([q - direction, r + direction]);
        }
        if (isInBoard(q + direction, r) &&
            board[q + direction][r] != null &&
            board[q + direction][r]!.isWhite != piece.isWhite) {
          canidateMoves.add([q + direction, r]);
        }
        // TODO: add en passant

        break;
      case ChessPieceType.rook:
        break;
      case ChessPieceType.knight:
        break;
      case ChessPieceType.bishop:
        break;
      case ChessPieceType.king:
        break;
      case ChessPieceType.queen:
        break;
    }
    return canidateMoves;
  }

  // declare a variables
  ChessPiece? piece;
  ChessPiece? selectedPiece;
  Coordinates? selectedCoordinates;
  bool isSelected = false;
  bool isValidMove = false;
  bool isWhiteTurn = true;

  // A list of valid moves for the selected piece
  // each move is represented by a list with 2 elements: q and r
  List<List<int>> validMoves = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HexagonGrid.flat(
        color: Colors.grey[300],
        depth: 5,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        buildTile: (coordinates) {
          piece = board[5 + coordinates.q][5 + coordinates.r];
          isSelected = selectedCoordinates == coordinates;
          for (var position in validMoves) {
            if (position[0] == 5 + coordinates.q &&
                position[1] == 5 + coordinates.r) {
              isValidMove = true;
              break;
            } else {
              isValidMove = false;
            }
          }
          Color? color = whatColor(coordinates);

          // set color for the tile
          if (isSelected) {
            color = Colors.green;
          } else if (isValidMove) {
            color = Colors.green[300];
          }

          // return a widget for the tile
          return HexagonWidgetBuilder(
              color: color,
              padding: 2.0,
              cornerRadius: 8.0,
              child: GestureDetector(
                onTap: () => pieceSelected(coordinates),
                child: SizedBox(
                  child: piece != null
                      ? Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            color: piece!.isWhite ? Colors.white : Colors.black,
                            piece!.imagePath,
                            fit: BoxFit.contain,
                          ),
                        )
                      : null,
                ),
              ));
        },
      ),
    );
  }
}
