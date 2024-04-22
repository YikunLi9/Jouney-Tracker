import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'database_util.dart';

class DetailPage extends StatefulWidget {
  final DateTime selectedDate;

  DetailPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadData();
  }

  void _loadData() async {
    List<LatLng> locations = await DatabaseHelper.instance.getLocationsByDate(widget.selectedDate);
    if (locations.isNotEmpty) {
      _updateMap(locations);
    }
  }

  void _updateMap(List<LatLng> locations) async {
    Set<Marker> markers = {};
    List<LatLng> polylineCoordinates = [];
    final icon = await createCircleBitmapDescriptor();  // 生成圆点图标

    for (var location in locations) {
      markers.add(Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        icon: icon,  // 使用生成的圆点图标
      ));
      polylineCoordinates.add(location);
    }

    setState(() {
      _markers = markers;
    });

    if (locations.isNotEmpty) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(locations.first, 15),
      );
    }
  }

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
