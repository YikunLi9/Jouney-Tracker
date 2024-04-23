import 'package:flutter/material.dart';
import 'advanture_chart.dart';
import 'settings.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  // List of widget options corresponding to each bottom navigation item.
  static List<Widget> _widgetOptions = <Widget>[
    AdventureScreen(),
    HomeScreen(),
    SettingsScreen(),
  ];

  // Method to handle tapping on a bottom navigation item.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the currently selected tab index.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex), // Display the selected widget based on _selectedIndex.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_sharp),
            label: 'My Adventure',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Method called when a tab is tapped.
      ),
    );
  }
}
