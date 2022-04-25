import 'package:flutter/cupertino.dart';

// Lokalisierung
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late final preferenceInstance;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Column(children: [
        Text(AppLocalizations.of(context)!.achievements),
        /*FutureBuilder(
        // key wird für AnimatedSwitcher genutzt
        //key: ValueKey<int>(widget.guesses.length),
            future: countries,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.hasData) {
            ],*/
      ])),
    );
  }
}
