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
      
      int dir = (((angle+(15/16)*pi)/(pi/4)).abs()).round();
      String direction = ["S","SW","W","NW","N","NE","E","SE","S"][dir];
      double distance = currCountry.getDistanceByCountry(countryToGuess);
    Widget arrow = 
      Transform.rotate(
        angle: angle,
        child: const Icon(Icons.arrow_upward),
      );
      int green;
      int red;
      if(5250 > distance){
        green = 255;
        red = (distance*255/5250).round();
      }else if(15500 > distance){
        green = ((10500/(distance+1))*510-340).round();
        red = 255;
      }else{
        green = 0;
        red = 255;
      }
      Color disColor = Color.fromARGB(255, red, green, 0);
      return customCard(arrow, direction, disColor, currCountry, distance);
    }).toList(),
  );
}