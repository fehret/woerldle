import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class CountryPainter extends CustomPainter {

  final polygons = <Polygon>[];
  Color _color = Colors.black;

  CountryPainter(String geojsonFile, Color color) {
    
    final data = parseJsonFromAssets(geojsonFile);
    this._color = color;
  }

  @override
  void paint(Canvas canvas, Size size){
    
    Paint paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    
    Path path = new Path.from();

    path.addPolygon(size.width,size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Future<Map<String, dynamic>> parseJsonFromAssets(String geojsonFile) async {
    return rootBundle.loadString('assets/countries/${geojsonFile.toLowerCase()}.json')
        .then((jsonStr) => jsonDecode(jsonStr)["geometry"]);
  }
/*
  Future<void> processData() async {
    final geojson = GeoJson();
    geojson.processedMultiPolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);
        for (final serie in polygon.geoSeries) {
          if (serie.geoPoints != null) {
            geoSerie.geoPoints?.addAll(serie.geoPoints!);
          }
        }
        final color =
            Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
                .withOpacity(0.3);
        final poly = Polygon(
            points: geoSerie.toLatLng(ignoreErrors: true), color: color);
        setState(() => polygons.add(poly));
      }
    });

  Future<void> parseAndDrawAssets(String geojsonFile) async {
    final geo = GeoJson();
    
    geo.processedLines.listen((GeoJsonLine line) {
      /// when a line is parsed add it to the map right away
      setState(() => lines.add(Polyline(
          strokeWidth: 2.0, color: Colors.blue, points: line.geoSerie!.toLatLng())));
    });

    geo.endSignal.listen((_) => geo.dispose());
    final data = await rootBundle
        .loadString('assets/countries/${geojsonFile.toLowerCase()}.json');
    await geo.parse(data, verbose: true);
  }
}
*/