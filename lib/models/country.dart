import 'package:latlong2/latlong.dart';
import 'dart:math';

//------------------------------
// Datenmodell für ein Land
//------------------------------
class Country {
  //------------------------------
  // Eigenschaften und Konstruktor
  //------------------------------
  String name;
  String short;
  LatLng coords;
  //Coords mapCoords;
  double area;

  Country(
    this.name,
    this.coords,
    this.short,
    this.area,
  );

  //-------------------------------
  // ermöglicht Init aus JSON
  //  benötigt bereits decoded-JSON
  //-------------------------------
  factory Country.fromJSON(dynamic json) {
    List coords = List.from(json['latlng']);

    return Country(
      json['name']['common'] as String,
      LatLng(coords[0].toDouble(), coords[1].toDouble()),
      json['cca2'].toLowerCase() as String,
      json['area'].toDouble(),
      //mapProjection(LatLng(coords[0].toDouble(), coords[1].toDouble()))
    );
  }

  /*static Coords mapProjection(LatLng mapCoords) {
    double lat = mapCoords.latitude;
    double long = mapCoords.longitude;
    double mapWidth = 40075;
    double mapHeight = 10002 * 2;

    double x = (long + 180) * (mapWidth / 360);
    double latRad = lat * pi / 180;

    double mercN = log(tan((pi / 4) + (latRad / 2)));
    double y = (mapHeight / 2) - (mapWidth * mercN / (2 * pi));

    return Coords(x, y);
  }*/

  // not really useable
  double mapDistance(LatLng other) {
    return sqrt(pow((coords.latitude - other.latitude), 2) +
        pow((coords.longitude - other.longitude), 2));
  }

  double mapDirection(LatLng other) {
    double w = other.latitude - coords.latitude;
    double h = other.longitude - coords.longitude;

    double atanCalc = atan(h / w);
    if (w < 0 || h < 0) atanCalc += pi;
    if (w > 0 && h < 0) atanCalc -= pi;
    if (atanCalc < 0) atanCalc += 2 * pi;

    return (atanCalc % (2 * pi));
  }

  //------------------------------
  // Distanzberechnung über Coords
  // und anderes Land
  //------------------------------
  double getDistanceByCoords(LatLng other) {
    return const Distance().as(LengthUnit.Kilometer, coords, other);
  }

  double getDistanceByCountry(Country other) {
    return const Distance().as(LengthUnit.Kilometer, coords, other.coords);
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
    return '{ $name, $coords}';
  }
}
