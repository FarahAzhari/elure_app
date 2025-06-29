import 'package:flutter/material.dart';
import 'package:elure_app/models/api_models.dart'; // Import API models for CheckoutData and CheckoutItem
import 'package:elure_app/screens/main_navigation_screen.dart'; // Import MainNavigationScreen for navigation
import 'package:confetti/confetti.dart'; // Import for confetti animation
import 'package:lottie/lottie.dart'; // Import Lottie package

class CheckoutSuccessScreen extends StatefulWidget {
  final CheckoutData? checkoutData; // Data from the successful checkout API call

  const CheckoutSuccessScreen({super.key, required this.checkoutData});

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen> with TickerProviderStateMixin {
  static const Color primaryPink = Color(0xFFE91E63);

  // Confetti controller
  late ConfettiController _confettiController;

  // Lottie animation URL (updated to a general animation)
  static const String _lottieSuccessUrl = 'https://lottie.host/c23b15d3-fa79-4ca4-92f6-d7a6969b10a8/xRgJihL3fC.json'; // A more general 'animation' Lottie file

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10)); // Made confetti duration longer (10 seconds)

    // Play confetti after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Stop the confetti controller before disposing it
    _confettiController.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if checkoutData is null (e.g., if navigated directly without data)
    if (widget.checkoutData == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.blueGrey, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'No checkout details available. Please complete a checkout process to see details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(), // Navigate to MainNavigationScreen
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Stack( // Use Stack to overlay confetti and Lottie animation
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                // Lottie Animation
                Center(
                  child: Lottie.network(
                    _lottieSuccessUrl,
                    width: 150, // Adjust size as needed
                    height: 150,
                    fit: BoxFit.contain,
                    repeat: true, // Changed to true for looping
                    onLoaded: (composition) {
                      // Optionally, you can add a delay or control when confetti plays
                      // if the Lottie animation has a specific point for "success".
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.check_circle, color: Colors.green, size: 100), // Fallback
                  ),
                ),
                const SizedBox(height: 10),
                // Thank you message
                const Center(
                  child: Text(
                    'Thank you, Your order has\nbeen received.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // PDF Receipt and Share Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildActionButton(
                      icon: Icons.picture_as_pdf_outlined,
                      text: 'PDF Receipt',
                      onTap: () => print('PDF Receipt clicked'),
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      text: 'Share',
                      onTap: () => print('Share clicked'),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // Increased space after buttons

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop all routes until the MainNavigationScreen is reached
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(), // Navigate to MainNavigationScreen
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Padding for bottom of screen
              ],
            ),
          ),
          // Confetti overlay at the top-center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // All directions
              shouldLoop: false, // Play once
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ], // Customize confetti colors
              createParticlePath: (size) { // Optional: Create a custom path for confetti shapes
                // Example: A simple square path
                return Path()
                  ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom AppBar for the Checkout Success Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Order Confirmation', // Changed title to reflect "Order Confirmation"
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: Colors.grey[700],
            size: 28,
          ),
          onPressed: () {
            print('Notifications Tapped from Checkout Success Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // Helper widget for PDF Receipt and Share buttons
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: primaryPink),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
