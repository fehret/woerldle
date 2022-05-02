import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:country_codes/country_codes.dart';

Future<String?> countryCode() async {
  await CountryCodes.init();

  final Locale? deviceLocale = CountryCodes.getDeviceLocale();
  return deviceLocale?.languageCode;
}

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
  num area;

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

    String? acc3;

    acc3Conv() async {
      acc3 = await countryCode();

      switch(acc3) {
        case "DE":
          acc3 = "deu";
          break;
        case "CS":
          acc3 = "ces";
          break;
        case "ET":
          acc3 = "est";
          break;
        case "FI":
          acc3 = "fin";
          break;
        case "FR":
          acc3 = "fra";
          break;
        case "HR":
          acc3 = "hrv";
          break;
        case "HU":
          acc3 = "hun";
          break;
        case "IT":
          acc3 = "ita";
          break;
        case "JA":
          acc3 = "jpn";
          break;
        case "KO":
          acc3 = "kor";
          break;
        case "NL":
          acc3 = "nld";
          break;
        case "FA":
          acc3 = "per";
          break;
        case "PL":
          acc3 = "pol";
          break;
        case "PT":
          acc3 = "por";
          break;
        case "RU":
          acc3 = "rus";
          break;
        case "SK":
          acc3 = "slk";
          break;
        case "SV":
          acc3 = "swe";
          break;
        case "ES":
          acc3 = "spa";
          break;
        case "UR":
          acc3 = "urd";
          break;
        case "ZH":
          acc3 = "zho";
          break;
      }
    }
    acc3Conv();

    return Country(
      json['translations']["deu"]['common'] as String,
      LatLng(coords[0].toDouble(), coords[1].toDouble()),
      json['cca2'].toLowerCase() as String,
      json['area'],
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
