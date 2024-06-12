import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mad_bus_stop/http/api_manager.dart';
import 'package:provider/provider.dart';
import '../location_provider.dart';
import '/screens/bus_stop_screen.dart';
import '/http/api_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    loadBusStopMarkers();
  }

  Future<void> loadBusStopMarkers() async {
    String jsonString =
        await rootBundle.loadString('lib/assets/EMT_stops.geojson');
    var jsonData = jsonDecode(jsonString);
    List<Marker> loadedMarkers = [];
    for (var feature in jsonData['features']) {
      var coordinates = feature['geometry']['coordinates'];
      loadedMarkers.add(
        Marker(
          point: LatLng(coordinates[1], coordinates[0]),
          width: 80,
          height: 80,
          child: IconButton(
            onPressed: () async {
              var busStops = await ApiManager.fetchStopData(
                  feature['properties']['CODIGOEMPRESA']);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text(
                        'Do you want to view the details of ${feature['properties']['DENOMINACION']}'),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusStopScreen(
                                feature: feature,
                                busStops: busStops,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Background color
                shape: BoxShape.circle, // Circular shape
              ),
              padding: const EdgeInsets.all(3), // Adjust padding as needed
              child: const Icon(
                Icons.directions_bus,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }
    setState(() {
      markers = loadedMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content(),
    );
  }

  Widget content() {
    LatLng center = Provider.of<LocationProvider>(context).currentLocation;
    return FlutterMap(
      options: MapOptions(
          initialCenter: center,
          initialZoom: 15,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.all)),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: markers),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routeCoordinates,
              color: Colors.pink,
              strokeWidth: 8.0,
            ),
          ],
        ),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
