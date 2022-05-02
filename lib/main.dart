import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woerldle/pages/achievements.dart';
import 'package:woerldle/pages/game.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Is needed for generation of localisation files
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', ''), // Deutsch ohne Landesspezifizierung
        Locale('en', ''), // Englisch ohne Landesspezifizierung
      ],
      //home: MyHomePage(title: AppLocalizations.of(context)!.appTitle),
      home: const MyHomePage(title: "Wördle"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _pageIndex = 0;
  int difficulty = 1;
  bool darkMode = false;

  void toggleDarkMode(value) async {}

  getPrefDiff() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      difficulty = prefs.getInt('difficulty') ?? 1;
    });
  }

  setPref(mode, value) async {
    switch (mode) {
      case "difficulty":
        final prefs = await SharedPreferences.getInstance();
        int current = prefs.getInt("difficulty") ?? 1;

        if (value != current) {
          prefs.setInt('difficulty', int.parse(value));
          setState(() {
            difficulty = int.parse(value);
          });
        }

        break;
      case "darkMode":
        final prefs = await SharedPreferences.getInstance();
        bool readDarkMode = prefs.getBool('darkMode') ?? false;
        prefs.setBool('darkMode', !readDarkMode);
        setState(() {
          darkMode = !readDarkMode;
        });
        break;
      default:
    }
  }

  pageWrapper(pageNumber) {
    switch (pageNumber) {
      case 0:
        return GamePage();
      case 1:
        return const AchievementsPage();
      default:
        return GamePage();
    }
  }
  
  @override
  void initState() {
    super.initState();
    getPrefDiff();
  }

  //--------------------------------------------------
  // Funktion gibt Backlayer als Widget zurück
  // Änderung bzgl. Design müssen hier getätigt werden
  //--------------------------------------------------
  Widget getBackLayer(BuildContext context) => BackdropNavigationBackLayer(
            items: [
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget> [
                    ListTile(
                      leading: const Icon(Icons.gamepad_outlined),
                      title: Text(AppLocalizations.of(context)!.game),
                    ),
                    const Divider(color: Colors.black, thickness: 0.1, indent: 10, endIndent: 10),
                    ListTile(
                leading: const Icon(Icons.check),
                title: Text(AppLocalizations.of(context)!.achievements),
                  ),
                ]
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(AppLocalizations.of(context)!.settings),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget> [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      //minVerticalPadding: 10,
                      leading: const Icon(Icons.dark_mode),
                      title: Text(
                        AppLocalizations.of(context)!.darkMode,
                        textAlign: TextAlign.left,
                        ),
                      trailing: SizedBox(
                        width: 100,
                        child: CupertinoSwitch(
                          value: darkMode,
                          onChanged: (newValue) {
                            setPref("darkMode", newValue);
                          })
                      )
                    ),
                    const Divider(color: Colors.black, thickness: 0.1, indent: 10, endIndent: 10),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      leading: const Icon(Icons.videogame_asset),
                      title: Text(
                          AppLocalizations.of(context)!.difficulty,
                          textAlign: TextAlign.left,
                      ),
                      trailing: Container(
                        width: 100,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButton<String>(
                          value: difficulty.toString(),
                          style: const TextStyle(color: Colors.deepPurple),
                          onChanged: (String? newValue) {
                            setPref("difficulty", newValue!);
                          },
                          items: [
                            [1, Icons.sentiment_very_satisfied_sharp],
                            [2, Icons.sentiment_satisfied],
                            [3, Icons.sentiment_very_dissatisfied_outlined]
                          ].map<DropdownMenuItem<String>>((List list) {
                            return DropdownMenuItem<String>(
                                value: list[0].toString(),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        list[0].toString(),
                                        style: const TextStyle(
                                            color: Colors.deepPurple, fontSize: 20),
                                      ),
                                      Icon(list[1]),
                                    ]));
                          }).toList(),
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: const SizedBox(),
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ],
              //---------------------------------
              // setzt dementsprechend den Index
              //---------------------------------
              itemPadding: const EdgeInsets.only(bottom: 500.0),
              onTap: (int pos) {
                setState(() {
                  _pageIndex = pos;
                });
              },
              separatorBuilder: (context, position) => const Divider());

  //Grundstruktur der Applikation
  //Auf der Seiten werden alle Seiten geladen
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackdropScaffold(
      resizeToAvoidBottomInset: false,
      appBar: BackdropAppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.title),
          Container(
            margin: const EdgeInsets.only(left: 5.0),
            child: const Icon(Icons.travel_explore),
          ),
        ]),
        leading: const BackdropToggleButton(
          icon: AnimatedIcons.close_menu,
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () => {setState((() => _pageIndex = 1))},
              icon: const Icon(Icons.emoji_events))
        ],
      ),

      //------------------------------------
      // Front-Layer zeigt gewählte Seite an
      //------------------------------------
      frontLayer: pageWrapper(_pageIndex),

      //----------------------------------
      // Backlayer wird prozedural erzeugt
      //----------------------------------
      backLayer: getBackLayer(context),
    );
  }
}
