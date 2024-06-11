import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../location_provider.dart';
import '/screens/bus_stop_screen.dart';

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
    //loadMarkers();
    //loadRouteCoordinates();
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
                          const Text('Tap to view details'),
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
          initialCenter: center, // Centro inicial
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
