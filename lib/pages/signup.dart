import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartlocker/pages/login.dart'; // Make sure this import points to your LoginPage

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _registerAccount() async {
    try {
      // Create the user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the user's UID
      final String uid = userCredential.user!.uid;

      // Add the user details to Firestore under the 'users' collection with the UID as the document ID
      await _firestore.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        // Add additional fields as needed
      });

      // Navigate to LoginPage after successful signup
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } on FirebaseAuthException catch (e) {
      // Handle errors, such as email already in use, weak password, etc.
      // Show an error message using a dialog or a snackbar
      final snackBar = SnackBar(content: Text('Error: ${e.message}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors as per your UI design
    const Color primaryColor = Color(0xFF5356FF);
    const Color accentColor = Color(0xFF67C6E3);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo and Sign Up Text
              Image.asset('assets/logo2.png'),
              SizedBox(height: 20),
              Text(
                'Create New Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Login text button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text(
                  'Already registered? Login',
                  style: TextStyle(
                    color: accentColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                ),
              ),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: primaryColor),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                ),
                obscureText: true,
              ),
              // Sign Up Button
              ElevatedButton(
                onPressed: _registerAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor, // background (button) color
                  foregroundColor: Colors.white, // foreground (text) color
                ),
                child: Text('SIGN UP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
