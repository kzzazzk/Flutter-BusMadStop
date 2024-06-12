import 'package:flutter/material.dart';
import 'package:mad_bus_stop/http/api_manager.dart';

class BusStopScreen extends StatefulWidget {
  late final Map<String, int> busStops;
  final Map<String, dynamic> feature;

  BusStopScreen({Key? key, required this.feature, required this.busStops})
      : super(key: key);

  @override
  _BusStopScreenState createState() => _BusStopScreenState();
}

class _BusStopScreenState extends State<BusStopScreen> {
  late Map<String, int> busStops;
  String currentBusStop = "";

  @override
  void initState() {
    super.initState();
    busStops = widget.busStops;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Remove the default back button
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 45,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshTimes,
              ),
            ),
          ],
        ),
      ),
      body: content(),
    );
  }

  void _refreshTimes() async {
    Map<String, int> newBusStops =
        await ApiManager.fetchStopData(currentBusStop);
    if (mounted) {
      setState(() {
        busStops = newBusStops;
      });
    }
  }

  Widget content() {
    List<String> busLines = widget.feature['properties']['LINEAS'].split(', ');
    currentBusStop = widget.feature['properties']['CODIGOEMPRESA'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    widget.feature['properties']['DENOMINACION'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.feature['properties']['CODIGOEMPRESA'],
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: busLines.map((line) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: busStops.length,
                itemBuilder: (context, index) {
                  String busStop = busStops.keys.elementAt(index);
                  int? estimatedTime = busStops[busStop];
                  String formattedTimes = formattedTime(estimatedTime!.toInt());

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            busStop,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          formattedTimes,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  formattedTime(int timeInSecond) {
    if (timeInSecond > 3600) {
      return "> 1h";
    } else if (timeInSecond == 0) {
      return "Now";
    }
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }
}
