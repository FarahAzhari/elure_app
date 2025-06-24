import 'package:elure_app/screens/auth/auth_screen.dart';
import 'package:elure_app/utils/app_constant.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your pink color
    const Color primaryPink = Color(
      0xFFE91E63,
    ); // Example pink, adjust as needed

    return Scaffold(
      backgroundColor:
          Colors.white, // Or a very light pink if that's the background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        title: const Text(
          'Élure',
          style: TextStyle(
            color: Colors.black, // Adjust color as per design
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true, // Center the title
        // You might need to adjust leading/actions if there are specific icons for status bar
        // For the status bar time and icons, Flutter generally handles them automatically.
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            // Spacer to push content down from app bar
            const SizedBox(height: 50),

            // Circular Image
            Container(
              width: 250, // Adjust size as needed
              height: 250, // Adjust size as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryPink, // Background color for the oval
                border: Border.all(
                  color: primaryPink, // Pink border
                  width: 4, // Border thickness
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  AppImage.logo, // Replace with your image path
                  fit: BoxFit.cover, // Ensures the image covers the oval
                ),
              ),
            ),

            const SizedBox(height: 60), // Space between image and text
            // Discover Beauty Text
            const Text(
              'Luminous Beauty,\nLightly Touched.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20), // Space between titles
            // Description Text
            const Text(
              'Beauty at your fingertips effortlessly access\nskincare makeup and self-care essentials anytime\nwherever you go!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Adjust color as needed
              ),
            ),

            const Spacer(), // Pushes the button to the bottom
            // Get Started Button
            Padding(
              padding: const EdgeInsets.only(
                bottom: 40.0,
              ), // Padding from the bottom
              child: SizedBox(
                width: double.infinity, // Make button full width
                height: 60, // Set button height
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                    print('Get Started Pressed!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Button text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
