import 'package:flutter/material.dart';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/models/imageTheme.dart';


Card customCard(Widget arrow, String direction, Color disColor, Country currCountry, double distance){
  return Card(
    margin: const EdgeInsets.fromLTRB(10,3,10,3),
    child: ListTile(
      shape: RoundedRectangleBorder(
        //borderRadius: BorderRadius.circular(30), TODO: Will Ecken runder machen
      ),
      leading: 
        SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              arrow,
              Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                width: 30,
                child: Text(
                  direction,
                )
              )
            ]
          ),
        ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:[
          smallImage(currCountry, color : disColor, width : 30),
        ]
      ),
      trailing: Container(
        width: 70,
        alignment: Alignment.centerRight,
        child: Text(distance.round().toString() + "km"),
      ),
    ),
);
}