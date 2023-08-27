import 'package:chexagon/components/user.dart';
import 'package:chexagon/helper/board_helper.dart';
import 'package:chexagon/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../components/piece.dart';
import '../../consts/colors.dart';
import '../../widgets/account.dart';

class GameSelect extends HookWidget {
  const GameSelect({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? currentUser;

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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Game Select',
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
                      child: SingleChildScrollView(
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
                                  FirebaseFirestore.instance
                                      .collection('games')
                                      .add({
                                    'player1': currentUser!.id,
                                    'player2': '',
                                    'startedAt': DateTime.now(),
                                    'board':
                                        convertBoardToListOfMaps(initBoard()),
                                    'isWhiteTurn': true,
                                    'whiteCaptured': [],
                                    'blackCaptured': [],
                                  }).then((value) =>
                                          context.go('/game:${value.id}'));
                                },
                                child: const Text('Multiplayer'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
