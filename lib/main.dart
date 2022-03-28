import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:woerldle/pages/achievements.dart';
import 'package:woerldle/pages/game.dart';
import 'package:woerldle/pages/login.dart';
import 'package:flutter_svg_opt/flutter_svg_opt.dart';
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
    SettingsPage(),
    const LoginPage()
  ];

  //--------------------------------------------------
  // Funktion gibt Backlayer als Widget zurück
  // Änderung bzgl. Design müssen hier getätigt werden
  //--------------------------------------------------
  Widget getBackLayer() => Center( 
    child: BackdropNavigationBackLayer(
          items: const [
              Card(
                color: Colors.green,
                margin: EdgeInsets.symmetric(horizontal : 100.0),
                elevation : 10,
                child : ListTile(
                leading: Icon(Icons.gamepad_outlined),
                title: Text("Game"),
                ),
              ),
              Card(
                color: Colors.green,
                margin: EdgeInsets.symmetric(horizontal : 100.0),
                elevation : 10,
                child : ListTile(
                leading: Icon(Icons.check),
                title: Text("Achievements"),
                ),
              ),
              Card(
                color: Colors.green,
                margin: EdgeInsets.symmetric(horizontal : 100.0),
                elevation : 10,
                child : ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                ),
              ),
          ],
          //---------------------------------
          // setzt dementsprechend den Index
          //---------------------------------
          itemPadding: const EdgeInsets.only( bottom : 500.0),
          onTap: (int pos) => {setState(() => _pageIndex = pos)},
          separatorBuilder: (context, position) => const Divider()));

  //Grundstruktur der Applikation
  //Auf der Seiten werden alle Seiten geladen
  @override
  Widget build(BuildContext context) {
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
    );
  }
}
