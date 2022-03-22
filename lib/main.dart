import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:woerldle/pages/achievements.dart';
import 'package:woerldle/pages/game.dart';
import 'package:woerldle/pages/login.dart';
import 'pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wörldle',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Wörldle'),
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

class _MyHomePageState extends State<MyHomePage> {
  int _pageIndex = 0;

  //------------------------------------
  // Liste der Seiten für die Navigation
  //------------------------------------
  final List<Widget> pages = [
    GamePage(),
    const AchievementsPage(),
    const SettingsPage(),
    const LoginPage()
  ];

  //--------------------------------------------------
  // Funktion gibt Backlayer als Widget zurück
  // Änderung bzgl. Design müssen hier getätigt werden
  //--------------------------------------------------
  Widget getBackLayer() => BackdropNavigationBackLayer(
          items: const [
            ListTile(
              leading: Icon(Icons.gamepad_outlined),
              title: Text("Game"),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text("Achievements"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            )
          ],
          //---------------------------------
          // setzt dementsprechend den Index
          //---------------------------------
          onTap: (int pos) => {setState(() => _pageIndex = pos)},
          separatorBuilder: (context, position) => const Divider());

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      appBar: BackdropAppBar(
        title: Text(widget.title),
        leading: const BackdropToggleButton(
          icon: AnimatedIcons.close_menu,
        ),
        actions: <Widget>[
          //------------------------------------------
          // Profil-Button
          //  Profilseite sollte immer die letzte sein
          //------------------------------------------
          IconButton(
              onPressed: () =>
                  {setState((() => _pageIndex = pages.length - 1))},
              icon: const Icon(Icons.person))
        ],
      ),

      //------------------------------------
      // Front-Layer zeigt gewählte Seite an
      //------------------------------------
      frontLayer: pages[_pageIndex],

      //----------------------------------
      // Backlayer wird prozedural erzeugt
      //---------------------------------- 
      backLayer: getBackLayer(),

      //-----------------------
      // altes Programm, nötig?
      //-----------------------
      /*Scaffold(
        backgroundColor: const Color.fromARGB(255, 116, 200, 248),
        body: Column(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(20.0),
                child: const Text("Menü", style: TextStyle(fontSize: 20))),
            const Divider(),
            Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                      primary: const Color.fromARGB(255, 0, 26, 255)),
                  onPressed: () {}, //TODO: WAS SOLL PASSIEREN?
                  child: const Text("Einstellungen"),
                ))
          ],
        ),
      ),*/
    );
  }
}
