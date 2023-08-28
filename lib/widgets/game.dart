import 'dart:math';

import 'package:chexagon/helper/message_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/user.dart';
import '../helper/board_helper.dart';

// TODO make the gui acually update when any of the buttons are pressed

void showGameCreationDialog(
    BuildContext context, UserModel currentUser, bool isLocal) {
  late bool isPlayer1White;
  final List<bool> toggleButtonsSelection = List.generate(3, (_) => false);
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
            content: ToggleButtons(
              isSelected: toggleButtonsSelection,
              onPressed: (index) {
                // only one button is allowed to be selected
                // if the first one is true set isPlayer1White to true
                // if the second one is true set isPlayer1White to false
                // if the third one is true set isPlayer1White to Random().nextBool()
                if (index == 0) {
                  isPlayer1White = true;
                  toggleButtonsSelection[0] = true;
                  toggleButtonsSelection[1] = false;
                  toggleButtonsSelection[2] = false;
                } else if (index == 1) {
                  isPlayer1White = false;
                  toggleButtonsSelection[0] = false;
                  toggleButtonsSelection[1] = true;
                  toggleButtonsSelection[2] = false;
                } else {
                  isPlayer1White = Random().nextBool();
                  toggleButtonsSelection[0] = false;
                  toggleButtonsSelection[1] = false;
                  toggleButtonsSelection[2] = true;
                }
              },
              children: const [
                Text('You'),
                Text('Opponent'),
                Text('Random'),
              ],
            ),
            title: const Text('Who should be white?'),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    // check if the user selected an option
                    if (toggleButtonsSelection[0] == false &&
                        toggleButtonsSelection[1] == false &&
                        toggleButtonsSelection[2] == false) {
                      showErrorSnackbar(context, 'Please select an option.');
                      return;
                    }
                    isLocal
                        ? context.go('/game:local')
                        : FirebaseFirestore.instance.collection('games').add({
                            'player1': currentUser.id,
                            'player2': '',
                            'isPlayer1White': isPlayer1White,
                            'startedAt': DateTime.now(),
                            'board': convertBoardToListOfMaps(initBoard()),
                            'isWhiteTurn': true,
                            'whiteCaptured': [],
                            'blackCaptured': [],
                          }).then((value) {
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                            context.go('/game:${value.id}');
                          });
                  },
                  child: const Text('Continue')),
            ],
          ));
}
