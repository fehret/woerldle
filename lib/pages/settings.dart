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
      
    ]);
  }
}
