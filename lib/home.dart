import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  double _currentZoom = 15;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _locateMe();  // Ensure location is centered right after map is ready
  }

  Future<void> _locateMe() async {
    var locData = await _location.getLocation();
    _currentPosition = LatLng(locData.latitude!, locData.longitude!);
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, _currentZoom));
    }
  }

  void _requestLocationPermission() async {
    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }
    _locateMe(); // Get initial location once permission is granted
  }

  void _zoomIn() {
    if (_currentZoom < 19) {
      setState(() {
        _currentZoom++;
        _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
      });
    }
  }

  void _zoomOut() {
    if (_currentZoom > 0) {
      setState(() {
        _currentZoom--;
        _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0), // Default to equator before location is found
              zoom: 1,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _locateMe,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  child: Icon(Icons.my_location),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomIn,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
