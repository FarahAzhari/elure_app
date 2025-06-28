import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elure_app/models/api_models.dart'; // Import your API models (changed from your_app_name/api_models.dart)

class LocalStorageService {
  static const String _userTokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _recentSearchesKey =
      'recent_searches'; // New key for recent searches
  static const int _maxRecentSearches =
      5; // Limit to keep the list from growing too large

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

  // Save a recent search query
  // This method now intelligently adds/moves the query to the top and limits the list size.
  Future<void> saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];

    // Remove duplicates and move the latest search to the top
    searches.remove(query);
    searches.insert(0, query);

    // Keep only the most recent searches
    if (searches.length > _maxRecentSearches) {
      searches = searches.sublist(0, _maxRecentSearches);
    }

    await prefs.setStringList(_recentSearchesKey, searches);
    print('Recent search saved: "$query". Current list: $searches');
  }

  // NEW: Remove a specific recent search query
  Future<void> removeSpecificRecentSearch(String queryToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];

    // Remove the specified query
    final bool removed = searches.remove(queryToRemove);

    if (removed) {
      await prefs.setStringList(_recentSearchesKey, searches);
      print('Recent search "$queryToRemove" removed. Current list: $searches');
    } else {
      print('Recent search "$queryToRemove" not found in list.');
    }
  }

  // Retrieve recent search queries
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    print('Retrieved recent searches: $searches');
    return searches;
  }

  // Clear all stored data (e.g., on full logout)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All local data cleared.');
  }
}
