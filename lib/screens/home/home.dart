import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(43.4675, -79.6858),
          initialZoom: 12.2,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/dataviz-dark/{z}/{x}/{y}.png?key=YcB0Er29jUlGFLKjn3nP',
            userAgentPackageName: 'com.sight.track',
          ),
        ],
      ),
    );
  }
}
