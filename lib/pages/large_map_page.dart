import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LargeMapPage extends StatelessWidget {
  final LatLng initialLocation;

  const LargeMapPage({Key? key, required this.initialLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Large Map View'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 15,
        ),
        markers: Set<Marker>.of([
          Marker(
            markerId: MarkerId('large_map_marker'),
            position: initialLocation,
          ),
        ]),
      ),
    );
  }
}