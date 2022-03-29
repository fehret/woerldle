import 'package:flutter/material.dart';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/widgets/smallImage.dart';

Card customCard(Country currCountry,
    {Color disColor = Colors.black,
    double distance = 0,
    Widget arrow = const SizedBox(),
    String direction = ""}) {
  return Card(
    margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
    child: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      leading: SizedBox(
        width: 60,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          arrow,
          Container(
              margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              width: 30,
              child: Text(
                direction,
              ))
        ]),
      ),
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        smallImage(currCountry, color: disColor, width: 30, type: "borders"),
        Text(currCountry.name, style: TextStyle(color: disColor)),
      ]),
      trailing: Container(
        width: 70,
        alignment: Alignment.centerRight,
        child: distance == 0
            ? Text("")
            : Text(distance.round().toString() + " km"),
      ),
    ),
  );
}
