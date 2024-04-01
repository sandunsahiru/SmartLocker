import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userUIDKey = 'user_uid';

  final SharedPreferences _prefs;

  SessionManager(this._prefs);

  Future<void> setUserUID(String uid) async {
    await _prefs.setString(_userUIDKey, uid);
  }

  String? getUserUID() {
    return _prefs.getString(_userUIDKey);
  }

  Future<void> clearUserUID() async {
    await _prefs.remove(_userUIDKey);
  }
}
