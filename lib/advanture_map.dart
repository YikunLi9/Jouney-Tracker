import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'database_util.dart';

// StatefulWidget to handle the dynamic aspects of displaying a map with markers.
class DetailPage extends StatefulWidget {
  final DateTime selectedDate;

  DetailPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

// State class for DetailPage, managing map and location data.
class _DetailPageState extends State<DetailPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Callback when map is created, setting the map controller and initiating data loading.
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadData();
  }

  // Fetch location data for the selected date and update the map accordingly.
  void _loadData() async {
    List<LatLng> locations = await DatabaseHelper.instance.getLocationsByDate(widget.selectedDate);
    if (locations.isNotEmpty) {
      _updateMap(locations);
    }
  }

  // Update the map with markers and optionally polylines for the retrieved locations.
  void _updateMap(List<LatLng> locations) async {
    Set<Marker> markers = {};
    List<LatLng> polylineCoordinates = [];  // List to hold coordinates for polylines.
    final icon = await createCircleBitmapDescriptor();  // Create a custom marker icon.

    // Loop through locations, creating markers and adding coordinates to polyline list.
    for (var location in locations) {
      markers.add(Marker(
        markerId: MarkerId(location.toString()), // Unique ID for each marker.
        position: location, // Geographic coordinates for the marker.
        icon: icon,
      ));
      polylineCoordinates.add(location);
    }

    setState(() {
      _markers = markers; // Update state with new markers.
    });

    if (locations.isNotEmpty) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(locations.first, 15), // Center on the first location with zoom level 15.
      );
    }
  }

  // Function to create a custom marker icon as a circle.
  Future<BitmapDescriptor> createCircleBitmapDescriptor() async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..color = Colors.blue;  // 你可以选择颜色
    final double radius = 10;  // 圆点的半径

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final img = await pictureRecorder.endRecording().toImage(
      (radius * 2).toInt(),
      (radius * 2).toInt(),
    );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Map"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),  // Default location
          zoom: 1,
        ),
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}
