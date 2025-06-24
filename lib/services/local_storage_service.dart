import 'dart:convert';
import 'package:elure_app/models/api_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userTokenKey = 'user_token';
  static const String _userDataKey = 'user_data';

  // Save the user authentication token
  Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTokenKey, token);
    print('User token saved: $token');
  }

  // Retrieve the user authentication token
  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_userTokenKey);
    print('Retrieved user token: $token');
    return token;
  }

  // Remove the user authentication token (on logout)
  Future<void> removeUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTokenKey);
    print('User token removed.');
  }

  // Save the user data (User object)
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert User object to JSON string for storage
    await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
    print('User data saved for: ${user.name}');
  }

  // Retrieve the user data
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      // Parse JSON string back to User object
      final Map<String, dynamic> userJson = jsonDecode(userDataString);
      final user = User.fromJson(userJson);
      print('Retrieved user data for: ${user.name}');
      return user;
    }
    print('No user data found locally.');
    return null;
  }

  // Remove user data (on logout)
  Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    print('User data removed.');
  }

  // Clear all stored data (e.g., on full logout)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All local data cleared.');
  }
}
