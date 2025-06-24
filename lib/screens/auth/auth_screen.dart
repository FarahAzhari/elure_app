import 'package:elure_app/screens/auth/login_tab.dart';
import 'package:elure_app/screens/auth/signup_tab.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  // Added TickerProviderStateMixin here
  // Define the primary pink color used in the design.
  // This helps maintain consistency across the app.
  static const Color primaryPink = Color(0xFFE91E63);

  // Controller for the TabBar and TabBarView.
  // It allows programmatically changing the selected tab.
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs.
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 'this' refers to TickerProviderStateMixin
  }

  @override
  void dispose() {
    // Dispose the TabController when the state is removed to free up resources.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // SafeArea ensures content doesn't overlap with system UI (e.g., notch, status bar).
        child: SingleChildScrollView(
          // SingleChildScrollView allows the content to be scrollable if it
          // overflows, which is crucial for soft keyboards on smaller devices.
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ), // Adjusted vertical padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // "Welcome back" text
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                // Subtitle text
                const Text(
                  'Welcome! Log in or sign up to enjoy\nour platform\'s full benefits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Custom Tab Bar for Log In / Sign Up
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors
                        .grey[200], // Background color for the tab bar container
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                    // Optional: subtle border if needed, but the image suggests none or very faint
                    // border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize
                        .tab, // Makes indicator fit the tab size
                    indicator: BoxDecoration(
                      color: Colors
                          .white, // Indicator color when a tab is selected
                      borderRadius: BorderRadius.circular(25),
                      // Removed boxShadow to match the flatter look of the image
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ), // Added padding for the selected tab
                    labelColor:
                        primaryPink, // Color for the selected tab's text
                    unselectedLabelColor:
                        Colors.grey[600], // Color for unselected tabs' text
                    dividerColor: Colors
                        .transparent, // Explicitly remove the line below the tabs
                    tabs: const [
                      Tab(text: 'Log in'),
                      Tab(text: 'Sign up'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ), // Adjusted space between tab bar and content
                // TabBarView to display the content of the selected tab
                SizedBox(
                  height:
                      600, // Fixed height for the TabBarView. Adjust as needed.
                  // Consider using a more dynamic height or expanding to fit content
                  // if the content varies significantly.
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      LoginTab(), // The login form content
                      SignUpTab(), // The sign-up form content
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
