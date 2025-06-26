import 'package:elure_app/models/api_models.dart'; // Import API models for CheckoutData and CheckoutItem
import 'package:elure_app/screens/home_screen.dart'; // Import HomeScreen to navigate back
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class CheckoutScreen extends StatelessWidget {
  final CheckoutData?
  checkoutData; // Data from the successful checkout API call

  const CheckoutScreen({super.key, required this.checkoutData});

  static const Color primaryPink = Color(0xFFE91E63);

  @override
  Widget build(BuildContext context) {
    // Check if checkoutData is null (e.g., if navigated directly without data)
    if (checkoutData == null) {
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
                        builder: (context) => const HomeScreen(),
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

    // Format date if available
    final String formattedDate = checkoutData?.createdAt != null
        ? DateFormat(
            'MMMM dd,yyyy',
          ).format(DateTime.parse(checkoutData!.createdAt!))
        : 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
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
            const SizedBox(height: 30),

            // Payment Details Section
            _buildSectionTitle('Payment Details'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children: [
                _buildDetailRow(
                  'Amount',
                  '\$${checkoutData!.total?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _buildDetailRow(
                  'Order number',
                  checkoutData!.id?.toString() ?? 'N/A',
                ),
                _buildDetailRow('Date', formattedDate),
                _buildDetailRow(
                  'Payment method',
                  'Cash payment on delivery',
                ), // Static as per original design
              ],
            ),
            const SizedBox(height: 30),

            // Order Details Section
            _buildSectionTitle('Order Details'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children:
                  checkoutData!.items?.map((item) {
                    final productName = item.product?.name ?? 'Unknown Product';
                    final quantity = item.quantity ?? 0;
                    final price = item.product?.price ?? 0;
                    final totalItemPrice = (quantity * price).toStringAsFixed(
                      2,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildDetailRow(
                        '$productName x $quantity',
                        '\$$totalItemPrice',
                        isMultiLine: true,
                      ),
                    );
                  }).toList() ??
                  [
                    const Text(
                      'No order items found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
            ),
            const SizedBox(height: 30),

            // Addresses Section (static placeholder as API does not provide address details in CheckoutData)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Billing address'),
                      const SizedBox(height: 10),
                      _buildAddressCard(
                        'Asif Asif IQBAL\n12 Rue Mohamed V\nApartment 3B\nCasablanca\nMAAZI',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Delivery address'),
                      const SizedBox(height: 10),
                      _buildAddressCard(
                        'Asif Asif IQBAL\n12 Rue Mohamed V\nApartment 3B\nCasablanca\nMAAZI',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // Space before bottom button
            // Back to Home Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Pop all routes until the HomeScreen is reached
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    );
  }

  // Custom AppBar for the Checkout Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(context); // Go back to the previous screen (CartScreen)
        },
      ),
      title: const Text(
        'Checkout details', // Changed title to reflect "Checkout"
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
            print('Notifications Tapped from Checkout Screen');
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

  // Helper widget for section titles (e.g., Payment Details, Order Details)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // Helper widget for a card containing details (Payment Details, Order Details)
  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Helper widget for a single row of detail (e.g., Amount: $960.00)
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: isMultiLine
          ? const EdgeInsets.symmetric(vertical: 5.0)
          : const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for address cards
  Widget _buildAddressCard(String address) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        address,
        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
      ),
    );
  }
}
