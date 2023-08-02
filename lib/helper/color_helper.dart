import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

Color? white = Colors.grey[400];
Color? grey = Colors.grey[600];
Color? black = Colors.grey[800];

Color? whatColor(Coordinates coordinates) {
  if (coordinates.q % 3 == 0) {
    if (coordinates.r % 3 == 0) {
      return grey;
    } else if (coordinates.r % 3 == 1) {
      return black;
    } else {
      return white;
    }
  } else if (coordinates.q % 3 == 1) {
    if (coordinates.r % 3 == 0) {
      return white;
    } else if (coordinates.r % 3 == 1) {
      return grey;
    } else {
      return black;
    }
  } else {
    if (coordinates.r % 3 == 0) {
      return black;
    } else if (coordinates.r % 3 == 1) {
      return white;
    } else {
      return grey;
    }
  }
}
