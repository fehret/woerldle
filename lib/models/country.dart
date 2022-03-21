import 'package:latlong2/latlong.dart';

class Country {
  String name;
  LatLng coords;

  Country(this.name, this.coords);

  factory Country.fromJSON(dynamic json) {
    List coords = List.from(json['latlng']);

    return Country(json['name']['common'] as String,
        LatLng(coords[0].toDouble(), coords[1].toDouble()));
  }

  double getDistanceFromCoords(LatLng other) {
    return Distance().as(LengthUnit.Kilometer, coords, other);
  }

  double getDistanceFromCountry(Country other) {
    return Distance().as(LengthUnit.Kilometer, coords, other.coords);
  }

  @override
  String toString() {
    return '{ ${this.name}, ${this.coords}}';
  }
}
