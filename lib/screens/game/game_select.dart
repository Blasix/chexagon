import 'package:chexagon/components/user.dart';
import 'package:chexagon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../consts/colors.dart';
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
                                  showGameCreationDialog(
                                      context, currentUser!, true);
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
                                  showGameCreationDialog(
                                      context, currentUser!, false);
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
