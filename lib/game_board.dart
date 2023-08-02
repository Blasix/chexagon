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
    List<List<ChessPiece?>> newBoard = List.generate(15, (i) {
      if (i <= 5) {
        return List.filled(i + 1, null);
      } else if (i >= 10) {
        return List.filled(15 - i, null);
      } else if (i % 2 == 0) {
        return List.filled(5, null);
      } else {
        return List.filled(6, null);
      }
    });
    board = newBoard;
    // TODO: initialize the board with chess pieces
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
          //create a piece
          piece = ChessPiece(
            type: ChessPieceType.pawn,
            isWhite: Random().nextBool(),
            imagePath: 'images/pawn.png',
          );

          // TODO: convert the 2-dimensional list index to pieces on the board

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
