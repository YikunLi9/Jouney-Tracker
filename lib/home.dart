import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'database_util.dart';

// Define the HomeScreen class which is a stateful widget, necessary for widgets that need mutable state.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Define the private State class for HomeScreen using AutomaticKeepAliveClientMixin to keep the state alive (prevents state from being disposed).
class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin { 
  static GoogleMapController? _mapController; // Controller for Google Map interactions.
  final Location _location = Location(); // Location instance to get and track device's location.
  double _currentZoom = 15; // Initial zoom level for the map.
  LatLng? _currentPosition; // To store the current location of the device.
  static LatLng? _lastKnownPosition;  // To store the last known position even after app restarts.
  Timer? _timer; // Timer to perform location updates periodically.
  Map<PolylineId, Polyline> _polylines = {}; // Map to hold polylines that represent paths on the map.
  List<LatLng> routePoints = []; // List to hold points on the route travelled.

  // JSON string defining the custom style for the Google Map.
  final String _mapStyle = """
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ebe3cd"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#523735"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f1e6"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#c9b2a6"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#dcd2be"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ae9e90"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#93817c"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#a5b076"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#447530"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f1e6"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#fdfcf8"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f8c967"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#e9bc62"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e98d58"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#db8555"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#806b63"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8f7d77"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#ebe3cd"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#b9d3c2"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#92998d"
      }
    ]
  }
]
""";

  // Overridden property from AutomaticKeepAliveClientMixin to keep the widget alive.
  @override
  bool get wantKeepAlive => true; // 为 AutomaticKeepAliveClientMixin 实现

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Request location permission at initialization.
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _recordLocation()); // Setup a timer to record location every 10 seconds.
    _loadTodayLocations();  // Load locations recorded today when the widget initializes.
  }

   // Function to load today's location points from the database and update the polyline on the map.
  void _loadTodayLocations() async {
    List<LatLng> todayPoints = await DatabaseHelper.instance.getTodayLocations();
    setState(() {
      _updatePolylineWithPoints(todayPoints); // Update the polyline on the map with today's points.
    });
  }

   // Function to update the polyline with new points.
  void _updatePolylineWithPoints(List<LatLng> points) {
    PolylineId id = PolylineId("route");
    if (_polylines.containsKey(id)) {
      _polylines[id] = _polylines[id]!.copyWith(pointsParam: points);
    } else {
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: points,
        width: 5,
      );
      _polylines[id] = polyline;
    }
    print("Polyline updated with points count: ${points.length}");
  }

  // Clean up the controller and timer when the widget is disposed.
  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Callback function when the map is created.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    controller.setMapStyle(_mapStyle);
    print("Map created. Restoring last known position and polyline.");
    if (_lastKnownPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_lastKnownPosition!, _currentZoom));
      _updatePolylineWithPoints(routePoints);
    } else {
      _locateMe();
    }
  }

  // Function to get the current location of the device and update the map position.
  Future<void> _locateMe() async {
    var locData = await _location.getLocation();
    _currentPosition = LatLng(locData.latitude!, locData.longitude!);
    _lastKnownPosition = _currentPosition;
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, _currentZoom));
    }
  }

  // Function to request location permissions.
  void _requestLocationPermission() async {
    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }
    _locateMe();
  }

  // Function to increase the zoom level of the map.
  void _zoomIn() {
    if (_currentZoom < 19) {
      setState(() {
        _currentZoom++;
        _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
      });
    }
  }

  // Function to decrease the zoom level of the map.
  void _zoomOut() {
    if (_currentZoom > 0) {
      setState(() {
        _currentZoom--;
        _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
      });
    }
  }

  // Function to add and update a polyline with new points collected.
  void _addOrUpdatePolyline(List<LatLng> newPoints) {
    PolylineId id = PolylineId("route");
    List<LatLng> allPoints = List.from(_polylines[id]?.points ?? [])..addAll(newPoints);

    if (_polylines.containsKey(id)) {
      _polylines[id] = _polylines[id]!.copyWith(pointsParam: allPoints);
    } else {
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: allPoints,
        width: 5,
      );
      _polylines[id] = polyline;
    }
    print("Polyline updated with points count: ${allPoints.length}");
    setState(() {});
  }

  // Record the current location and update the database and polyline.
  void _recordLocation() async {
    var locData = await _location.getLocation();
    LatLng newPoint = LatLng(locData.latitude!, locData.longitude!);
    routePoints.add(newPoint);
    _addOrUpdatePolyline([newPoint]);
    await DatabaseHelper.instance.insertLocation(locData.latitude!, locData.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _lastKnownPosition ?? LatLng(0, 0),
              zoom: _lastKnownPosition != null ? _currentZoom : 1,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            polylines: Set<Polyline>.of(_polylines.values),
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
