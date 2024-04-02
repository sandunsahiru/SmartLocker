import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlocker/pages/services/session_manager.dart';
import 'package:smartlocker/pages/home.dart';
import 'package:smartlocker/pages/account.dart';
import 'package:smartlocker/pages/password_change.dart';
import 'package:smartlocker/pages/login.dart';

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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }


  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Card(
                child: ListTile(
                  title: Text('Account'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AccountPage(),
                    ));
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Password & Security'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChangePasswordPage(),
                    ));
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
        currentIndex: 1,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (int index) {
          if (index == 0) {
            _navigateToHome();
          }
          // Other index handling can go here if more items are added
        },
      ),
    );
  }
}
