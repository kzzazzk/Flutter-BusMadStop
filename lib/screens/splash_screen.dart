import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import '/db/database_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<Position>? _positionStreamSubscription;
  DatabaseHelper db = DatabaseHelper.instance;

  final logger = Logger();
  final _uidController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _uidController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void startTracking() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Adjust the accuracy as needed
      distanceFilter: 5, // Distance in meters before an update is triggered
    );
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        writePositionToFile(position);
        db.insertCoordinate(position);
      },
    );
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> writePositionToFile(Position position) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await file.writeAsString(
        '${timestamp};${position.latitude};${position.longitude}\n',
        mode: FileMode.append);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Toggle to turn on Location Tracking!!!'),
            Switch(
              value: _positionStreamSubscription != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    startTracking();
                  } else {
                    stopTracking();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
