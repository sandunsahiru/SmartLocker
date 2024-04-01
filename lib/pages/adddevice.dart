import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartlocker/pages/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AddDevicePage extends StatefulWidget {
  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _nicknameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionManager = SessionManager(prefs);
    _userId = sessionManager.getUserUID();
  }

  Future<void> _addDevice() async {
    if (_userId != null && _nicknameController.text.isNotEmpty && _deviceIdController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('devices').add({
        'nickname': _nicknameController.text,
        'deviceid': _deviceIdController.text,
        'userid': _userId,
      });

      // Show a success message or navigate away
      Navigator.pop(context);
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required and you must be logged in.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Device', style: GoogleFonts.openSans()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Enter Device Details',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _deviceIdController,
                decoration: InputDecoration(
                  labelText: 'Device ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _addDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Add Device', style: GoogleFonts.openSans()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
