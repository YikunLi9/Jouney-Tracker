import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'advanture_map.dart';

class AdventureScreen extends StatefulWidget {
  @override
  _AdventureScreenState createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  DateTime _selectedDay = DateTime.now();

  List<FlSpot> _spots = [
    FlSpot(0, 1),
    FlSpot(1, 3),
    FlSpot(2, 10),
    FlSpot(3, 7),
    FlSpot(4, 9),
    FlSpot(5, 15),
  ];

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
            focusedDay: DateTime.now(),
          ),
          SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(spots: _spots)
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigation logic to detail page
              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage()));
            },
            child: Text("Go to Details"),
          )
        ],
      ),
    );
  }
}
