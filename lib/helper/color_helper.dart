import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

import '../consts/colors.dart';

Color? whatColor(Coordinates coordinates) {
  if (coordinates.q % 3 == 0) {
    if (coordinates.r % 3 == 0) {
      return gameGrey;
    } else if (coordinates.r % 3 == 1) {
      return gameBlack;
    } else {
      return gameWhite;
    }
  } else if (coordinates.q % 3 == 1) {
    if (coordinates.r % 3 == 0) {
      return gameWhite;
    } else if (coordinates.r % 3 == 1) {
      return gameGrey;
    } else {
      return gameBlack;
    }
  } else {
    if (coordinates.r % 3 == 0) {
      return gameBlack;
    } else if (coordinates.r % 3 == 1) {
      return gameWhite;
    } else {
      return gameGrey;
    }
  }
}
