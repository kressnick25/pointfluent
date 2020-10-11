import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'UdsModel.dart';

class RecentModels extends StatefulWidget {
  static const prefsKey = 'recentModels';

  RecentModels({Key key}) : super(key: key);

  static updateStoredList(String newLocation) async {
    // Get the local most recent list and add this location to the front
    final prefs = await SharedPreferences.getInstance();
    List<String> recentLocations =
        prefs.getStringList(prefsKey) ?? List<String>();
    // Move location to front if already exists so that is in order of 'most recent'
    recentLocations.remove(newLocation);
    recentLocations.insert(0, newLocation);
    prefs.setStringList(prefsKey, recentLocations);
  }

  @override
  _RecentModelsState createState() => _RecentModelsState();
}

class _RecentModelsState extends State<RecentModels> {
  Future<List<String>> _modelLocations;

  Future<List<String>> _loadModels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(RecentModels.prefsKey) ?? List<String>();
  }

  @override
  void initState() {
    _modelLocations = _loadModels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: this._modelLocations,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          final modelLocations = snapshot.data;
          if (modelLocations.isEmpty) {
            return Text("No recent models");
          }
          return Container(
            height: 100,
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: modelLocations
                  .map(
                    (location) => UdsModel(location: location),
                  )
                  .toList(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Error loading recent models");
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }
}
