import 'package:chexagon/components/piece.dart';
import 'package:chexagon/helper/board_helper.dart';
import 'package:chexagon/helper/color_helper.dart';
import 'package:chexagon/helper/piece_helper.dart';
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
      // no piece is selected
      if (selectedPiece == null && board[q][r] != null) {
        if (board[q][r]!.isWhite == isWhiteTurn) {
          selectedPiece = board[q][r];
          selectedCoordinates = coordinates;
        }
      }

      // piece already selected, select another one
      else if (board[q][r] != null &&
          board[q][r]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[q][r];
        selectedCoordinates = coordinates;
      }

      // if user taps on valid move, move the piece
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == q && element[1] == r)) {
        movePiece(q, r);
        return;
      }

      if (selectedPiece != null &&
          board[q][r] != null &&
          board[q][r]!.isWhite == selectedPiece!.isWhite) {
        // if piece is selected, calculate valid moves
        validMoves = calculateRealValidMoves(q, r, selectedPiece!, true);
      }
    });
  }

  // calculate the raw valid moves for a piece
  List<List<int>> calculateRawValidMoves(int q, int r, ChessPiece? piece) {
    List<List<int>> canidateMoves = [];

    if (piece == null) {
      return canidateMoves;
    }

    // different moves for different color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn can move forward
        if (isInBoard(q, r + direction) && board[q][r + direction] == null) {
          canidateMoves.add([q, r + direction]);
          // pawn can move 2 hexagons foreward if it is the first move
          if (isPawnAtInitialPosition(q, r, piece.isWhite)) {
            if (isInBoard(q, r + 2 * direction) &&
                board[q][r + 2 * direction] == null) {
              canidateMoves.add([q, r + 2 * direction]);
            }
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
        var directions = [
          [0, -1],
          [1, -1],
          [1, 0],
          [0, 1],
          [-1, 1],
          [-1, 0],
        ];
        for (var directions in directions) {
          var i = 1;
          while (true) {
            var q2 = q + directions[0] * i;
            var r2 = r + directions[1] * i;
            if (!isInBoard(q2, r2)) {
              break;
            }
            if (board[q2][r2] != null) {
              if (board[q2][r2]!.isWhite != piece.isWhite) {
                canidateMoves.add([q2, r2]); // Capture
              }
              break;
            }
            canidateMoves.add([q2, r2]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        var directions = [
          [1, -3],
          [2, -3],
          [3, -2],
          [3, -1],
          [2, 1],
          [1, 2],
          [-1, 3],
          [-2, 3],
          [-3, 2],
          [-3, 1],
          [-2, -1],
          [-1, -2],
        ];
        for (var directions in directions) {
          var q2 = q + directions[0];
          var r2 = r + directions[1];
          if (!isInBoard(q2, r2)) {
            continue;
          }
          if (board[q2][r2] != null) {
            if (board[q2][r2]!.isWhite != piece.isWhite) {
              canidateMoves.add([q2, r2]); // Capture
            }
            continue;
          }
          canidateMoves.add([q2, r2]);
        }
        break;
      case ChessPieceType.bishop:
        var directions = [
          [1, -2],
          [2, -1],
          [1, 1],
          [-1, 2],
          [-2, 1],
          [-1, -1],
        ];
        for (var directions in directions) {
          var i = 1;
          while (true) {
            var q2 = q + directions[0] * i;
            var r2 = r + directions[1] * i;
            if (!isInBoard(q2, r2)) {
              break;
            }
            if (board[q2][r2] != null) {
              if (board[q2][r2]!.isWhite != piece.isWhite) {
                canidateMoves.add([q2, r2]); // Capture
              }
              break;
            }
            canidateMoves.add([q2, r2]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [0, -1],
          [1, -1],
          [1, 0],
          [0, 1],
          [-1, 1],
          [-1, 0],
          [1, -2],
          [2, -1],
          [1, 1],
          [-1, 2],
          [-2, 1],
          [-1, -1],
        ];
        for (var directions in directions) {
          var q2 = q + directions[0];
          var r2 = r + directions[1];
          if (!isInBoard(q2, r2)) {
            continue;
          }
          if (board[q2][r2] != null) {
            if (board[q2][r2]!.isWhite != piece.isWhite) {
              canidateMoves.add([q2, r2]); // Capture
            }
            continue;
          }
          canidateMoves.add([q2, r2]);
        }

        // TODO: add castling

        break;
      case ChessPieceType.queen:
        var directions = [
          [0, -1],
          [1, -1],
          [1, 0],
          [0, 1],
          [-1, 1],
          [-1, 0],
          [1, -2],
          [2, -1],
          [1, 1],
          [-1, 2],
          [-2, 1],
          [-1, -1],
        ];
        for (var directions in directions) {
          var i = 1;
          while (true) {
            var q2 = q + directions[0] * i;
            var r2 = r + directions[1] * i;
            if (!isInBoard(q2, r2)) {
              break;
            }
            if (board[q2][r2] != null) {
              if (board[q2][r2]!.isWhite != piece.isWhite) {
                canidateMoves.add([q2, r2]); // Capture
              }
              break;
            }
            canidateMoves.add([q2, r2]);
            i++;
          }
        }
        break;
    }
    return canidateMoves;
  }

  // calculate the real valid moves for a piece
  List<List<int>> calculateRealValidMoves(
      int q, int r, ChessPiece piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> canidateMoves = calculateRawValidMoves(q, r, piece);

    // after generating canidate moves, check if they are valid
    if (checkSimulation) {
      for (var move in canidateMoves) {
        int endQ = move[0];
        int endR = move[1];
        if (simulatedMoveIsSafe(q, r, endQ, endR, piece)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = canidateMoves;
    }
    return realValidMoves;
  }

  // check if a move is safe
  bool simulatedMoveIsSafe(int q, int r, int endQ, int endR, ChessPiece piece) {
    // save current board state
    ChessPiece? originalDestinationPiece = board[endQ][endR];

    // if the piece is king, try new move
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // move king to new location
      if (piece.isWhite) {
        whiteKingPosition = [endQ, endR];
      } else {
        blackKingPosition = [endQ, endR];
      }
    }

    // simulate move
    board[endQ][endR] = piece;
    board[q][r] = null;

    // check if king is in check
    bool isInCheck = isKingInCheck(piece.isWhite);

    // undo move
    board[q][r] = piece;
    board[endQ][endR] = originalDestinationPiece;

    // if the piece was king, undo move
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // if king is in check, move is not safe
    return !isInCheck;
  }

  // move the piece to the new location
  void movePiece(int q, int r) {
    // if new spot is occupied with enemy piece, capture it
    if (board[q][r] != null) {
      //add to appropriate list
      if (board[q][r]!.isWhite) {
        whiteCaptured.add(board[q][r]!);
      } else {
        blackCaptured.add(board[q][r]!);
      }
    }

    // move piece and clear the old location
    board[q][r] = selectedPiece;
    board[selectedCoordinates!.q + 5][selectedCoordinates!.r + 5] = null;

    // check if king is in check
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // check for king
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [q, r];
      } else {
        blackKingPosition = [q, r];
      }
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedCoordinates = null;
      validMoves = [];
    });

    // check for checkmate
    if (isCheckmate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Checkmate!'),
                actions: [
                  // play game again
                  TextButton(
                      onPressed: () {
                        resetGame();
                      },
                      child: const Text('Play Again')),
                ],
              ));
    }

    // change turn
    isWhiteTurn = !isWhiteTurn;
  }

  // check if king is in check
  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can capture the king
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        // skip empty and same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j]!, false);

        // check if any of the valid moves is the king's position
        for (var move in pieceValidMoves) {
          if (move[0] == kingPosition[0] && move[1] == kingPosition[1]) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // check if the king is in checkmate
  bool isCheckmate(bool isWhiteKing) {
    // check if king is in check
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    //check if there is a legal move
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        // skip empty and same color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j]!, false);

        // if piece has no valid moves, its not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if there are no legal moves, checkmate
    return true;
  }

  // reset the game
  void resetGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    _initBoard();
    checkStatus = false;
    whiteKingPosition = [6, 9];
    blackKingPosition = [6, 0];
    isWhiteTurn = true;
    whiteCaptured.clear();
    blackCaptured.clear();
    isSelected = false;
    selectedCoordinates = null;
    selectedPiece = null;
    validMoves.clear();
    setState(() {});
  }

  // declare a variables
  ChessPiece? piece;
  ChessPiece? selectedPiece;
  Coordinates? selectedCoordinates;
  bool isSelected = false;
  bool isValidMove = false;
  bool isWhiteTurn = true;

  // position of the kings
  List<int> whiteKingPosition = [6, 9];
  List<int> blackKingPosition = [6, 0];
  bool checkStatus = false;

  // A list of valid moves for the selected piece
  // each move is represented by a list with 2 elements: q and r
  List<List<int>> validMoves = [];

  // A list of white pieces that have been captured
  List<ChessPiece> whiteCaptured = [];

  // A list of black pieces that have been captured
  List<ChessPiece> blackCaptured = [];

  // sized of captured rows
  double? capturedSize = 60;

  @override
  Widget build(BuildContext context) {
    // sort captured pieces by type
    whiteCaptured.sort((a, b) => a.type.index.compareTo(b.type.index));
    blackCaptured.sort((a, b) => a.type.index.compareTo(b.type.index));

    return Scaffold(
      backgroundColor: Colors.grey[500],
      body: Stack(children: [
        Center(
          child: HexagonGrid.flat(
            depth: 5,
            height: MediaQuery.of(context).size.height - capturedSize! * 2,
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
                    onTap: () {
                      pieceSelected(coordinates);
                    },
                    child: piece != null
                        ? Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              color:
                                  piece!.isWhite ? Colors.white : Colors.black,
                              piece!.imagePath,
                              fit: BoxFit.contain,
                            ),
                          )
                        : null,
                  ));
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: capturedSize,
            child: SingleChildScrollView(
              controller: ScrollController(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var piece in blackCaptured) Image.asset(piece.imagePath),
                  if (calculateWorth(blackCaptured, whiteCaptured) < 0)
                    Text(
                      "+${calculateWorth(blackCaptured, whiteCaptured) * -1}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.5)),
                    )
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: capturedSize,
            child: SingleChildScrollView(
              controller: ScrollController(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var piece in whiteCaptured)
                    Image.asset(
                      piece.imagePath,
                      color: Colors.white,
                    ),
                  if (calculateWorth(blackCaptured, whiteCaptured) > 0)
                    Text(
                      "+${calculateWorth(blackCaptured, whiteCaptured)}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.5)),
                    )
                ],
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.black.withOpacity(0.5),
                size: 60,
              ),
              onPressed: () {
                resetGame();
              },
            ))
      ]),
    );
  }
}
