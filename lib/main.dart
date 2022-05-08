import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woerldle/pages/achievements.dart';
import 'package:woerldle/pages/game.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'variablen/locale.dart' as locales;

Future<void> main() async {
  runApp(const MyApp());
  String? locale = await Devicelocale.currentLocale;
  locales.locale = locale?.substring(0, 2);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    if (kDebugMode) {
      print(themeMode == ThemeMode.dark);
    }
    setState(() {
      _themeMode = themeMode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      theme:
          ThemeData(primarySwatch: Colors.green, brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,

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
      home: const MyHomePage(title: "Wörldle"),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        var brightness = SchedulerBinding.instance!.window.platformBrightness;
        bool isDarkMode = brightness == Brightness.dark;
        final prefs = await SharedPreferences.getInstance();
        bool readDarkMode = prefs.getBool('darkMode') ?? isDarkMode;
        prefs.setBool('darkMode', !readDarkMode);
        setState(() {
          darkMode = !readDarkMode;
        });
        break;
      default:
    }
  }

  getDarkMode() async {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    final prefs = await SharedPreferences.getInstance();
    bool correctMode = prefs.getBool('darkMode') ?? isDarkMode;

    MyApp.of(context)!
        .changeTheme(correctMode ? ThemeMode.dark : ThemeMode.light);

    setState(() {
      darkMode = correctMode;
    });
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
    getDarkMode();
  }

  //--------------------------------------------------
  // Funktion gibt Backlayer als Widget zurück
  // Änderung bzgl. Design müssen hier getätigt werden
  //--------------------------------------------------
  Widget getBackLayer() => Builder(
        builder: (BuildContext context) {
          return BackdropNavigationBackLayer(
              items: [
                Card(
                  color: darkMode ? Colors.grey : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.gamepad_outlined),
                        title: Text(AppLocalizations.of(context)!.game),
                        onTap: () {
                          Backdrop.of(context).concealBackLayer();
                          setState(() {
                            _pageIndex = 0;
                          });
                        },
                      ),
                      Divider(
                          color: darkMode ? Colors.white : Colors.black,
                          thickness: 0.1,
                          indent: 10,
                          endIndent: 10),
                      ListTile(
                        leading: const Icon(Icons.check),
                        title: Text(AppLocalizations.of(context)!.achievements),
                        onTap: () {
                          Backdrop.of(context).concealBackLayer();
                          setState(() {
                            _pageIndex = 1;
                          });
                        },
                      ),
                    ]),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(AppLocalizations.of(context)!.settings),
                ),
                Card(
                  color: darkMode ? Colors.grey : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(children: <Widget>[
                      ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
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
                                    MyApp.of(context)!.changeTheme(newValue
                                        ? ThemeMode.dark
                                        : ThemeMode.light);
                                    setPref("darkMode", newValue);
                                  }))),
                      Divider(
                          color: darkMode ? Colors.white : Colors.black,
                          thickness: 0.1,
                          indent: 10,
                          endIndent: 10),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        leading: const Icon(Icons.videogame_asset),
                        title: Text(
                          AppLocalizations.of(context)!.difficulty,
                          textAlign: TextAlign.left,
                        ),
                        trailing: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: darkMode ? Colors.grey : Colors.white,
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
                                              color: Colors.deepPurple,
                                              fontSize: 20),
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
                    ]),
                  ),
                ),
              ],
              //---------------------------------
              // setzt dementsprechend den Index
              //---------------------------------
              itemPadding: const EdgeInsets.only(bottom: 500.0),
              separatorBuilder: (context, position) => const Divider());
        },
      );

  //Grundstruktur der Applikation
  //Auf der Seiten werden alle Seiten geladen
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackdropScaffold(
      scaffoldKey: _scaffoldKey,
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
      backLayer: getBackLayer(),
    );
  }
}
