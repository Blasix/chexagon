import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HexagonGrid.flat(
        color: Colors.grey,
        depth: 5,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        buildTile: (coordinates) {
          // set the color of the tile based on the coordinates
          Color? color;
          if (coordinates.q % 3 == 0) {
            if (coordinates.r % 3 == 0) {
              color = Colors.grey[600];
            } else if (coordinates.r % 3 == 1) {
              color = Colors.grey[800];
            } else {
              color = Colors.grey[300];
            }
          } else if (coordinates.q % 3 == 1) {
            if (coordinates.r % 3 == 0) {
              color = Colors.grey[300];
            } else if (coordinates.r % 3 == 1) {
              color = Colors.grey[600];
            } else {
              color = Colors.grey[800];
            }
          } else {
            if (coordinates.r % 3 == 0) {
              color = Colors.grey[800];
            } else if (coordinates.r % 3 == 1) {
              color = Colors.grey[300];
            } else {
              color = Colors.grey[600];
            }
          }
          // return a widget for the tile
          return HexagonWidgetBuilder(
            color: color,
            padding: 2.0,
            cornerRadius: 8.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${coordinates.x}, ${coordinates.y}, ${coordinates.z}'),
                Text('${coordinates.q}, ${coordinates.r}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
