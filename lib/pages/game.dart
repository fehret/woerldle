import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'dart:collection';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/models/customCard.dart';
import 'package:woerldle/models/guessColumn.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geojson/geojson.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/services.dart' show rootBundle;


class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  //-------------------------------------
  // Halte getätigte Guesses weiter oben,
  // sonst Fehler durch Seitenwechsel
  // (Sollte auch normal gehen,
  // aber bisher noch nicht geändert)
  //-------------------------------------
  List<Country> guesses = [];
  bool reGen = true;
  int toGuess = -1;

  @override
  State<GamePage> createState() => _GamePageState();
}

//-----------------------------------------------------------------
// AutomaticKeepAliveClientMixin sorgt für Speicherung des States
//  dann müssen wantKeepAlive und build anders überschrieben werden
//-----------------------------------------------------------------
class _GamePageState extends State<GamePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  //------------------------------
  // alle Variablen, die für die
  // Spielmechanik notwendig sind
  //------------------------------
  late Future<List<Country>> countries;
  late int toGuess;

  //------------------------------
  // Variablen für Autocompletion
  //------------------------------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  String? _selectedCountry;

  //------------------------------
  // App-weite Einstellungen
  //  Asynchronität beachten
  //------------------------------
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //------------------------------------
  // rootBundle läd aus gegebenen Assets
  //------------------------------------
  Future<String> loadCountryJson() async {
    return await rootBundle.loadString('assets/countries.json');
  }

  //-------------------------------
  // lädt Länder aus gegebener JSON
  //-------------------------------
  Future<List<Country>> loadCountries() async {
    String countryJson = await loadCountryJson();
    List rawCountries = List.from(jsonDecode(countryJson));

    //--------------------------------------------
    // führt für jeden Eintrag die
    // factory-Funktion aus um Objekte zu erhalten
    //--------------------------------------------
    List<Country> countries =
        rawCountries.map((e) => Country.fromJSON(e)).toList();
    return countries;
  }

  //-------------------------------------------
  // gibt für String passende Vorschläge zurück
  //-------------------------------------------
  static List<String> getSuggestions(String query, List<Country> toMatch) {
    List<String> matches = <String>[];
    matches.addAll(toMatch.map((e) => e.name));

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  testprint() {
    print(widget.reGen);
  }

  //------------------------------
  // wird immer bei Aufbau der
  // Seite aufgerufen, läd hier
  // die Länder
  //------------------------------
  @override
  void initState() {
    super.initState();
    countries = loadCountries();
    testprint();
  }

  @override
  Widget build(BuildContext context) {
    // bei AutomaticKeepAliveClientMixin nötig
    super.build(context);

    //------------------------------
    // Animiert Änderungen in der Seite
    //------------------------------
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      //------------------------------
      // wird genutzt, um asynchrone
      // Daten anzuzeigen, sobald
      // verfügar
      //------------------------------
      child: FutureBuilder(
        // key wird für AnimatedSwitcher genutzt
        //key: ValueKey<int>(widget.guesses.length),
        future: countries,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            //------------------------------
            // generiert Landesliste und
            // Map, die Namen mit Ländern
            // verbindet
            //------------------------------
            List<Country> countriesReceived = snapshot.data!;
            HashMap<String, Country> name2Country = HashMap.fromIterable(
                countriesReceived,
                key: (element) => element.name,
                value: (element) => element);

            if (widget.reGen) {
              widget.toGuess = Random().nextInt(countriesReceived.length);
              //------------------------------
              // setzt Einstellung auf false
              //------------------------------
              widget.reGen = false;
            }

            //--------------------------------
            // checkt auf Gewinn oder Verlust
            // gibt entsprechendes Layout aus
            // lose noch auf 2, sonst Probleme
            //--------------------------------
            if (widget.guesses.isNotEmpty &&
                widget.guesses.last == countriesReceived[widget.toGuess]) {
              return winPage(widget.guesses);
            } else if (widget.guesses.length > 4) {
              return losePage(
                  countriesReceived[widget.toGuess], widget.guesses);
            } else {
              //------------------------------
              // Rate-Seite des Spiels
              //------------------------------
              
              return Column(
                children: [
                  //------------------------------
                  // nur als Dev-Hilfe,
                  //  zeigt Lösung an
                  //------------------------------
                    //margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    //TODO: Whitespaces für die svg stimmen nicht
                    Card(
                      elevation: 5,
                      margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: SizedBox(
                        height: 150,
                        child: SvgPicture.asset(
                        "assets/svg/${countriesReceived[widget.toGuess].short.toLowerCase()}.svg",
                        color: Colors.red,
                        alignment: Alignment.center,
                        fit: BoxFit.scaleDown,
                        //height: 140,
                        ),
                      ),
                    ),
                  //------------------------------
                  // Eingabe mit Autocompletion
                  //------------------------------
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: <Widget>[
                          const Text('Welches Land wird dargestellt?'),
                          TypeAheadFormField(
                            //------------------------------
                            // vielleicht eigenes Keyboard?
                            //------------------------------
                            //hideKeyboard: true,
                            textFieldConfiguration: TextFieldConfiguration(
                              decoration:
                                  const InputDecoration(labelText: 'Land'),
                              controller: _typeAheadController,
                            ),
                            suggestionsCallback: (pattern) {
                              return getSuggestions(pattern, countriesReceived);
                            },
                            itemBuilder: (context, String suggestion) {
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            transitionBuilder:
                                (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (String suggestion) {
                              _typeAheadController.text = suggestion;
                            },
                            validator: (value) =>
                                value!.isEmpty ? 'Bitte wähle ein Land' : null,
                            onSaved: (value) => _selectedCountry = value,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          ElevatedButton(
                            child: const Text('Prüfen'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  widget.guesses
                                      .add(name2Country[_selectedCountry]!);
                                  _selectedCountry = "";
                                  _typeAheadController.text = "";
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  //------------------------------
                  // bei getätigten Versuchen,
                  // diese zeichnen, ansonsten
                  // Text-Widget
                  //------------------------------
                  guessColumn(widget.guesses, countriesReceived[widget.toGuess], false),
                  //------------------------------
                  // Füllt Screen größtmöglich aus
                  //------------------------------
                  //const Spacer(),
                 ],
              );
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  //-----------------------------------
  // gibt Gewinnseite als Widget zurück
  //-----------------------------------
  Widget winPage(List<Country> guesses) {
    Country result = guesses.last;
    return Column(
      children: [
        const SizedBox(
          height: 20.0,
        ),
        const Text(
          "Korrekt!",
          style: TextStyle(color: Colors.lightGreen, fontSize: 40.0),
        ),
        const Spacer(),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on), //&Text(angle.toString()),
            title: Text(result.name),
          ),
        ),
        const Spacer(),
        guessColumn(guesses, result, true),
        const Spacer(),
        Row(
          children: [
            const SizedBox(
              width: 20.0,
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Transform(
                      alignment: Alignment.center,
                      child: const Icon(Icons.reply),
                      transform: Matrix4.rotationY(pi),
                    )),
                const Text("Share"),
              ],
            ),
            const Spacer(),
            //const SizedBox.expand(),
            Row(
              children: [
                const Text("Nächste Runde"),
                IconButton(
                    onPressed: () {
                      setState(() {
                        widget.toGuess = -1;
                        guesses.clear();
                        widget.reGen = true;
                      });
                    },
                    icon: const Icon(Icons.play_circle_filled))
              ],
            ),
          ],
        )
      ],
    );
  }

  //-----------------------------------
  // gitb Verlust als Widget zurück
  //-----------------------------------
  Widget losePage(Country result, List<Country> guesses) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: const Text(
          "Leider falsch!",
          style: TextStyle(color: Colors.red, fontSize: 40.0),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(result.name),
          ),
        ),
        guessColumn(guesses, result, false),
        Row(
          children: [
            const SizedBox(
              width: 20.0,
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Transform(
                      alignment: Alignment.center,
                      child: const Icon(Icons.reply),
                      transform: Matrix4.rotationY(pi),
                    )),
                const Text("Share"),
              ],
            ),
            const Spacer(),
            //const SizedBox.expand(),
            Row(
              children: [
                const Text("Nochmal spielen"),
                IconButton(
                    onPressed: () {
                      setState(() {
                        widget.toGuess = -1;
                        guesses.clear();
                        widget.reGen = true;
                      });
                    },
                    icon: const Icon(Icons.play_circle_filled))
              ],
            ),
          ],
        )
      ],
    );
  }
}
