// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/widgets/customCard.dart';

Column guessColumn(
    List<Country> guesses, Country countryToGuess, bool win, int diff) {
  if (win) {
    guesses.removeLast();
  }
  return Column(
    children: guesses.map<Widget>((currCountry) {
      double angle;
      double distance;
      int dir;
      String direction;
      if (diff < 2) {
        angle = currCountry.mapDirection(countryToGuess.coords);
        distance = currCountry.getDistanceByCountry(countryToGuess);
        dir = (((angle - (1 / 16) * pi) / (pi / 4)).abs()).round();
        //dir = 0;
      } else {
        angle = currCountry.getInitialBearing(countryToGuess.coords);
        distance = currCountry.getDistanceByCountry(countryToGuess);
        dir = (((angle - (1 / 16) * pi) / (pi / 4)).abs()).round();
      }

      direction = ["S", "SW", "W", "NW", "N", "NE", "E", "SE", "S"][dir];

      Widget arrow = Transform.rotate(
        angle: angle,
        child: const Icon(Icons.arrow_upward),
      );
      int green;
      int red;
      if (5250 > distance) {
        green = 255;
        red = (distance * 255 / 5250).round();
      } else if (15500 > distance) {
        green = ((10500 / (distance + 1)) * 510 - 340).round();
        red = 255;
      } else {
        green = 0;
        red = 255;
      }
      Color disColor = Color.fromARGB(255, red, green, 0);

      if (diff == 1) {
        return customCard(currCountry,
            disColor: disColor,
            distance: distance,
            arrow: arrow,
            direction: direction);
      } else if (diff == 2) {
        return customCard(currCountry, disColor: disColor, distance: distance);
      } else {
        return customCard(currCountry);
      }
    }).toList(),
  );
}
