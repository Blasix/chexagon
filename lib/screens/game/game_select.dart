import 'package:chexagon/components/piece.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/game.dart';
import '../../components/user.dart';
import '../../consts/colors.dart';
import '../../helper/color_helper.dart';
import '../../services/game_service.dart';
import '../../services/user_service.dart';
import '../../widgets/account.dart';
import '../../widgets/game.dart';

final toggleButtonsSelectionProvider = Provider((ref) {
  return List.generate(3, (_) => false);
});

class GameSelect extends HookConsumerWidget {
  const GameSelect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesListProvider = ref.watch(gamesProvider);
    List<OnlineGameModel> gamesList;
    switch (gamesListProvider) {
      case AsyncData(:final value):
        gamesList = value;
      case AsyncError(:final error):
        print(error);
        gamesList = [];
      default:
        gamesList = [];
    }

    final currentUserProvider = ref.watch(userProvider);
    UserModel? currentUser;
    switch (currentUserProvider) {
      case AsyncData(:final value):
        currentUser = value;
      case AsyncError(:final error):
        print(error);
        currentUser = null;
      default:
        currentUser = null;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  //TODO: add ability to change profile picture
                  //for picture: https://github.com/Blasix/group_planner_app/blob/master/lib/screens/user.dart
                  onTap: () {
                    showAccountDialog(context, currentUser!);
                  },
                  child: const CircleAvatar(
                    radius: 30,
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Create a game',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: 400,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.go('/game:local');
                                },
                                child: const Text('Local 1v1'),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  showGameCreationDialog(context, currentUser!);
                                },
                                child: const Text('Multiplayer'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (gamesList.isNotEmpty) const SizedBox(height: 20),
                      if (gamesList.isNotEmpty)
                        const Text(
                          'Select a game',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      if (gamesList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          width: 400,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // TODO: make pieces on board visible
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: gamesList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) {
                                bool? shouldFlip;
                                bool doesUserHaveTurn;
                                if (gamesList[index].player1 ==
                                    FirebaseAuth.instance.currentUser!.uid) {
                                  doesUserHaveTurn =
                                      !gamesList[index].isWhiteTurn;
                                  shouldFlip = !gamesList[index].isPlayer1White;
                                } else {
                                  doesUserHaveTurn =
                                      gamesList[index].isWhiteTurn;
                                  shouldFlip = gamesList[index].isPlayer1White;
                                }
                                return SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      context
                                          .go('/game:${gamesList[index].id}');
                                    },
                                    child: Stack(
                                      children: [
                                        HexagonGrid.flat(
                                          depth: 5,
                                          buildTile: (coordinates) {
                                            // flip board if needed
                                            if (shouldFlip == true) {
                                              coordinates = Coordinates.axial(
                                                  -coordinates.q,
                                                  -coordinates.r);
                                            }
                                            // get piece
                                            final ChessPiece? piece =
                                                gamesList[index].board[
                                                        5 + coordinates.q]
                                                    [5 + coordinates.r];
                                            // get color
                                            final Color? color =
                                                whatColor(coordinates);

                                            // return a widget for the tile
                                            return HexagonWidgetBuilder(
                                              elevation: 1,
                                              color: color,
                                              padding: 0.8,
                                              cornerRadius: 1.0,
                                              child: piece != null
                                                  ? piece.type ==
                                                          ChessPieceType
                                                              .enPassant
                                                      ? null
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.8),
                                                          child: Image.asset(
                                                            color: piece.isWhite
                                                                ? Colors.white
                                                                : Colors.black,
                                                            piece.imagePath,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        )
                                                  : null,
                                            );
                                          },
                                        ),
                                        Visibility(
                                          visible: doesUserHaveTurn,
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.red,
                                                    width: 4,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: const Icon(
                                                  FontAwesomeIcons.exclamation,
                                                  color: Colors.red,
                                                  size: 28,
                                                )),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
