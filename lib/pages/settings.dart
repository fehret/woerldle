import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  String diff = "1";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  getDiff(key) async {
    return await SharedPreferences.getInstance().then((prefs){
        widget.diff = prefs.getInt(key)!.toString();
    });
  }

  addInt(String key, int value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }
  
  @override
  Widget build(BuildContext context) {

    return Column(children: [
      ListTile(
        leading: Transform.scale(
          child: const Icon(Icons.settings),
          scale: 1.5,
        ),
        title: const Center( 
          child: Text(
            "Settings",
            style: TextStyle(fontSize: 20),
            ),
        ),
      ),
      const Divider(
        color: Colors.black,
        thickness: 1.0,
      ),
      //-------------------------------
      // Beispielhafte Einstellung
      // Row wäre auch denkbar,
      // hätte mehr kreative Freiheiten
      //-------------------------------
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [ 
          Container(
            margin: const EdgeInsets.only(left : 15),
            child: const Text(
              "Schwierigkeit",
              style: TextStyle(
                fontSize: 20,
              ),

              ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
              
              value: widget.diff,
              style: const TextStyle(color: Colors.deepPurple),
              onChanged: (String? newValue) {
                setState(() {
                  widget.diff = newValue!;
                  addInt("difficulty", int.parse(widget.diff));
                });
              },
              items: [['1',Icons.sentiment_very_satisfied_sharp], ['2',Icons.sentiment_satisfied], ['3',Icons.sentiment_very_dissatisfied_outlined]]
                  .map<DropdownMenuItem<String>>((List list) {
                return DropdownMenuItem<String>(
                  value: list[0],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        list[0],
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 20
                          ),
                      ),
                      Icon(list[1]),
                    ]
                  )
                );
              }).toList(),
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 42,
              underline: const SizedBox(),
            ),
          ),
        ]
      )
    ]);
  }
}
