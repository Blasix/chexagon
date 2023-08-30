import 'package:chexagon/components/user.dart';
import 'package:chexagon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../consts/colors.dart';
import '../../helper/color_helper.dart';
import '../../widgets/account.dart';
import '../../widgets/game.dart';

final toggleButtonsSelectionProvider = Provider((ref) {
  return List.generate(3, (_) => false);
});

class GameSelect extends HookWidget {
  const GameSelect({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? currentUser;
    // TODO: get games from firebase
    // replace this with a list games (List<GameModel>)
    List<String> currentGames = [
      '60f047ea-3cbc-54b4-a0c9-eb80955c1927',
      '9a2f1600-aa2e-5aef-98d3-27684303f7c0',
      'b72c122d-b421-5163-9fea-e4e03dd19afb'
    ];

    Future<void> loadCurrentUser() async {
      final UserService userService = UserService();
      final UserModel? currentUser0 = await userService.getCurrentUser();
      currentUser = currentUser0;
    }

    useEffect(
      () {
        loadCurrentUser();
        return null;
      },
      [],
    );

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
                  //TODO: add ability to change profile
                  //for picture: https://github.com/Blasix/group_planner_app/blob/master/lib/screens/user.dart
                  onTap: () {
                    showAccountDialog(context, currentUser!);
                  },
                  child: const CircleAvatar(),
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
                      if (currentGames.isNotEmpty) const SizedBox(height: 20),
                      if (currentGames.isNotEmpty)
                        const Text(
                          'Select a game',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      if (currentGames.isNotEmpty)
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
                              itemCount: currentGames.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) {
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
                                    onPressed: () {},
                                    child: HexagonGrid.flat(
                                      depth: 5,
                                      buildTile: (coordinates) {
                                        Color? color = whatColor(coordinates);

                                        // return a widget for the tile
                                        return HexagonWidgetBuilder(
                                          color: color,
                                          padding: 0.8,
                                          cornerRadius: 1.0,
                                        );
                                      },
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
