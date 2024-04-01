import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartlocker/pages/signup.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set a background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset('assets/logo2.png'), // Display the logo image
              SizedBox(height: 24),
              Text(
                'Welcome to IntelliLock!',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Use the primary color from the app's theme
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your ultimate solution for securely storing your valuables with the added peace of mind of GPS tracking. Our app offers seamless control and monitoring of your safe box from anywhere, anytime.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.grey[600], // Use a color suitable for the text
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity, // Make the button take full width of the screen
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Use the primary color from the app's theme
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: Colors.white, // Text color for buttons is typically white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
