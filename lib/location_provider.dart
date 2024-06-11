import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  LatLng _currentLocation = const LatLng(40.4165, -3.70256);
  final _locationController = StreamController<LatLng>.broadcast();

  LatLng get currentLocation => _currentLocation;
  Stream<LatLng> get locationStream => _locationController.stream;

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;
    _locationController.add(_currentLocation);
    notifyListeners();
  }

  @override
  void dispose() {
    _locationController.close();
    super.dispose();
  }
}