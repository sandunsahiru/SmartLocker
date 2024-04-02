import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlocker/pages/services/session_manager.dart';
import 'package:smartlocker/pages/settings.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isProcessing = false;
  late final SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _sessionManager = SessionManager(prefs); // Initialize your SessionManager with SharedPreferences
  }

  Future<void> _changePassword() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New passwords do not match")));
      setState(() => _isProcessing = false);
      return;
    }

    String? uid = _sessionManager.getUserUID(); // Get UID from your SessionManager
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User ID not found")));
      setState(() => _isProcessing = false);
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password successfully updated")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unable to update password. User not authenticated")));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildPasswordTextField(
              controller: _currentPasswordController,
              labelText: 'Current Password',
              icon: Icons.lock_outline,
            ),
            SizedBox(height: 16),
            _buildPasswordTextField(
              controller: _newPasswordController,
              labelText: 'New Password',
              icon: Icons.lock,
            ),
            SizedBox(height: 16),
            _buildPasswordTextField(
              controller: _confirmNewPasswordController,
              labelText: 'Confirm New Password',
              icon: Icons.lock,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _changePassword,
              child: _isProcessing ? CircularProgressIndicator() : Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}
