import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartlocker/pages/home.dart'; // Replace with your actual home page
import 'package:smartlocker/pages/services/session_manager.dart'; // Replace with your actual SessionManager file path
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  SessionManager? _sessionManager;

  @override
  void initState() {
    super.initState();
    _initializeSessionManager();
  }

  void _initializeSessionManager() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionManager = SessionManager(prefs);
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      // Sign in the user with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;

      // If we have a UID, save it using SessionManager
      if (uid != null && _sessionManager != null) {
        await _sessionManager!.setUserUID(uid);
      }

      // Navigate to the HomePage after successful login
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      // Handle errors such as wrong password, user not found, etc.
      final snackBar = SnackBar(content: Text('Error: ${e.message}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors as per your UI design
    const Color primaryColor = Color(0xFF5356FF); // Adjust the color as needed
    const Color accentColor = Color(0xFF67C6E3); // Adjust the color as needed

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo
              Image.asset('assets/logo2.png'),
              SizedBox(height: 20),
              Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 30),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              // Login Button
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
