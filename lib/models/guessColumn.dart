import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/models/customCard.dart';

Column guessColumn(List<Country> guesses, Country countryToGuess, bool win){
  if(win){
    guesses.removeLast();
  }
  return Column(
    children: guesses.map<Widget>((currCountry) {
      double angle = currCountry.getInitialBearing(
          countryToGuess.coords);
      
      int dir = (((angle+pi)/(pi/4)).abs() - 0.5).round();
      print("angle: " + angle.toString());
      print("dir: " + dir.toString());
      String direction = ["S","SW","W","NW","N","NE","E","SE"][dir];
      double distance = currCountry.getDistanceByCountry(
          countryToGuess);
    Widget arrow = 
      Transform.rotate(
        angle: angle,
        child: const Icon(Icons.arrow_upward),
      );
      int green;
      int red;
      if(10500 > distance){
        green = 255;
        red = (distance*255/10500).round();
      }else{
        green = ((10500/(distance+1))*510-255).round();
        red = 255;
      }
      Color disColor = Color.fromARGB(255, red, green, 0);
      return customCard(arrow, direction, disColor, currCountry, distance);
    }).toList(),
  );
}