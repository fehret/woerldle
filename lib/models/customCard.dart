import 'package:flutter/material.dart';
import 'package:woerldle/models/country.dart';
import 'package:flutter_svg/flutter_svg.dart';

Card customCard(Widget arrow, String direction, Color disColor, Country currCountry, double distance){
  return Card(
    margin: const EdgeInsets.fromLTRB(10,3,10,3),
    child: ListTile(
      shape: RoundedRectangleBorder(
        //borderRadius: BorderRadius.circular(30), TODO: Will Ecken runder machen
      ),
      leading: 
        Container(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              arrow,
              Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                width: 20,
                child: Text(
                  direction,
                )
              )
            ]
          ),
        ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Container(
            alignment: Alignment.centerLeft,
            height: 30,
            width: 30,  
            margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: SvgPicture.asset(
            "assets/svg/${currCountry.short.toLowerCase()}.svg",
            color: disColor,
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            ),
          ),
          Container(
            width: 80,
            child: Text(
              currCountry.name,
              style: TextStyle(
                color: disColor,
              ),
            ),
          ),
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