import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'dart:collection';
import 'package:woerldle/models/country.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  //-------------------------------------
  // Halte getätigte Guesses weiter oben,
  // sonst Fehler durch Seitenwechsel
  // (Sollte auch normal gehen,
  // aber bisher noch nicht geändert)
  //-------------------------------------
  List<Country> guesses = [];

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
  int toGuess = 0;

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

  //------------------------------
  // wird immer bei Aufbau der
  // Seite aufgerufen, läd hier
  // die Länder
  //------------------------------
  @override
  void initState() {
    super.initState();
    countries = loadCountries();
  }

  //-------------------------------
  // lädt Preferences und versucht,
  // bool zu laden, wählt sonst std
  //-------------------------------
  Future<bool?> getGenerate() {
    return _prefs.then((value) => value.getBool('generateNew'));
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
        key: ValueKey<int>(widget.guesses.length),
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

            return FutureBuilder(
                //--------------------------------
                // fragt ab, ob neues Land gezogen
                // werden soll
                //--------------------------------
                future: getGenerate(),
                builder:
                    (BuildContext contextInner, AsyncSnapshot snapshotInner) {
                  if (snapshotInner.hasError) {
                    return Center(child: Text("Error: ${snapshotInner.error}"));
                  } else if (snapshotInner.hasData) {
                    //----------------------------------
                    // generiere neuen Index, wenn nötig
                    //----------------------------------
                    bool reGen = snapshotInner.data;
                    if (reGen) {
                      toGuess = Random().nextInt(countriesReceived.length);
                      //------------------------------
                      // setzt Einstellung auf false
                      //------------------------------
                      _prefs.then((SharedPreferences prefs) {
                        return prefs.setBool('generateNew', false);
                      });
                    }

                    //--------------------------------
                    // checkt auf Gewinn oder Verlust
                    // gibt entsprechendes Layout aus
                    // lose noch auf 2, sonst Probleme
                    //--------------------------------
                    if (widget.guesses.isNotEmpty &&
                        widget.guesses.last == countriesReceived[toGuess]) {
                      return winPage(widget.guesses);
                    } else if (widget.guesses.length > 2) {
                      return losePage(
                          countriesReceived[toGuess], widget.guesses);
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
                          Card(
                            child: ListTile(
                              title:
                                  Text(countriesReceived[toGuess].toString()),
                            ),
                          ),
                          //------------------------------
                          // beigetätigten Versuchen,
                          // diese zeichnen, ansonsten
                          // Text-Widget
                          //------------------------------
                          (widget.guesses.isNotEmpty)
                              ? Column(
                                  children: widget.guesses.map<Widget>((e) {
                                    double angle = e.getInitialBearing(
                                        countriesReceived[toGuess].coords);

                                    double distance = e.getDistanceByCountry(
                                        countriesReceived[toGuess]);
                                    Widget arrow = Transform.rotate(
                                      angle: angle,
                                      child: const Icon(Icons.arrow_upward),
                                    );
                                    return Card(
                                      child: ListTile(
                                        leading:
                                            arrow, //&Text(angle.toString()),
                                        title: Text(
                                          e.name,
                                          style: TextStyle(
                                            color: (distance < 3000)
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                          ),
                                        ),
                                        trailing: Text(distance.toString()),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : const Text("Noch nichts geraten!"),
                          //------------------------------
                          // Füllt Screen größtmöglich aus
                          //------------------------------
                          const Spacer(),
                          //------------------------------
                          // Eingabe mit Autocompletion
                          //------------------------------
                          Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: <Widget>[
                                  const Text(
                                      'Welches Land willst du versuchen?'),
                                  TypeAheadFormField(
                                    //------------------------------
                                    // vielleicht eigenes Keyboard?
                                    //------------------------------
                                    //hideKeyboard: true,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      decoration: const InputDecoration(
                                          labelText: 'Land'),
                                      controller: _typeAheadController,
                                    ),
                                    suggestionsCallback: (pattern) {
                                      return getSuggestions(
                                          pattern, countriesReceived);
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
                                    validator: (value) => value!.isEmpty
                                        ? 'Bitte wähle ein Land'
                                        : null,
                                    onSaved: (value) =>
                                        _selectedCountry = value,
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
                                          widget.guesses.add(
                                              name2Country[_selectedCountry]!);
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
                        ],
                      );
                    }
                    //------------------------------------
                    // sollten noch keine Daten vorliegen,
                    // wird Ladeindicator angezeigt
                    //------------------------------------
                  } else {
                    return const CircularProgressIndicator();
                  }
                });
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  //-----------------------------------
  // gitb Gewinnseite als Widget zurück
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
        Column(
          children:
              guesses.getRange(0, guesses.length - 1).toList().map<Widget>((e) {
            double angle = e.getInitialBearing(result.coords);
            Widget arrow = Transform.rotate(
              angle: angle,
              child: const Icon(Icons.arrow_upward),
            );
            return Card(
              child: ListTile(
                leading: arrow, //&Text(angle.toString()),
                title: Text(e.name),
                trailing: Text(e.getDistanceByCountry(result).toString()),
              ),
            );
          }).toList(),
        ),
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
                        toGuess = -1;
                        guesses.clear();
                        _prefs.then((SharedPreferences prefs) {
                          return prefs.setBool('generateNew', true);
                        });
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
        const Text(
          "Leider falsch!",
          style: TextStyle(color: Colors.red, fontSize: 40.0),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on), //&Text(angle.toString()),
            title: Text(result.name),
          ),
        ),
        Column(
          children: guesses.map<Widget>((e) {
            double angle = e.getInitialBearing(result.coords);
            Widget arrow = Transform.rotate(
              angle: angle,
              child: const Icon(Icons.arrow_upward),
            );
            return Card(
              child: ListTile(
                leading: arrow, //&Text(angle.toString()),
                title: Text(e.name),
                trailing: Text(e.getDistanceByCountry(result).toString()),
              ),
            );
          }).toList(),
        ),
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
                        toGuess = -1;
                        guesses.clear();
                        _prefs.then((SharedPreferences prefs) {
                          return prefs.setBool('generateNew', true);
                        });
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
