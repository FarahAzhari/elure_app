import 'package:elure_app/screens/cart/cashier_detail_screen.dart';
import 'package:flutter/material.dart'; // Import the new cashier detail screen

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  // Sample cart items. In a real app, this would be managed by a state management solution
  // and would reflect actual items added by the user.
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Purity Glow Face Wash',
      'brand': 'Pure Luxe',
      'originalPrice': 220.0,
      'currentPrice': 200.0,
      'imageUrl':
          'https://placehold.co/100x100/A2E69A/000000?text=FW', // Light green
      'quantity': 1,
      'isSelected': true,
    },
    {
      'id': '2',
      'name': 'Blemish-Free Toner',
      'brand': 'Radiant Clear',
      'originalPrice': 250.0,
      'currentPrice': 220.0,
      'imageUrl':
          'https://placehold.co/100x100/F0D0B5/000000?text=T', // Light brown
      'quantity': 1,
      'isSelected': false,
    },
    {
      'id': '3',
      'name': 'Acne Control Serum',
      'brand': 'Spotless Skin',
      'originalPrice': 320.0,
      'currentPrice': 280.0,
      'imageUrl':
          'https://placehold.co/100x100/DDA0DD/000000?text=S', // Light purple
      'quantity': 1,
      'isSelected': true,
    },
    {
      'id': '4',
      'name': 'Clarifying Clay Mask',
      'brand': 'Glow Clear',
      'originalPrice': 280.0,
      'currentPrice': 240.0,
      'imageUrl':
          'https://placehold.co/100x100/B0E0E6/000000?text=CM', // Light blue
      'quantity': 1,
      'isSelected': false,
    },
  ];

  // Calculate the total number of selected items
  int get _selectedItemCount =>
      _cartItems.where((item) => item['isSelected'] == true).length;

  // Calculate the total price of selected items
  double get _totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      if (item['isSelected'] == true) {
        total += item['currentPrice'] * item['quantity'];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: _buildSearchBar(), // Search bar
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItemCard(_cartItems[index], index);
              },
            ),
          ),
          _buildBottomSummary(), // Total summary and action buttons
        ],
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
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'View Cart',
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
            print('Notifications Tapped from Cart Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
            onPressed: () {
              print('Camera search tapped');
            },
          ),
        ],
      ),
    );
  }

  // Builds an individual cart item card
  Widget _buildCartItemCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Space between cards
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Item Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(item['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Item Name
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                // Item Brand
                Text(
                  item['brand'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                // Price and Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prices
                    Row(
                      children: [
                        Text(
                          '\$${item['originalPrice'].toStringAsFixed(0)}', // Original price
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${item['currentPrice'].toStringAsFixed(0)}', // Current price
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // Quantity Selector
                    _buildQuantitySelector(item, index),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Checkbox (or custom radio button)
          _buildSelectionCircle(item['isSelected'], index),
        ],
      ),
    );
  }

  // Builds the quantity selector for a cart item
  Widget _buildQuantitySelector(Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content tightly
        children: [
          IconButton(
            iconSize: 20,
            constraints: const BoxConstraints(), // Remove default padding
            padding: const EdgeInsets.all(5),
            icon: const Icon(Icons.remove, color: Colors.black),
            onPressed: () {
              setState(() {
                if (item['quantity'] > 1) {
                  _cartItems[index]['quantity']--;
                }
              });
            },
          ),
          Text(
            item['quantity'].toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            iconSize: 20,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(5),
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              setState(() {
                _cartItems[index]['quantity']++;
              });
            },
          ),
        ],
      ),
    );
  }

  // Builds the custom selection circle (checkbox replacement)
  Widget _buildSelectionCircle(bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _cartItems[index]['isSelected'] = !isSelected;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? primaryPink : Colors.transparent,
          border: Border.all(
            color: isSelected ? primaryPink : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  // Builds the bottom summary bar with total price and action buttons
  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ), // Rounded top corners
      ),
      child: Row(
        children: <Widget>[
          // Total items count and price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryPink,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Text(
                    '$_selectedItemCount', // Display count of selected items
                    style: TextStyle(
                      color: primaryPink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Chat Icon Button (Placeholder for message)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                print('Chat button clicked');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Icon(Icons.chat_bubble_outline, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 10),
          // Buy Now Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to CashierDetailScreen when Buy Now is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CashierDetailScreen(),
                  ),
                );
                print('Buy Now from Cart clicked');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
