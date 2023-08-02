import 'dart:math';

import 'package:chexagon/components/piece.dart';
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

  // declare a variable to hold the piece
  ChessPiece? piece;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HexagonGrid.flat(
        color: Colors.grey[300],
        depth: 5,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        buildTile: (coordinates) {
          // TODO: convert the 2-dimensional list index to pieces on the board
          piece = board[5 + coordinates.q][5 + coordinates.r];

          // return a widget for the tile
          return HexagonWidgetBuilder(
            color: whatColor(coordinates),
            padding: 2.0,
            cornerRadius: 8.0,
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
          );
        },
      ),
    );
  }
}
