import 'package:flutter/material.dart';

class BusStopScreen extends StatelessWidget {
  final Map<String, dynamic> feature;

  BusStopScreen({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(feature['properties']['DENOMINACION']),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Bus Stop Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Bus Stop Name: ${feature['properties']['DENOMINACION']}',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Bus Stop Address: ${feature['properties']['NOMBREVIA']}',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Bus Stop Routes: ${feature['properties']['LINEAS']}',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}