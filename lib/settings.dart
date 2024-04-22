import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'database_util.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _exportData() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final List<Map<String, dynamic>> data = await DatabaseHelper.instance.getAllLocations();
      List<List<dynamic>> csvData = [
        ['ID', 'Latitude', 'Longitude', 'Timestamp'], // CSV headers
      ];
      for (var row in data) {
        csvData.add([row['id'], row['latitude'], row['longitude'], row['timestamp']]);
      }
      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getExternalStorageDirectory();
      final path = directory!.path + "/exported_data.csv";
      final file = File(path);
      await file.writeAsString(csv);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Export Successful"),
          content: Text("Data exported to $path"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Permission Denied"),
          content: Text("Storage permission is needed to export data."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _deleteData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete all data? This action cannot be undone."),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                await DatabaseHelper.instance.deleteAllLocations();
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Data Deleted"),
                    content: Text("All data has been deleted successfully."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.grey[300], // Light gray
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://example.com/user_avatar.png'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text('Days of Use: 365', style: TextStyle(fontSize: 16, color: Colors.black54)),
                          Text('Total Travel Distance: 1234 km', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                buttonPadding: EdgeInsets.symmetric(horizontal: 20),
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: Icon(Icons.file_download),
                    label: Text('Export Data'),
                    onPressed: _exportData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[200]), // Use light blue-gray
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Delete Data'),
                    onPressed: _deleteData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[200]), // Same light blue-gray
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.map, color: Colors.blueGrey[400]),
                title: Text('Map Theme', style: TextStyle(color: Colors.black87)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blueGrey[400]),
                title: Text('About', style: TextStyle(color: Colors.black87)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
