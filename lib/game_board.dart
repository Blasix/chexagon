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
        buildTile: (coordinates) => HexagonWidgetBuilder(
          padding: 2.0,
          cornerRadius: 8.0,
          child: Text('${coordinates.q}, ${coordinates.r}'),
        ),
      ),
    );
  }
}
