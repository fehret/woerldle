import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:latlong2/latlong.dart';
import 'dart:collection';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/models/guessColumn.dart';
import 'package:woerldle/models/countryPopup.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

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
      fit: BoxFit.scaleDown,
    ),
  );
}
