import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woerldle/models/country.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Future<List<Country>> countries;

  Future<String> loadCountryJson() async {
    return await rootBundle.loadString('assets/countries.json');
  }

  Future<List<Country>> loadCountries() async {
    String countryJson = await loadCountryJson();
    List raw_countries = List.from(jsonDecode(countryJson));

    List<Country> countries =
        raw_countries.map((e) => Country.fromJSON(e)).toList();
    return countries;
  }

  @override
  void initState() {
    super.initState();
    countries = loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: countries,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (e) => Card(child: ListTile(title: Text(e.toString()))))
                .toList(),
            padding: EdgeInsets.all(10),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
