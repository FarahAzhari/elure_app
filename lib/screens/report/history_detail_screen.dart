import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elure_app/models/api_models.dart'; // Import API models for HistoryItem, CheckoutItem, CartProduct
import 'package:elure_app/screens/main_navigation_screen.dart'; // For back to home navigation

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem historyItem; // The specific history item to display

  const HistoryDetailScreen({super.key, required this.historyItem});

  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  @override
  Widget build(BuildContext context) {
    // Format date if available
    final String formattedDate = historyItem.createdAt != null
        ? DateFormat(
            'MMMM dd, yyyy',
          ).format(DateTime.parse(historyItem.createdAt!))
        : 'N/A';

    // Initialize NumberFormat for Rupiah (IDR) with dot as thousands separator
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp', // Rupiah symbol
      decimalDigits: 0, // No decimal digits for whole rupiah
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            // Order ID and Date
            Center(
              child: Column(
                children: [
                  Text(
                    'Order ID: ${historyItem.id ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // PDF Receipt and Share Buttons (reusing from CheckoutScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  text: 'PDF Receipt',
                  onTap: () => print(
                    'PDF Receipt clicked for Order ID ${historyItem.id}',
                  ),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  text: 'Share',
                  onTap: () =>
                      print('Share clicked for Order ID ${historyItem.id}'),
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
                  currencyFormatter.format(historyItem.total ?? 0),
                ),
                _buildDetailRow(
                  'Order number',
                  historyItem.id?.toString() ?? 'N/A',
                ),
                _buildDetailRow('Date', formattedDate),
                _buildDetailRow(
                  'Payment method',
                  'Cash payment on delivery',
                ), // Static as per original design
              ],
            ),
            const SizedBox(height: 30),

            // Order Details Section (iterating through historyItem.items)
            _buildSectionTitle('Order Details'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children:
                  historyItem.items?.map((item) {
                    final productName = item.product?.name ?? 'Unknown Product';
                    final quantity = item.quantity ?? 0;
                    final originalPrice = item.product?.price ?? 0;
                    final discount = item.product?.discount;

                    // Calculate price after discount
                    double priceAfterDiscount = originalPrice.toDouble();
                    if (discount != null && discount > 0) {
                      priceAfterDiscount =
                          originalPrice * (1 - (discount / 100));
                    }

                    final itemSubtotal = currencyFormatter.format(
                      priceAfterDiscount * quantity,
                    );

                    // Determine image URL
                    String? rawImageUrl = item.product?.imageUrl;
                    String imageUrlToDisplay;

                    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
                      if (rawImageUrl.startsWith('http://') ||
                          rawImageUrl.startsWith('https://')) {
                        imageUrlToDisplay = rawImageUrl;
                      } else {
                        imageUrlToDisplay = '$_baseUrl$rawImageUrl';
                      }
                    } else {
                      imageUrlToDisplay =
                          'https://placehold.co/80x80/FFC0CB/000000?text=Product';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrlToDisplay,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (discount != null && discount > 0) ...[
                                  Text(
                                    currencyFormatter.format(originalPrice),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  currencyFormatter.format(priceAfterDiscount),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                if (discount != null && discount > 0)
                                  Text(
                                    '${discount.toInt()}% Off',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: $quantity',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subtotal: $itemSubtotal',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: primaryPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

            // Addresses Section (static placeholder as API does not provide address details in HistoryItem)
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
                        'Jl. Merdeka No. 45, RT. 03/ RW. 02,\nGambir Subdistrict, Gambir District,\nCentral Jakarta, 10110, Indonesia',
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
                        'Jl. Merdeka No. 45, RT. 03/ RW. 02,\nGambir Subdistrict, Gambir District,\nCentral Jakarta, 10110, Indonesia',
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
                  // Pop all routes until the MainNavigationScreen is reached
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
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
    );
  }

  // Custom AppBar for the History Detail Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(
            context,
          ); // Go back to the previous screen (HistoryScreen)
        },
      ),
      title: const Text(
        'Order Details',
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
            print('Notifications Tapped from History Detail Screen');
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
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
