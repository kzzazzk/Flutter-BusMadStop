import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '/screens/bus_stop_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  List<LatLng> routeCoordinates = [];
  LatLng initialCenter = LatLng(40.4165, -3.70256);

  @override
  void initState() {
    super.initState();
    //loadMarkers();
    //loadRouteCoordinates();
    loadInitialCenter();
    loadBusStopMarkers();
  }

  Future<void> loadBusStopMarkers() async {
    String jsonString =
        await rootBundle.loadString('lib/assets/EMT_stops.geojson');
    print("geojson cargado");
    var jsonData = jsonDecode(jsonString);
    print("json codificado");
    List<Marker> loadedMarkers = [];
    print("lista de markers ceada");
    for (var feature in jsonData['features']) {
      var coordinates = feature['geometry']['coordinates'];
      loadedMarkers.add(
        Marker(
          point: LatLng(coordinates[1], coordinates[0]),
          width: 80,
          height: 80,
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusStopScreen(
                            feature: feature,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                              'Stop name: ${feature['properties']['DENOMINACION']}'),
                          const SizedBox(height: 7),
                          Text('Tap to view details'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Background color
                shape: BoxShape.circle, // Circular shape
              ),
              padding: EdgeInsets.all(3), // Adjust padding as needed
              child: Icon(
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

  // Load coordiantes from database
  /*Future<void> loadMarkers() async {
    final dbMarkers = await DatabaseHelper.instance.getCoordinates();
    List<Marker> loadedMarkers = dbMarkers.map((record) {
      return Marker(
        point: LatLng(record['latitude'], record['longitude']),
        width: 80,
        height: 80,
        child: Icon(
          Icons.location_pin,
          size: 60,
          color: Colors.red,
        ),
      );
    }).toList();
    setState(() {
      markers = loadedMarkers;
    });
  }*/

  /*void loadRouteCoordinates() async {
    final dbCoordinates = await DatabaseHelper.instance.getLast30Coordinates();
    routeCoordinates = dbCoordinates.map((record) {
      return LatLng(record['latitude'], record['longitude']);
    }).toList();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content(),
    );
  }

  Future<void> loadInitialCenter() async {
    initialCenter = await getLastPositionFromFile();
  }

  Future<LatLng> getLastPositionFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');

    if (await file.exists()) {
      List<String> lines = await file.readAsLines();

      String lastLine = lines.last;

      List<String> values = lastLine.split(';');

      print("LAT:" +
          double.parse(values[1]).toString() +
          "LONG:" +
          double.parse(values[2]).toString());
      return LatLng(double.parse(values[1]), double.parse(values[2]));
    } else {
      throw Exception('File does not exist');
    }
  }

  Widget content() {
    return FlutterMap(
      options: MapOptions(
          initialCenter: initialCenter, // Centro inicial
          initialZoom: 15,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.all)),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: markers), // Marcadores cargados
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
