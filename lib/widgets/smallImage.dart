// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:woerldle/models/country.dart';
import 'package:flutter_svg/flutter_svg.dart';

Container smallImage(
  Country country,

  //optionale Parameter
  {
  Color? color,
  double? width,
  double height = 30,
  EdgeInsets margin = const EdgeInsets.fromLTRB(0, 0, 5, 0),
  String type = "flags",
}) {
  return Container(
    height: height,
    width: width,
    margin: margin,
    child: SvgPicture.asset(
      "assets/$type/${country.short.toLowerCase()}.svg",
      color: color,
      alignment: Alignment.center,
      fit: BoxFit.contain,
      height: height,
      width: width,
    ),
  );
}
