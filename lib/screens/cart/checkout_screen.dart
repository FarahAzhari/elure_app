import 'package:elure_app/screens/cart/checkout_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:elure_app/models/api_models.dart'; // For CartItem, CheckoutData, ErrorResponse
import 'package:elure_app/services/api_service.dart'; // For ApiService
import 'package:intl/intl.dart'; // For currency formatting

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal; // Subtotal calculated in CartScreen

  const CheckoutScreen({super.key, required this.cartItems, required this.subtotal});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  final ApiService _apiService = ApiService();

  // Hardcoded address and payment method as per your request
  final String _billingAddress = 'Jl. Merdeka No. 45, RT. 03/ RW. 02,\nGambir Subdistrict, Gambir District,\nCentral Jakarta, 10110, Indonesia';
  final String _deliveryAddress = 'Jl. Merdeka No. 45, RT. 03/ RW. 02,\nGambir Subdistrict, Gambir District,\nCentral Jakarta, 10110, Indonesia';
  final String _paymentMethod = 'Cash payment on delivery';

  bool _isProcessingCheckout = false;

  Future<void> _handlePayNow() async {
    setState(() {
      _isProcessingCheckout = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing payment...')),
    );

    try {
      // Call the checkout API
      final CheckoutResponse response = await _apiService.checkout();

      if (mounted) {
        if (response.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
          // On successful checkout, navigate to the CheckoutSuccessScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => CheckoutSuccessScreen(checkoutData: response.data),
            ),
            (Route<dynamic> route) => false, // Clear all previous routes
          );
        } else {
          // Handle cases where response is successful but data is null (e.g., no order created)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        if (e.errors != null) {
          // Attempt to parse validation errors if available
          errorMessage += '\nDetails: ${e.errors!.toJson()}'; // Convert errors to string
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout Error: $errorMessage')),
        );
        print('Checkout Error: $errorMessage');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred during checkout: ${e.toString()}')),
        );
        print('Unexpected Checkout Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Confirm your order',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Order Summary Section
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children: [
                ...widget.cartItems.map((item) {
                  final productName = item.product?.name ?? 'Unknown Product';
                  final quantity = item.quantity ?? 0;
                  final int originalPricePerUnit = item.product?.price ?? 0;
                  final int discountPercentage = item.product?.discount ?? 0;

                  double discountedPricePerUnit = originalPricePerUnit.toDouble();
                  if (discountPercentage > 0) {
                    discountedPricePerUnit = originalPricePerUnit * (1 - discountPercentage / 100);
                  }

                  final totalOriginalItemPrice = (originalPricePerUnit * quantity).toDouble();
                  final totalDiscountedItemPrice = (discountedPricePerUnit * quantity).toDouble();

                  // Format the discounted price per piece
                  final String formattedPricePerPiece = currencyFormatter.format(discountedPricePerUnit);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildDetailRow(
                      '$productName x $quantity ($formattedPricePerPiece/pc)', // Updated label to include price per PC
                      currencyFormatter.format(totalDiscountedItemPrice),
                      originalValue: (originalPricePerUnit > 0 && discountPercentage > 0)
                          ? currencyFormatter.format(totalOriginalItemPrice)
                          : null, // Only pass originalValue if there's a discount
                      isMultiLine: true,
                    ),
                  );
                }).toList(),
                const Divider(), // Separator
                _buildDetailRow(
                  'Subtotal',
                  currencyFormatter.format(widget.subtotal),
                  isBold: true,
                ),
                _buildDetailRow(
                  'Shipping Fee',
                  currencyFormatter.format(0), // Hardcoded 0 for now
                  isBold: true,
                ),
                const Divider(), // Separator
                _buildDetailRow(
                  'Total Amount',
                  currencyFormatter.format(widget.subtotal), // Assuming no shipping fee for now
                  isBold: true,
                  isPrimaryPink: true,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Addresses Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Billing Address'),
                      const SizedBox(height: 10),
                      _buildAddressCard(_billingAddress),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Delivery Address'),
                      const SizedBox(height: 10),
                      _buildAddressCard(_deliveryAddress),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Payment Method Section
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children: [
                _buildDetailRow(
                  'Method',
                  _paymentMethod,
                ),
                // Add an option to change payment method if desired
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => print('Change payment method tapped'),
                    child: const Text(
                      'Change',
                      style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessingCheckout ? null : _handlePayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isProcessingCheckout
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(context); // Go back to CartScreen
        },
      ),
      title: const Text(
        'Checkout',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[700], size: 28),
          onPressed: () {
            print('Notifications Tapped from Checkout Confirmation');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

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

  Widget _buildDetailRow(String label, String value, {String? originalValue, bool isMultiLine = false, bool isBold = false, bool isPrimaryPink = false}) {
    return Padding(
      padding: isMultiLine ? const EdgeInsets.symmetric(vertical: 5.0) : const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Flexible(
            child: Column( // Use Column for value part to stack original and discounted prices
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (originalValue != null && originalValue.isNotEmpty)
                  Text(
                    originalValue,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough, // Strikethrough for original price
                    ),
                  ),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: isPrimaryPink ? primaryPink : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
