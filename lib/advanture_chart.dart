import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'advanture_map.dart';
import 'database_util.dart';

import 'dart:math';

class AdventureScreen extends StatefulWidget {
  @override
  _AdventureScreenState createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<FlSpot> _spots = [];

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;    // Math.PI / 180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2)); // 2 * R; R = 6371 km, round to 2 decimal places
  }


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
      newSpots.add(FlSpot(i.toDouble(), double.parse(totalDistance.toStringAsFixed(2)))); // 确保距离为两位小数
    }

    setState(() {
      _spots = newSpots.isEmpty ? [FlSpot(0, 0)] : newSpots;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateDataForSelectedDate();  // 在初始化时加载当天的数据
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
            focusedDay: _focusedDay,  // 使用 _focusedDay 替换 DateTime.now()
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;  // 更新选中的日期
                _focusedDay = focusedDay;  // 同时更新焦点日期
                _updateDataForSelectedDate();
              });
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: _spots.isEmpty
                ? Center(child: Text("无数据"))
                : Padding(
              padding: const EdgeInsets.all(8.0),  // 增加整体内边距
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
                      sideTitles: SideTitles(showTitles: false), // 删除上方标题
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // 删除右方标题
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // 删除底部 X 轴标题
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toStringAsFixed(2)} km', style: TextStyle(fontSize: 10));  // 保留两位小数
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,  // 不绘制垂直线
                    drawHorizontalLine: true,  // 绘制水平线
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  minX: 0,
                  maxX: _spots.length.toDouble() - 1,
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
                  builder: (_) => DetailPage(selectedDate: _selectedDay),
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
