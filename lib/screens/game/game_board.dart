import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:chexagon/helper/message_helper.dart';
import 'package:chexagon/widgets/share.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/game.dart';
import '../../components/piece.dart';
import '../../consts/colors.dart';
import '../../consts/images.dart';
import '../../helper/board_helper.dart';
import '../../helper/color_helper.dart';
import '../../helper/piece_helper.dart';
import '../../services/game_service.dart';

// TODO: make captured lists automagicly calcalated based on board
// TODO: checkmate not working

// multiplayer
// TODO: for now it does everything twice so once on divice then upload to firebase maby optimize later
// TODO: add posibility to invite other people

final _joinableProvider = StateProvider((ref) => false);

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key, required this.gameID});
  final String gameID;

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  // A 2-dimensional list representing the chessboard,
  // with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  @override
  void initState() {
    super.initState();
    board = initBoard();
  }

  // user selects a piece
  void pieceSelected(Coordinates coordinates, bool isPlayerWhite) {
    if (widget.gameID.substring(1) != 'local') {
      if (isPlayerWhite != isWhiteTurn) {
        return;
      }
    }
    setState(() {
      final int q = 5 + coordinates.q;
      final int r = 5 + coordinates.r;
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
    final List<List<int>> canidateMoves = [];

    if (piece == null) {
      return canidateMoves;
    }

    // different moves for different color
    final int direction = piece.isWhite ? -1 : 1;

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

      case ChessPieceType.rook:
        final directions = [
          [0, -1],
          [1, -1],
          [1, 0],
          [0, 1],
          [-1, 1],
          [-1, 0],
        ];
        for (final directions in directions) {
          var i = 1;
          while (true) {
            final q2 = q + directions[0] * i;
            final r2 = r + directions[1] * i;
            if (!isInBoard(q2, r2)) {
              break;
            }
            if (board[q2][r2] != null) {
              if (board[q2][r2]!.isWhite != piece.isWhite) {
                canidateMoves.add([q2, r2]); // Capture
              }
              if (board[q2][r2]!.type != ChessPieceType.enPassant) {
                break;
              }
            }
            canidateMoves.add([q2, r2]);
            i++;
          }
        }
      case ChessPieceType.knight:
        final directions = [
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
        for (final directions in directions) {
          final q2 = q + directions[0];
          final r2 = r + directions[1];
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
      case ChessPieceType.bishop:
        final directions = [
          [1, -2],
          [2, -1],
          [1, 1],
          [-1, 2],
          [-2, 1],
          [-1, -1],
        ];
        for (final directions in directions) {
          var i = 1;
          while (true) {
            final q2 = q + directions[0] * i;
            final r2 = r + directions[1] * i;
            if (!isInBoard(q2, r2)) {
              break;
            }
            if (board[q2][r2] != null) {
              if (board[q2][r2]!.isWhite != piece.isWhite) {
                canidateMoves.add([q2, r2]); // Capture
              }
              if (board[q2][r2]!.type != ChessPieceType.enPassant) {
                break;
              }
            }
            canidateMoves.add([q2, r2]);
            i++;
          }
        }
      case ChessPieceType.king:
        final directions = [
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
        for (final directions in directions) {
          final q2 = q + directions[0];
          final r2 = r + directions[1];
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

      case ChessPieceType.queen:
        final directions = [
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
        for (final directions in directions) {
          var i = 1;
          while (true) {
            final q2 = q + directions[0] * i;
            final r2 = r + directions[1] * i;
            if (!isInBoard(q2, r2)) {
              break;
            }
            if (board[q2][r2] != null) {
              if (board[q2][r2]!.isWhite != piece.isWhite) {
                canidateMoves.add([q2, r2]); // Capture
              }
              if (board[q2][r2]!.type != ChessPieceType.enPassant) {
                break;
              }
            }
            canidateMoves.add([q2, r2]);
            i++;
          }
        }
      case ChessPieceType.enPassant:
        break;
    }

    return canidateMoves;
  }

  // calculate the real valid moves for a piece
  List<List<int>> calculateRealValidMoves(
      int q, int r, ChessPiece piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    final List<List<int>> canidateMoves = calculateRawValidMoves(q, r, piece);

    // after generating canidate moves, check if they are valid
    if (checkSimulation) {
      for (final move in canidateMoves) {
        final int endQ = move[0];
        final int endR = move[1];
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
    final ChessPiece? originalDestinationPiece = board[endQ][endR];

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
    final bool isInCheck = isKingInCheck(piece.isWhite);

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
    final int qStart = selectedCoordinates!.q + 5;
    final int rStart = selectedCoordinates!.r + 5;
    // if new spot is occupied with enemy piece, capture it
    if (board[q][r] != null) {
      if (board[q][r]!.type == ChessPieceType.enPassant) {
        if (selectedPiece!.type == ChessPieceType.pawn) {
          //add to appropriate list
          if (selectedPiece!.isWhite) {
            blackCaptured.add(board[q][r + 1]!);
            board[q][r + 1] = null;
          } else {
            whiteCaptured.add(board[q][r - 1]!);
            board[q][r - 1] = null;
          }
        }
      } else {
        //add to appropriate list
        if (board[q][r]!.isWhite) {
          whiteCaptured.add(board[q][r]!);
        } else {
          blackCaptured.add(board[q][r]!);
        }
      }
    }

    // search board for all "enPassant pieces" and remove them
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        if (board[i][j] != null) {
          if (board[i][j]!.type == ChessPieceType.enPassant) {
            board[i][j] = null;
          }
        }
      }
    }

    // check for pawn
    if (selectedPiece!.type == ChessPieceType.pawn) {
      // check if pawn is at end of board
      for (int i = 1; i <= 5; i++) {
        if (selectedPiece!.isWhite) {
          if (q == (i + 5) && r == 0 ||
              q == (i - 1) && r == (6 - i) ||
              q == 5 && r == 0) {
            promotePawn(true, q, r, qStart, rStart);
            if (widget.gameID.substring(1) != 'local') {
              return;
            } else {
              break;
            }
          }
        } else {
          if (q == (i + 5) && r == (10 - i) ||
              q == (i - 1) && r == 10 ||
              q == 5 && r == 10) {
            promotePawn(false, q, r, qStart, rStart);
            if (widget.gameID.substring(1) != 'local') {
              return;
            } else {
              break;
            }
          }
        }
      }

      // check if pawn is moving 2 spaces
      if (selectedPiece!.isWhite) {
        if (rStart - 2 == r) {
          // add en passant piece
          board[qStart][rStart - 1] = ChessPiece(
            imagePath: '',
            isWhite: true,
            type: ChessPieceType.enPassant,
          );
        }
      } else {
        if (rStart + 2 == r) {
          // add en passant piece
          board[qStart][rStart + 1] = ChessPiece(
            imagePath: '',
            isWhite: false,
            type: ChessPieceType.enPassant,
          );
        }
      }

      // move piece and clear the old location
      board[q][r] = selectedPiece;
      board[qStart][rStart] = null;
    } else {
      // move piece and clear the old location
      board[q][r] = selectedPiece;
      board[qStart][rStart] = null;
    }

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
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Checkmate!'),
          actions: [
            // play game again
            TextButton(
              onPressed: () {
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }

    // if game is multiplayer, upload to firebase
    if (widget.gameID.substring(1) != 'local') {
      FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameID.substring(1))
          .update({
        'board': convertBoardToListOfMaps(board),
        'isWhiteTurn': !isWhiteTurn,
        'whiteCaptured': convertCapturedListToListOfMaps(whiteCaptured),
        'blackCaptured': convertCapturedListToListOfMaps(blackCaptured),
      });
    } else {
      // if game is local, switch turns
      setState(() {
        isWhiteTurn = !isWhiteTurn;
      });
    }
  }

  // check if king is in check
  bool isKingInCheck(bool isWhiteKing) {
    final List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can capture the king
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        // skip empty and same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        final List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j]!, false);

        // check if any of the valid moves is the king's position
        for (final move in pieceValidMoves) {
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

        final List<List<int>> pieceValidMoves =
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
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    board = initBoard();
    checkStatus = false;
    isWhiteTurn = true;
    whiteCaptured.clear();
    blackCaptured.clear();
    isSelected = false;
    selectedCoordinates = null;
    selectedPiece = null;
    validMoves.clear();
    setState(() {});
  }

  // pormote pawn
  void promotePawn(bool isWhite, int q, int r, int qStart, int rStart) {
    void addToCaptured(ChessPieceType type) {
      if (isWhite) {
        whiteCaptured.add(
          ChessPiece(
              type: ChessPieceType.pawn,
              isWhite: true,
              imagePath: pieceImagePaths[ChessPieceType.pawn]!),
        );
        blackCaptured.add(
          ChessPiece(type: type, isWhite: false, imagePath: ''),
        );
      } else {
        blackCaptured.add(
          ChessPiece(
              type: ChessPieceType.pawn,
              isWhite: false,
              imagePath: pieceImagePaths[ChessPieceType.pawn]!),
        );
        whiteCaptured.add(
          ChessPiece(type: type, isWhite: true, imagePath: ''),
        );
      }
      // return;
    }

    void completePromotionOnline() {
      if (widget.gameID.substring(1) != 'local') {
        // move piece and clear the old location
        board[qStart][rStart] = null;

        // check if king is in check
        if (isKingInCheck(!isWhiteTurn)) {
          checkStatus = true;
        } else {
          checkStatus = false;
        }

        // check for checkmate
        if (isCheckmate(!isWhiteTurn)) {
          showDialog(
              barrierDismissible: false,
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

        // upload to firebase
        FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameID.substring(1))
            .update({
          'board': convertBoardToListOfMaps(board),
          'isWhiteTurn': !isWhiteTurn,
          'whiteCaptured': convertCapturedListToListOfMaps(whiteCaptured),
          'blackCaptured': convertCapturedListToListOfMaps(blackCaptured),
        });
      }
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Promote!'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          board[q][r] = ChessPiece(
                              type: ChessPieceType.queen,
                              isWhite: isWhite,
                              imagePath:
                                  pieceImagePaths[ChessPieceType.queen]!);
                        });
                        addToCaptured(ChessPieceType.queen);
                        completePromotionOnline();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Queen')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          board[q][r] = ChessPiece(
                              type: ChessPieceType.rook,
                              isWhite: isWhite,
                              imagePath: pieceImagePaths[ChessPieceType.rook]!);
                        });
                        addToCaptured(ChessPieceType.rook);
                        completePromotionOnline();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Rook')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          board[q][r] = ChessPiece(
                              type: ChessPieceType.bishop,
                              isWhite: isWhite,
                              imagePath:
                                  pieceImagePaths[ChessPieceType.bishop]!);
                        });
                        addToCaptured(ChessPieceType.bishop);
                        completePromotionOnline();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Bishop')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          board[q][r] = ChessPiece(
                              type: ChessPieceType.knight,
                              isWhite: isWhite,
                              imagePath:
                                  pieceImagePaths[ChessPieceType.knight]!);
                        });
                        addToCaptured(ChessPieceType.knight);
                        completePromotionOnline();
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Knight')),
                ],
              ),
            ));
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

  Widget buildCapturedRow(List<ChessPiece> capturedPieces) {
    // widget.isLocal
    final List<List<ChessPiece>> rows = [];
    for (final piece in capturedPieces) {
      bool addedToRow = false;
      for (final List<ChessPiece> row in rows) {
        if (row.isNotEmpty && row.first.type == piece.type) {
          row.add(piece);
          addedToRow = true;
          break;
        }
      }
      if (!addedToRow && piece.imagePath != '') {
        rows.add([piece]);
      }
    }
    return RowSuper(
      innerDistance: -10,
      children: [
        for (final list in rows)
          RowSuper(
            innerDistance: -40,
            children: [
              for (final piece in list)
                SimpleShadow(
                  color: piece.isWhite ? Colors.black : Colors.white,
                  offset: Offset.zero,
                  child: Image.asset(
                    piece.imagePath,
                    color: piece.isWhite ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // sized of captured rows
  double? capturedSize = 60;

  // should the board be flipped
  bool? shouldFlip;

  @override
  Widget build(BuildContext context) {
    // sort captured pieces by type
    whiteCaptured.sort((a, b) => a.type.index.compareTo(b.type.index));
    blackCaptured.sort((a, b) => a.type.index.compareTo(b.type.index));

    // sized of captured rows
    const double capturedSize = 60;
    // available height
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    // FIREBASE
    final String gameID = widget.gameID.substring(1);
    bool playerNotInGame = false;
    final StateController<bool> joinable =
        ref.watch(_joinableProvider.notifier);
    if (gameID != 'local') {
      // get current games
      final gamesListProvider = ref.watch(gamesProvider);
      OnlineGameModel? currentGame;
      switch (gamesListProvider) {
        case AsyncData(:final value):
          // check if user is in the game
          if (!value.any((element) => element.id == gameID)) {
            playerNotInGame = true;
            // check if there exists a game with the given id
            FirebaseFirestore.instance
                .collection('games')
                .doc(gameID)
                .get()
                .then((value) {
              if (value.exists) {
                // check if player2 is an empty string
                if (value.data()!['player2'] == '') {
                  joinable.state = true;
                }
              }
            });
            break;
          }

          // get current game
          currentGame = value.firstWhere((element) => element.id == gameID);
          board = currentGame.board;
          blackCaptured = currentGame.blackCaptured;
          whiteCaptured = currentGame.whiteCaptured;
          isWhiteTurn = currentGame.isWhiteTurn;
          whiteKingPosition = getKingPosition(board, true);
          blackKingPosition = getKingPosition(board, false);
          if (currentGame.player1 == FirebaseAuth.instance.currentUser!.uid) {
            shouldFlip = !currentGame.isPlayer1White;
          } else {
            shouldFlip = currentGame.isPlayer1White;
          }
        case AsyncError(:final error):
          print(error);
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: playerNotInGame
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You are not in this game',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 20),
                  if (joinable.state)
                    ElevatedButton(
                      onPressed: () async {
                        // join the game as player 2
                        try {
                          await FirebaseFirestore.instance
                              .collection('games')
                              .doc(gameID)
                              .update({
                            'player2': FirebaseAuth.instance.currentUser!.uid,
                          });
                        } on FirebaseException catch (e) {
                          if (context.mounted) {
                            showErrorSnackbar(context, e.message);
                          }
                        }
                      },
                      child: const Text('Join the game'),
                    ),
                  if (joinable.state) const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: const Text('Go back'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Center(
                  child: HexagonGrid.flat(
                    depth: 5,
                    height: availableHeight - capturedSize * 2,
                    width: MediaQuery.of(context).size.width,
                    buildTile: (coordinates) {
                      // flip board if needed
                      if (shouldFlip == true) {
                        coordinates =
                            Coordinates.axial(-coordinates.q, -coordinates.r);
                      }
                      piece = board[5 + coordinates.q][5 + coordinates.r];
                      isSelected = selectedCoordinates == coordinates;
                      for (final position in validMoves) {
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
                              pieceSelected(coordinates, shouldFlip != true);
                            },
                            child: piece != null
                                ? piece!.type == ChessPieceType.enPassant
                                    ? null
                                    : Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Image.asset(
                                          color: piece!.isWhite
                                              ? Colors.white
                                              : Colors.black,
                                          piece!.imagePath,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                : null,
                          ));
                    },
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          height: capturedSize,
                          child: SingleChildScrollView(
                            controller: ScrollController(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildCapturedRow(blackCaptured),
                                if (calculateWorth(
                                        blackCaptured, whiteCaptured) <
                                    0)
                                  Text(
                                    '+${calculateWorth(blackCaptured, whiteCaptured) * -1}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
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
                                buildCapturedRow(whiteCaptured),
                                if (calculateWorth(
                                        blackCaptured, whiteCaptured) >
                                    0)
                                  Text(
                                    '+${calculateWorth(blackCaptured, whiteCaptured)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.rightFromBracket,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 60,
                                ),
                                onPressed: () {
                                  context.go('/');
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  gameID == 'local'
                                      ? FontAwesomeIcons.arrowsRotate
                                      : FontAwesomeIcons.userPlus,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 60,
                                ),
                                onPressed: () {
                                  if (gameID == 'local') {
                                    resetGame();
                                  } else {
                                    showShareDialog(
                                        context, Uri.base.toString());
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.github,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 60,
                                ),
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                      'https://github.com/Blasix/chexagon');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
