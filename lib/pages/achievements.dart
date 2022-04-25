import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

// Lokalisierung
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late final Future<SharedPreferences> preferenceInstance;

  final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    preferenceInstance = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          FutureBuilder(
              future: preferenceInstance,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  SharedPreferences prefs = snapshot.data;

                  List<String> rawWinDates =
                      prefs.getStringList("winStreak") ?? [];
                  List<String> rawLossDates =
                      prefs.getStringList("loseStreak") ?? [];
                  List<String> rawGuessData =
                      prefs.getStringList("guessStreak") ?? [];
                  List<String> gamesPerDay =
                      prefs.getStringList("gamesPerDay") ??
                          ["0", "0", "0", "0", "0", "0", "0"];

                  HashMap winData = HashMap<int, int>();
                  HashMap lossData = HashMap<int, int>();

                  rawGuessData.removeWhere((element) => (element == ""));
                  dynamic avgGuess = (rawGuessData.isNotEmpty)
                      ? rawGuessData
                          .map((e) => int.parse(e))
                          .average
                          .toStringAsPrecision(3)
                      : "?";

                  for (int i = 1; i < 8; i++) {
                    winData[i] = rawWinDates
                        .where((f) => i == ((f == "") ? -1 : int.parse(f)))
                        .length;
                  }

                  for (int i = 1; i < 8; i++) {
                    lossData[i] = rawLossDates
                        .where((f) => i == ((f == "") ? -1 : int.parse(f)))
                        .length;
                  }

                  List wins = winData.values.toList();
                  wins.sort();

                  List losses = lossData.values.toList();
                  losses.sort();

                  print(gamesPerDay);

                  return SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      //Text(AppLocalizations.of(context)!.achievements,
                      //style: TextStyle(
                      // fontWeight: FontWeight.bold, fontSize: 20)),
                      Card(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: const Text("Overall statistics: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Text(
                                "Won: ${prefs.getInt("wins") ?? 0}",
                                style: TextStyle(color: Colors.green),
                              ),
                              Text(
                                "Lost: ${prefs.getInt("lose") ?? 0}",
                                style: TextStyle(color: Colors.red),
                              ),
                              Text(
                                "Avg. Guesses: ${avgGuess}",
                                style: TextStyle(color: Colors.purple),
                              )
                            ]),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 100,
                                maxWidth: 200,
                                minHeight: 100,
                                maxHeight: 250),
                            child: BarChart(BarChartData(
                                gridData: FlGridData(
                                    show: true,
                                    horizontalInterval: 1.0,
                                    verticalInterval: 1.0),
                                titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: AxisTitles(),
                                    topTitles: AxisTitles(),
                                    leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              const style = TextStyle(
                                                color: Color(0xff7589a2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              );
                                              String text;
                                              return Center(
                                                  child: Text(
                                                      value.toInt().toString(),
                                                      style: style));
                                            })),
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              const style = TextStyle(
                                                color: Color(0xff7589a2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              );
                                              String text;
                                              return Center(
                                                  child: Text(
                                                      weekdays[
                                                          value.toInt() - 1],
                                                      style: style));
                                            }))),
                                alignment: BarChartAlignment.spaceEvenly,
                                minY: 0,
                                maxY: max<double>(
                                        (wins.last + .0), (losses.last + .0)) +
                                    5,
                                barGroups: (winData.keys.isNotEmpty)
                                    ? winData.keys.map((weekday) {
                                        print(
                                            "$weekday, ${winData[weekday].toDouble()}");
                                        return BarChartGroupData(
                                            x: weekday,
                                            barRods: [
                                              BarChartRodData(
                                                  width: 10,
                                                  toY: winData[weekday]
                                                      .toDouble(),
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.zero),
                                              BarChartRodData(
                                                  width: 10,
                                                  toY: lossData[weekday]
                                                      .toDouble(),
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.zero),
                                            ]);
                                      }).toList()
                                    : [BarChartGroupData(x: 0)])),
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(
                              "Hier sehen Sie Ihre Gewinn-/Verluststatistik nach Wochentag aufgeschlüsselt.",
                              overflow: TextOverflow.clip,
                              maxLines: 10,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(
                              "Hier sehen Sie Ihre Anzahl an gespielten Spielen nach Wochentag.",
                              overflow: TextOverflow.clip,
                              maxLines: 10,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 100,
                                maxWidth: 200,
                                minHeight: 100,
                                maxHeight: 250),
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                      spots: gamesPerDay
                                          .asMap()
                                          .map((i, e) {
                                            return MapEntry(
                                                i,
                                                FlSpot(i.toDouble(),
                                                    int.parse(e).toDouble()));
                                          })
                                          .values
                                          .toList()),
                                ],
                                gridData: FlGridData(
                                    show: true,
                                    horizontalInterval: 1.0,
                                    verticalInterval: 1.0),
                                titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: AxisTitles(),
                                    topTitles: AxisTitles(),
                                    leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              const style = TextStyle(
                                                color: Color(0xff7589a2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              );
                                              String text;
                                              return Center(
                                                  child: Text(
                                                      value.toInt().toString(),
                                                      style: style));
                                            })),
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              const style = TextStyle(
                                                color: Color(0xff7589a2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              );
                                              String text;
                                              return Center(
                                                  child: Text(
                                                      weekdays[value.toInt()],
                                                      style: style));
                                            }))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })
        ],
      )),
    );
  }
}
