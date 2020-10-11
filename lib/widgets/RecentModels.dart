import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'UdsModel.dart';

class RecentModelsData extends ChangeNotifier {
  List<String> modelLocations;
  Future loaded;
  static const prefsKey = 'recentModels';

  RecentModelsData() {
    this.modelLocations = List<String>();
    loaded = _loadList();
  }

  _loadList() async {
    final prefs = await SharedPreferences.getInstance();
    this.modelLocations = prefs.getStringList(prefsKey) ?? List<String>();
  }

  Future<void> _saveList() async {
    final prefs = await SharedPreferences.getInstance();
    this.modelLocations.removeWhere((element) => element == null);
    prefs.setStringList(prefsKey, modelLocations);
  }

  void add(String location) {
    modelLocations.remove(location);
    modelLocations.insert(0, location);
    notifyListeners();
    _saveList();
  }
}

class RecentModelsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecentModelsData>(
      builder: (context, recentFiles, child) {
        return FutureBuilder(
          future: recentFiles.loaded,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (recentFiles.modelLocations.isEmpty) {
                return Text("No recent models");
              }
              return Container(
                height: 100,
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: recentFiles.modelLocations
                      .map(
                        (location) => UdsModel(location: location),
                      )
                      .toList(),
                ),
              );
            }
            return LinearProgressIndicator();
          },
        );
      },
    );
  }
}
