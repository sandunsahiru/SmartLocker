import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlocker/pages/services/session_manager.dart';
import 'package:smartlocker/pages/home.dart'; // Assuming this is the file with your HomePage

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _initializeSessionManager();
  }

  Future<void> _initializeSessionManager() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sessionManager = SessionManager(prefs);
  }

  void _logout() async {
    await _sessionManager.clearUserUID();
    // Navigate back to the login page or handle the logout accordingly
  }

  void _navigateToHome() {
    // Assuming your HomePage is the main route '/'
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Account'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Handle account settings navigation
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Password & Security'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Handle password and security navigation
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('About'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Handle about navigation
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Log Out'),
              trailing: Icon(Icons.exit_to_app),
              onTap: _logout,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue, // or your theme primary color
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.grey, // or your theme secondary color
          ),
        ],
        currentIndex: 1, // Assuming Settings is the second item
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (int index) {
          if (index == 0) {
            _navigateToHome();
          }
        },
      ),
    );
  }
}
