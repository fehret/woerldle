import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:woerldle/models/country.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CountryMarker extends Marker {
  CountryMarker({required this.country, required container})
      : super(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          height: 40,
          width: 40,
          point: country.coords,
          builder: (BuildContext cty) => container,
        );

  final Country country;
}

class CountryPopup extends StatelessWidget {
  const CountryPopup({Key? key, required this.country}) : super(key: key);
  final Country country;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //TODO Der Gruppe kann man noch etwas hinzufügen
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth> {

              },
              children: <TableRow> [
                TableRow(
                  children: [Text("dddd")],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
