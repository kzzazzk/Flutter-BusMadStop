import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../db/database_helper.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<List<String>> _coordinates = [];
  List<List<String>> _dbCoordinates = []; // For coordinates from the database

  @override
  void initState() {
    super.initState();
    // This method is called once when the state object is created.
    // It's a good place to initialize data that depends on the state.
    print("initState: Initial state setup.");
    _loadCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    // Similar to the build method of a StatelessWidget,
    // this method is called every time the widget needs to be rebuilt, for example, after calling setState().
    print("build: Building the user interface.");
    return Scaffold(
      body: ListView.builder(
        itemCount: _coordinates.length,
        itemBuilder: (context, index) {
          var coord = _coordinates[index];
          var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss')
              .format(DateTime.fromMillisecondsSinceEpoch(int.parse(coord[0])));
          return ListTile(
              title: Text('DB Timestamp: ${coord[0]}',
                  style: const TextStyle(color: Colors.red)),
              subtitle: Text('Latitude: ${coord[1]}, Longitude: ${coord[2]}',
                  style: const TextStyle(color: Colors.red)),
              onTap: () => _showDeleteDialog(coord[0]),
              onLongPress: () =>
                  _showUpdateDialog(coord[0], coord[1], coord[2]));
        },
      ),
    );
  }

  void _showDeleteDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm delete ${timestamp}"),
          content: Text("Do you want to delete this coordinate?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                await DatabaseHelper.instance.deleteCoordinate(timestamp);
                Navigator.of(context).pop(); // Dismiss the dialog
                _loadDbCoordinatesAndUpdate(); // Reload data and update UI
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(
      String timestamp, String currentLat, String currentLong) {
    TextEditingController latController =
        TextEditingController(text: currentLat);
    TextEditingController longController =
        TextEditingController(text: currentLong);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update coordinates for ${timestamp}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: latController,
                decoration: InputDecoration(labelText: "Latitude"),
              ),
              TextField(
                controller: longController,
                decoration: InputDecoration(labelText: "Longitude"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Update"),
              onPressed: () async {
                Navigator.of(context).pop();
                await DatabaseHelper.instance.updateCoordinate(
                    timestamp, latController.text, longController.text);
                _loadDbCoordinatesAndUpdate();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCoordinates() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');
    List<String> lines = await file.readAsLines();
    setState(() {
      _coordinates = lines.map((line) => line.split(';')).toList();
    });
  }

  Future<void> _loadDbCoordinates() async {
    List<Map<String, dynamic>> dbCoords =
        await DatabaseHelper.instance.getCoordinates(); // Corrected
    setState(() {
      _dbCoordinates = dbCoords
          .map((c) => [
                c['timestamp'].toString(), // Corrected
                c['latitude'].toString(), // Corrected
                c['longitude'].toString() // Corrected
              ])
          .toList();
    });
  }

  void _loadDbCoordinatesAndUpdate() async {
    List<Map<String, dynamic>> dbCoords =
        await DatabaseHelper.instance.getCoordinates();
    setState(() {
      _dbCoordinates = dbCoords
          .map((c) => [
                c['timestamp'].toString(),
                c['latitude'].toString(),
                c['longitude'].toString()
              ])
          .toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method is called right after initState the first time
    // the widget is built and when any dependencies of the InheritedWidget change.
    print("didChangeDependencies: Dependencies updated.");
  }

  @override
  void didUpdateWidget(SecondScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent widget changes and has to rebuild this widget (because it needs to update the configuration),
    // this method is called with the old widget as an argument.
    print("didUpdateWidget: The widget has been updated from the parent.");
  }

  @override
  void dispose() {
    // This method is called when this state object is permanently removed.
    print("dispose: Cleaning up before the state is destroyed.");
    super.dispose();
  }
}
