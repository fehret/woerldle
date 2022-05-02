import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'dart:collection';
import 'package:woerldle/models/country.dart';
import 'package:woerldle/widgets/guessColumn.dart';
import 'package:woerldle/pages/countryPopup.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

import 'package:flutter/services.dart' show rootBundle;

import '../widgets/smallImage.dart';

// Lokalisierung
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const int SMALL_COUNTRIES = 10000;
const int Medium_COUNTRIES = 500000;

class GamePage extends StatefulWidget {
  //-------------------------------------
  // Halte getätigte Guesses weiter oben,
  // sonst Fehler durch Seitenwechsel
  // (Sollte auch normal gehen,
  // aber bisher noch nicht geändert)
  //-------------------------------------
  List<Country> guesses = [];
  bool reGen = true;
  bool darkMode = false;
  int toGuess = -1;
  int diff = 1;
  int tries = 4;

  GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

//-----------------------------------------------------------------
// AutomaticKeepAliveClientMixin sorgt für Speicherung des States
//  dann müssen wantKeepAlive und build anders überschrieben werden
//-----------------------------------------------------------------
class _GamePageState extends State<GamePage>
//with AutomaticKeepAliveClientMixin {
{
  /*@override
  bool get wantKeepAlive => true;*/

  //------------------------------
  // alle Variablen, die für die
  // Spielmechanik notwendig sind
  //------------------------------
  late Future<List<Country>> countries;
  late int toGuess;
  int difficulty = 1;
  bool darkMode = false;

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

  checkPrefValue(key) async {
    print("game: darkMode: $darkMode, difficulty: $difficulty");
    switch (key) {
      case "difficulty":
        int d = await SharedPreferences.getInstance().then((prefs) {
          return prefs.getInt(key) ?? difficulty;
        });
        if (d != difficulty) {
          setState(() {
            difficulty = d;
            widget.reGen = true;
            widget.guesses = [];
          });
        }
        break;
      case "darkMode":
        SharedPreferences.getInstance().then((prefs) {
          setState(() {
            darkMode = prefs.getBool(key) ?? darkMode;
            widget.reGen = false;
          });
        });
        break;
      default:
    }
  }

  setPrefValue(key, value) async {
    await SharedPreferences.getInstance().then((prefs) {
      return prefs.setInt(key, value);
    });
  }

  addWin() {
    SharedPreferences.getInstance().then((prefs) {
      int currentValue = prefs.getInt("wins") ?? 0;
      prefs.setInt("wins", currentValue + 1);
    });
  }

  addLose() {
    SharedPreferences.getInstance().then((prefs) {
      int currentValue = prefs.getInt("lose") ?? 0;
      prefs.setInt("lose", currentValue + 1);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    // bei AutomaticKeepAliveClientMixin nötig
    //super.build(context);

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

            //aktualisiere die Schwierigkeit
            checkPrefValue("difficulty");
            switch (difficulty) {
              case 1:
                widget.tries = 4;
                break;
              case 2:
                widget.tries = 3;
                break;
              case 3:
                widget.tries = 2;
                break;
              default:
            }

            countriesReceived.sort(((a, b) => a.name.compareTo(b.name)));
            HashMap<String, Country> name2Country = HashMap.fromIterable(
                countriesReceived,
                key: (element) => element.name,
                value: (element) => element);

            if (widget.reGen) {
              while (true) {
                widget.toGuess = Random().nextInt(countriesReceived.length);
                if (difficulty == 3) {
                  break;
                } else if (difficulty == 2 &&
                    countriesReceived[widget.toGuess].area > Medium_COUNTRIES) {
                  break;
                } else if (difficulty == 1 &&
                    countriesReceived[widget.toGuess].area > SMALL_COUNTRIES) {
                  break;
                }
              }
              widget.reGen = false;
            }

            //--------------------------------
            // checkt auf Gewinn oder Verlust
            // gibt entsprechendes Layout aus
            // lose noch auf 2, sonst Probleme
            //--------------------------------
            if (widget.guesses.isNotEmpty &&
                widget.guesses.last == countriesReceived[widget.toGuess]) {
              addWin();
              return winPage(widget.guesses);
            } else if (widget.guesses.length > widget.tries) {
              addLose();
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
                    margin: const EdgeInsets.all(10),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 150,
                      width: double.infinity,
                      child: smallImage(countriesReceived[widget.toGuess],
                          color: Colors.red, height: 150.0, type: 'borders'),
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
                          Text(AppLocalizations.of(context)!.whichCountry),
                          TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.country),
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
                                leading: FractionallySizedBox(
                                  child: Image.asset(
                                      "assets/png100px/${countriesReceived.firstWhere((country) => country.name == suggestion).short}.png"),
                                  heightFactor: 0.5,
                                  widthFactor: 0.2,
                                ),
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
                                return AppLocalizations.of(context)!
                                    .pleaseChooseCountry;
                              } else if (widget.guesses.isEmpty) {
                                return null;
                              } else if (selectedSug) {
                                try {
                                  widget.guesses.firstWhere(
                                      (country) => country.name == value);
                                  return AppLocalizations.of(context)!
                                      .pleaseChooseAnother;
                                } catch (e) {
                                  return null;
                                }
                              } else {
                                try {
                                  widget.guesses.firstWhere((country) =>
                                      country.name == bestSuggestion?.name);
                                  return AppLocalizations.of(context)!
                                      .pleaseChooseAnother;
                                } catch (e) {
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
                            child: Text(AppLocalizations.of(context)!.check),
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
                  guessColumn(widget.guesses, countriesReceived[widget.toGuess],
                      false, difficulty),
                ],
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
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
        Text(
          AppLocalizations.of(context)!.correct,
          style: TextStyle(color: Colors.lightGreen, fontSize: 40.0),
        ),
        Container(
          height: 400,
          width: double.infinity,
          foregroundDecoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: FlutterMap(
            options: MapOptions(
              center: result.coords,
              zoom: 10,
              onTap: (_, __) => _popupLayerController.hideAllPopups(),
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                    minZoom: 3,
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
                Text(AppLocalizations.of(context)!.share),
              ],
            ),
            const Spacer(),
            //const SizedBox.expand(),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.nextRound),
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
          child: Text(
            AppLocalizations.of(context)!.wrong,
            style: TextStyle(color: Colors.red, fontSize: 40.0),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(result.name),
          ),
        ),
        guessColumn(guesses, result, false, difficulty),
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
                Text(AppLocalizations.of(context)!.share),
              ],
            ),
            const Spacer(),
            //const SizedBox.expand(),
            ElevatedButton(
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.anotherRound),
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
