import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/user.dart';
import '../helper/board_helper.dart';

void showGameCreationDialog(BuildContext context, UserModel currentUser) {
  bool isPlayer1White = true;
  final List<bool> toggleButtonsSelection = <bool>[true, false, false];
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
            content: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Center(
                    child: ToggleButtons(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        minWidth: 80.0,
                      ),
                      isSelected: toggleButtonsSelection,
                      onPressed: (index) {
                        // only one button is allowed to be selected
                        // if the first one is true set isPlayer1White to true
                        // if the second one is true set isPlayer1White to false
                        // if the third one is true set isPlayer1White to Random().nextBool()
                        if (index == 0) {
                          setState(() {
                            isPlayer1White = true;
                          });
                        } else if (index == 1) {
                          setState(() {
                            isPlayer1White = false;
                          });
                        } else {
                          setState(() {
                            isPlayer1White = Random().nextBool();
                          });
                        }
                        for (int i = 0;
                            i < toggleButtonsSelection.length;
                            i++) {
                          toggleButtonsSelection[i] = i == index;
                        }
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('You'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Opponent'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Random'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            title: const Text('Who should start?'),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance.collection('games').add({
                      'player1': currentUser.id,
                      'player2': '',
                      'isPlayer1White': isPlayer1White,
                      'startedAt': DateTime.now(),
                      'board': convertBoardToListOfMaps(initBoard()),
                      'isWhiteTurn': true,
                      'whiteCaptured': [],
                      'blackCaptured': [],
                    }).then((value) {
                      FirebaseFirestore.instance
                          .collection('games')
                          .doc(value.id)
                          .update({
                        'id': value.id,
                      });
                      if (Navigator.canPop(context)) Navigator.pop(context);
                      context.go('/game:${value.id}');
                    });
                  },
                  child: const Text('Continue')),
            ],
          ));
}
