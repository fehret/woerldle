import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String dropdownValue = "1";

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        leading: Transform.scale(
          child: const Icon(Icons.settings),
          scale: 2,
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 20),
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
      ListTile(
        leading: DropdownButton(
          value: dropdownValue,
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: <String>['1', '2', '3', '4']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.deepPurple),
              ),
            );
          }).toList(),
        ),
        title: const Text("Schwierigkeit"),
      )
    ]);
  }
}
