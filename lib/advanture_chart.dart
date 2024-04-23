import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'advanture_map.dart';
import 'database_util.dart';

import 'dart:math';

// Define a StatefulWidget for the adventure screen of the app.
class AdventureScreen extends StatefulWidget {
  @override
  _AdventureScreenState createState() => _AdventureScreenState();
}

// State class to handle dynamic updates and data management for the AdventureScreen.
class _AdventureScreenState extends State<AdventureScreen> {
  DateTime _selectedDay = DateTime.now();  // Currently selected day in the calendar.
  DateTime _focusedDay = DateTime.now(); // The day that the calendar is focused on.
  List<FlSpot> _spots = [];

  // Function to calculate the distance between two geographical points.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;    // Math.PI / 180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2)); // 2 * R; R = 6371 km, round to 2 decimal places
  }

  // Function to fetch and process location data for a selected date.
  void _updateDataForSelectedDate() async {
    List<LatLng> locations = await DatabaseHelper.instance.getLocationsByDate(_selectedDay);
    double totalDistance = 0;
    List<FlSpot> newSpots = [];
    for (int i = 0; i < locations.length; i++) {
      if (i > 0) {
        totalDistance += _calculateDistance(
            locations[i-1].latitude, locations[i-1].longitude,
            locations[i].latitude, locations[i].longitude
        );
      }
      newSpots.add(FlSpot(i.toDouble(), double.parse(totalDistance.toStringAsFixed(2)))); // Create a spot for the chart.
    }

    setState(() {
      _spots = newSpots.isEmpty ? [FlSpot(0, 0)] : newSpots;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateDataForSelectedDate();   // Load data for the current date initially.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Adventure"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,  // The day the calendar is focused upon.
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;   // Update the selected day.
                _focusedDay = focusedDay;  // Update the focused day.
                _updateDataForSelectedDate(); // Refresh the data for the new selected day.
              });
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: _spots.isEmpty
                ? Center(child: Text("No data")) // Display message when no data is available.
                : Padding(
              padding: const EdgeInsets.all(8.0),  // Padding around the chart.
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: true),
                    )
                  ],
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toStringAsFixed(2)} km', style: TextStyle(fontSize: 10));  // Display distances with two decimal points.
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,  // Show grid lines.
                    drawVerticalLine: false,  // Disable vertical lines.
                    drawHorizontalLine: true, // Enable horizontal lines.
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  minX: 0, // Minimum value on the X-axis.
                  maxX: _spots.length.toDouble() - 1,  // Maximum value on the X-axis.
                  minY: 0,  // Minimum value on the Y-axis.
                  minY: 0,
                  maxY: _spots.isNotEmpty ? (_spots.map((spot) => spot.y).reduce(max) * 1.1).toDouble() : 1.0,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(selectedDate: _selectedDay), // Pass the selected date to the detail page.
                ),
              );
            },
            child: Text("Go to Details"),
          ),
        ],
      ),
    );
  }
}
