import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../widgets/account.dart';
import 'game_board.dart';

class GameSelect extends StatelessWidget {
  const GameSelect({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
                      showAccountDialog(context);
                    },
                    child: const CircleAvatar()),
              ),
            ),
            Center(
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
                                // Navigator.pushNamed(context, '/game');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GameBoard(
                                      isLocal: true,
                                    ),
                                  ),
                                );
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
                              onPressed: () {},
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
          ],
        ),
      ),
    );
  }
}
