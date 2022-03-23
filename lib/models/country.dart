import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

//------------------------------
// Datenmodell für ein Land
//------------------------------
class Country {
  //------------------------------
  // Eigenschaften und Konstruktor
  //------------------------------
  String name;
  LatLng coords;

  Country(this.name, this.coords);

  //-------------------------------
  // ermöglicht Init aus JSON
  //  benötigt bereits decoded-JSON
  //-------------------------------
  factory Country.fromJSON(dynamic json) {
    List coords = List.from(json['latlng']);

    return Country(json['name']['common'] as String,
        LatLng(coords[0].toDouble(), coords[1].toDouble()));
  }

  //------------------------------
  // Distanzberechnung über Coords 
  // und anderes Land
  //------------------------------
  double getDistanceByCoords(LatLng other) {
    return Distance().as(LengthUnit.Kilometer, coords, other);
  }

  double getDistanceByCountry(Country other) {
    return Distance().as(LengthUnit.Kilometer, coords, other.coords);
  }

  //-----------------------------------
  // Funtkionen zur Richtungsberechnung
  //  Ergebnis in Rad,
  //  Icon-Drehungen benötigen auch Rad
  //-----------------------------------

  double toRadian(double input) {
    return input * pi / 180;
  }

  LatLng transformPoint(LatLng point) {
    return LatLng(toRadian(point.latitude), toRadian(point.longitude));
  }

  // starting from this country, which direction should be taken?
  double getInitialBearing(LatLng other) {
    LatLng transformedOther = transformPoint(other);
    LatLng transformedSelf = transformPoint(coords);

    double x = sin(transformedOther.longitude - transformedSelf.longitude) *
        cos(transformedOther.latitude);
    double y = cos(transformedSelf.latitude) * sin(transformedOther.latitude) -
        sin(transformedSelf.latitude) *
            cos(transformedOther.latitude) *
            cos(transformedOther.longitude - transformedSelf.longitude);
    return atan2(x, y);
  }

  @override
  String toString() {
    return '{ ${this.name}, ${this.coords}}';
  }

}
