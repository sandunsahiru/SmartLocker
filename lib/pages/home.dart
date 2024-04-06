import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlocker/pages/services/session_manager.dart';
import 'package:smartlocker/pages/lock_unlock_buttons.dart';
import 'package:smartlocker/pages/battery_details.dart';
import 'package:smartlocker/pages/adddevice.dart';
import 'package:smartlocker/pages/settings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<String> _deviceNicknames = [];
  Map<String, String> _deviceIdMap = {};
  String? _selectedDeviceNickname;
  Future<String>? _usernameFuture;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      // User tapped on Home, do nothing or refresh the page if needed
    } else if (index == 1) {
      // User tapped on Settings, navigate to the SettingsPage
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserDevices();
  }

  void _loadUserDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionManager = SessionManager(prefs);
    String uid = sessionManager.getUserUID() ?? '';

    if (uid.isNotEmpty) {
      setState(() {
        _usernameFuture = _fetchUsername(uid);
      });

      var devicesQuerySnapshot = await FirebaseFirestore.instance
          .collection('devices')
          .where('userid', isEqualTo: uid)
          .get();

      _deviceNicknames.clear();
      _deviceIdMap.clear();

      for (var doc in devicesQuerySnapshot.docs) {
        String nickname = doc.data()['nickname'] as String;
        String deviceId = doc.data()['deviceid'] as String;
        _deviceNicknames.add(nickname);
        _deviceIdMap[nickname] = deviceId;
      }

      if (_deviceNicknames.isNotEmpty) {
        _selectedDeviceNickname = _deviceNicknames.first;
      }

      setState(() {});
    }
  }

  Future<String> _fetchUsername(String uid) async {
    var userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDocument.data()?['username'] ?? 'User';
  }



  void _handleDeviceSelectionChange(String deviceId) {
    // Here you could also update other widgets like BatteryDetails based on the selected device
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.openSans()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset('assets/logo.png'),
              SizedBox(height: 20),
              FutureBuilder<String>(
                future: _usernameFuture,
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  String welcomeText = 'Loading...';
                  if (snapshot.connectionState == ConnectionState.done) {
                    welcomeText = 'Welcome, ${snapshot.data}';
                  }
                  return Text(
                    welcomeText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              if (_selectedDeviceNickname != null)
                LockUnlockButtons(
                  deviceNicknames: _deviceNicknames,
                  deviceIdMap: _deviceIdMap,
                  onSelectedDeviceChanged: _handleDeviceSelectionChange,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddDevicePage(),
                  ));
                },
                child: Text('Add Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              // SizedBox(height: 30),
              // if (_selectedDeviceNickname != null)
              //   BatteryDetails(deviceId: _deviceIdMap[_selectedDeviceNickname] ?? ''),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
