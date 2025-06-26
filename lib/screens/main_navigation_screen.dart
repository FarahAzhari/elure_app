import 'package:elure_app/screens/auth/profile_screen.dart';
import 'package:elure_app/screens/brand/brand_screen.dart';
import 'package:elure_app/screens/category/category_screen.dart';
import 'package:elure_app/screens/home_screen.dart';
import 'package:elure_app/screens/report/history_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Define the primary pink color for consistency
  static const Color primaryPink = Color(0xFFE91E63);

  // State variable to manage the current index of the bottom navigation bar
  int _selectedIndex = 0;

  // List of screens to be displayed in the IndexedStack
  final List<Widget> _pages = [
    const HomeScreen(), // Your existing home screen content
    const CategoryScreen(),
    const BrandScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  // Helper function to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will display the widget corresponding to the selected index
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // The persistent bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Builds the Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white, // White background
      selectedItemColor: primaryPink, // Pink for selected icon/label
      unselectedItemColor: Colors.grey[600], // Grey for unselected
      currentIndex:
          _selectedIndex, // Use the state variable for the current index
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
      showSelectedLabels: true, // Always show labels for selected item
      showUnselectedLabels: true, // Always show labels for unselected items
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: _onItemTapped, // Call the handler function
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.diamond_outlined,
          ), // Using diamond as placeholder for Brands
          label: 'Brands',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history), // New icon for History
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          label: 'Profile',
        ),
      ],
    );
  }
}
