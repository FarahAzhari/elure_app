import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/screens/main_navigation_screen.dart';
import 'package:elure_app/screens/welcome_screen.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized for SharedPreferences
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isCheckingAuth =
      true; // State to indicate if authentication status is being checked
  bool _isLoggedIn = false; // State to hold login status

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Check authentication status on app startup
  }

  // Function to check if the user is already logged in
  Future<void> _checkAuthStatus() async {
    final String? token = await _localStorageService.getUserToken();
    final User? user = await _localStorageService
        .getUserData(); // Assuming User model is retrieved

    setState(() {
      // If both token and user data exist, consider the user logged in
      _isLoggedIn = token != null && user != null;
      _isCheckingAuth = false; // Finished checking auth status
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: 'Elure App', // Changed title to reflect the app name
      theme: ThemeData(
        // Using `primarySwatch` for a consistent pink color theme
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Applying Inter font as previously discussed
        // Remove colorScheme.fromSeed to use primarySwatch more directly
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Removed
      ),
      // The `home` property will dynamically select the initial screen
      home: _isCheckingAuth
          ? const _SplashScreen() // Show splash screen while checking auth
          : (_isLoggedIn
                ? const MainNavigationScreen()
                : const WelcomeScreen()), // Navigate based on auth status
    );
  }
}

// A simple splash screen widget to show while checking authentication status
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFE91E63), // Primary pink color for indicator
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
