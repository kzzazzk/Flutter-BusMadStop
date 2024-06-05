import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<List<String>> _coordinates = [];

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
            title: Text(
              'Timestamp: $formattedDate',
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Text('Latitude: ${coord[1]}, Longitude: ${coord[2]}',
                style: const TextStyle(color: Colors.black)),
          );
        },
      ),
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
