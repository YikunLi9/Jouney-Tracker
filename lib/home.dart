import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'database_util.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin { // 添加 AutomaticKeepAliveClientMixin 来保持页面状态
  static GoogleMapController? _mapController; // 使用静态变量保存地图控制器
  final Location _location = Location();
  double _currentZoom = 15;
  LatLng? _currentPosition;
  static LatLng? _lastKnownPosition; // 使用静态变量保存最后已知位置
  Timer? _timer;
  Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> routePoints = [];

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

  @override
  bool get wantKeepAlive => true; // 为 AutomaticKeepAliveClientMixin 实现

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _recordLocation());
    _loadTodayLocations();
  }

  void _loadTodayLocations() async {
    List<LatLng> todayPoints = await DatabaseHelper.instance.getTodayLocations();
    setState(() {
      _updatePolylineWithPoints(todayPoints);
    });
  }

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


  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

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


  Future<void> _locateMe() async {
    var locData = await _location.getLocation();
    _currentPosition = LatLng(locData.latitude!, locData.longitude!);
    _lastKnownPosition = _currentPosition;
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
    _locateMe();
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

  void _addOrUpdatePolyline(List<LatLng> newPoints) {
    PolylineId id = PolylineId("route");
    // 合并旧的点和新的点
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
    setState(() {
      // 更新地图的Polyline
    });
  }

  void _recordLocation() async {
    var locData = await _location.getLocation();
    LatLng newPoint = LatLng(locData.latitude!, locData.longitude!);
    routePoints.add(newPoint);
    _addOrUpdatePolyline([newPoint]);
    await DatabaseHelper.instance.insertLocation(locData.latitude!, locData.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  // 调用 super.build 保持页面状态
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _lastKnownPosition ?? LatLng(0, 0), // 使用上次位置或默认位置
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
