import 'package:elure_app/screens/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
// Import the new product detail screen

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);

  // Sample product data, filtered by categoryName in a real app.
  // For now, this is static dummy data to show the layout.
  final List<Map<String, String>> _products = [
    {
      'name': 'Hair Cartoon',
      'brand': 'Glowora',
      'originalPrice': '\$40.00',
      'currentPrice': '\$27.00',
      'discount': '20%',
      'imageUrl': 'https://placehold.co/150x150/ADD8E6/000000?text=P1',
    },
    {
      'name': 'Nourkrin Femme...',
      'brand': 'Luscenta',
      'originalPrice': '\$50.00',
      'currentPrice': '\$35.00',
      'discount': '20%',
      'imageUrl': 'https://placehold.co/150x150/90EE90/000000?text=P2',
    },
    {
      'name': 'Dior Bronze Afte...',
      'brand': 'Bloomelle',
      'originalPrice': '\$40.00',
      'currentPrice': '\$27.00',
      'discount': '20%',
      'imageUrl': 'https://placehold.co/150x150/FFB6C1/000000?text=P3',
    },
    {
      'name': 'Face Primer Tube...',
      'brand': 'Naturae',
      'originalPrice': '\$50.00',
      'currentPrice': '\$35.00',
      'discount': '20%',
      'imageUrl': 'https://placehold.co/150x150/DDA0DD/000000?text=P4',
    },
    {
      'name': 'Spray Bottle - Ba...',
      'brand': 'Skinova',
      'originalPrice': '\$40.00',
      'currentPrice': '\$27.00',
      'discount': '20%',
      'imageUrl': 'https://placehold.co/150x150/B0E0E6/000000?text=P5',
    },
    {
      'name': 'Nourkrin Femme...',
      'brand': 'Beautifique',
      'originalPrice': '\$50.00',
      'currentPrice': '\$35.00',
      'discount': '20%',
      'imageUrl': 'https://placehold.co/150x150/F08080/000000?text=P6',
    },
    // Add more dummy products here if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context), // Custom App Bar for this screen
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: _buildSearchBar(), // Search bar
            ),
            const SizedBox(height: 20),
            // Grid of products for the selected category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildProductGrid(),
            ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // Custom AppBar for the Category Detail Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ), // Back button
        onPressed: () {
          Navigator.pop(
            context,
          ); // Go back to the previous screen (CategoryScreen)
        },
      ),
      title: Text(
        widget.categoryName, // Display the category name passed to the screen
        style: const TextStyle(
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
          ), // Notification icon
          onPressed: () {
            print('Notifications Tapped from Category Detail Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // Builds the Search Bar (reused for consistency)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light grey background
        borderRadius: BorderRadius.circular(30), // Rounded corners
        border: Border.all(color: Colors.grey[200]!), // Light border
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, color: Colors.grey[600]), // Search icon
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none, // No underline
                isDense: true, // Reduce vertical space
                contentPadding: EdgeInsets.zero, // Remove internal padding
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.grey[600],
            ), // Camera icon
            onPressed: () {
              print('Camera search tapped');
            },
          ),
        ],
      ),
    );
  }

  // Builds the grid of products
  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true, // Take only as much space as needed
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling within the grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        crossAxisSpacing: 15, // Horizontal spacing
        mainAxisSpacing: 15, // Vertical spacing
        childAspectRatio:
            0.75, // Aspect ratio of each grid item (adjusted to fit product info)
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  // Helper widget to build individual product cards (similar to HomeScreen)
  Widget _buildProductCard(Map<String, String> product) {
    return GestureDetector(
      // Added GestureDetector here
      onTap: () {
        print('Tapped on product: ${product['name']}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background for the card
          borderRadius: BorderRadius.circular(15), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Product Image with Discount Tag and Heart Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    product['imageUrl']!,
                    height: 120, // Adjusted height for image in detail view
                    width: double.infinity, // Take full width of the card
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                if (product['discount'] !=
                    null) // Show discount tag if available
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPink, // Pink background for discount
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product['discount']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
                // Plus button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryPink, // Pink background for the button
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        print('Add ${product['name']} to cart');
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product['brand']!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1, // Changed to 1 line based on image
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        product['originalPrice']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration
                              .lineThrough, // Strikethrough for original price
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product['currentPrice']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryPink, // Pink for current price
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
