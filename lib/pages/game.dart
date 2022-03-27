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

import 'package:flutter/services.dart' show rootBundle;

import '../models/imageTheme.dart';

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
  // Dabei sortiert der Algorithmus jeden Bestandteil des Strings
  // Die besten Überschneidungen sind mit der Menge an zusammenhängenden Substrings
  // Dann die, die mit denen Anfangen bsp:
  // query = Gh
  // 1. Ghana 2. Afghanistan, Germany
  //-------------------------------------------
  static List<Country> getSuggestions(String query, List<Country> toMatch) {
    List<Country> resMatches = <Country>[];
    //List<String> matches = <String>[];

    query = query.toLowerCase().replaceAll(" ", "");

    //matches.addAll(toMatch.map((e) => e.name));

    for (int i = query.length; i > 0; i--) {
      resMatches += toMatch
          .where((s) => s.name
              .toLowerCase()
              .replaceAll(" ", "")
              .startsWith(query.substring(0, i)))
          .toList();

      resMatches += toMatch
          .where((s) => s.name
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(query.substring(0, i)))
          .toList();
    }

    return [
      ...{...resMatches}
    ];
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
            countriesReceived.sort(((a, b) => a.name.compareTo(b.name)));
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

              List<Country>? suggestions;
              Country? bestSuggestion;
              bool selectedSug = false;

              return Column(
                children: [
                  //------------------------------
                  // nur als Dev-Hilfe,
                  //  zeigt Lösung an
                  //------------------------------
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(15),
                    child: smallImage(countriesReceived[widget.toGuess],
                        color: Colors.red, height: 150.0, type: 'borders'),
                    /*Container(
                      padding: const EdgeInsets.all(5),
                      height: 150,
                      child: SvgPicture.asset(
                        "assets/borders/${countriesReceived[widget.toGuess].short.toLowerCase()}.svg",
                        color: Colors.red,
                        alignment: Alignment.center,
                        fit: BoxFit.scaleDown,
                        ),
                    ),*/
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
                            textFieldConfiguration: TextFieldConfiguration(
                              decoration:
                                  const InputDecoration(labelText: 'Land'),
                              controller: _typeAheadController,
                            ),
                            suggestionsCallback: (pattern) {
                              if (pattern.isNotEmpty) {
                                selectedSug = false;
                                suggestions =
                                    getSuggestions(pattern, countriesReceived);

                                //Wähle das erste Land in der Suche als ähnlichsten Resultat aus
                                bestSuggestion = suggestions!.first;

                                return suggestions!.map((e) => e.name).toList();
                              }
                              return countriesReceived
                                  .map((e) => e.name)
                                  .toList();
                            },
                            itemBuilder: (context, String suggestion) {
                              return ListTile(
                                leading: smallImage(
                                    countriesReceived.firstWhere((country) =>
                                        country.name == suggestion),
                                    width: 30),
                                /*Container(
                                    height: 30,
                                    width: 30,  
                                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: SvgPicture.asset(
                                    "assets/flags/$shortTerm.svg",
                                    alignment: Alignment.center,
                                    fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  */
                                title: Text(suggestion),
                              );
                            },
                            transitionBuilder:
                                (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (String suggestion) {
                              _typeAheadController.text = suggestion;
                              selectedSug = true;
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Bitte wähle ein Land';
                              } else if (widget.guesses.isEmpty) {
                                return null;
                              } else if (selectedSug) {
                                try {
                                  print(value);
                                  widget.guesses.firstWhere(
                                      (country) => country.name == value);
                                  return 'Bitte wähle ein noch nicht gewähltes Land';
                                } catch (e) {
                                  print(e);
                                  return null;
                                }
                              } else {
                                try {
                                  widget.guesses.firstWhere((country) =>
                                      country.name == bestSuggestion?.name);
                                  return 'Bitte wähle ein noch nicht gewähltes Land';
                                } catch (e) {
                                  print(e);
                                  return null;
                                }
                              }
                            },
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
                                  if (selectedSug) {
                                    widget.guesses
                                        .add(name2Country[_selectedCountry]!);
                                  } else {
                                    widget.guesses.add(bestSuggestion!);
                                  }
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
                  guessColumn(
                      widget.guesses, countriesReceived[widget.toGuess], false),
                ],
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator() );
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
    final PopupController _popupLayerController = PopupController();

    return Column(
      children: [
        const SizedBox(
          height: 20.0,
        ),
        const Text(
          "Korrekt!",
          style: TextStyle(color: Colors.lightGreen, fontSize: 40.0),
        ),
        Container(
          height: 400,
          width: 400,
          child: FlutterMap(
            options: MapOptions(
              center: result.coords,
              zoom: 10,
              onTap: (_, __) => _popupLayerController.hideAllPopups(),
              minZoom: 3,
            ),
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                    minZoom: 1,
                    maxZoom: 18,
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
              ),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markers: [
                      CountryMarker(
                          country: result,
                          container: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40.0),
                              child: SvgPicture.asset(
                                "assets/flags/${result.short}.svg",
                                alignment: Alignment.center,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                    ],
                    markerRotateAlignment:
                        PopupMarkerLayerOptions.rotationAlignmentFor(
                            AnchorAlign.top),
                    popupBuilder: (BuildContext context, Marker countryMarker) {
                      if (countryMarker is CountryMarker) {
                        return CountryPopup(country: countryMarker.country);
                      }
                      return Container();
                    }),
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on), //&Text(angle.toString()),
            title: Text(result.name),
          ),
        ),
        //const Spacer(),
        //guessColumn(guesses, result, true),
        //const Spacer(),
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
            ElevatedButton(
                child: Row(
                  children: const [
                    Text("Noch eine Runde!"),
                    Icon(Icons.arrow_forward_ios_rounded)
                  ],
                ),
                onPressed: () {
                  setState(() {
                    widget.toGuess = -1;
                    guesses.clear();
                    widget.reGen = true;
                  });
                }),
          ],
        )
      ],
    );
  }
}
