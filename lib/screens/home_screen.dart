import 'package:elure_app/screens/auth/profile_screen.dart';
import 'package:elure_app/screens/brand/brand_screen.dart';
import 'package:elure_app/screens/cart/cart_screen.dart';
import 'package:elure_app/screens/category/category_screen.dart';
import 'package:flutter/material.dart';
// Import the new profile screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the primary pink color for consistency, as observed in your designs.
  static const Color primaryPink = Color(0xFFE91E63);

  // Add a state variable to manage the current index of the bottom navigation bar
  int _selectedIndex = 0;

  // Helper function to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on the tapped index
    if (index == 1) {
      // Index 1 corresponds to 'Categories'
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      ).then((_) {
        // After returning from CategoryScreen, reset selected index to Home (index 0)
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 2) {
      // Index 2 corresponds to 'Brands'
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BrandScreen()),
      ).then((_) {
        // After returning from BrandScreen, reset selected index to Home (index 0)
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 3) {
      // Index 3 corresponds to 'Carts'
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      ).then((_) {
        // After returning from CartScreen, reset selected index to Home (index 0)
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 4) {
      // Index 4 corresponds to 'Profile'
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ), // Navigate to ProfileScreen
      ).then((_) {
        // After returning from ProfileScreen, reset selected index to Home (index 0)
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Overall background color of the screen
      appBar: _buildAppBar(), // Custom AppBar widget
      body: SingleChildScrollView(
        // The body will always show the home content
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Horizontal padding for the main content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the start (left)
            children: <Widget>[
              const SizedBox(height: 20), // Spacer below app bar
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 20),

              // Horizontal list of filter tags (All Brands, Glowora, etc.)
              _buildFilterTags(),
              const SizedBox(height: 20),

              // Promotional Banner
              _buildPromotionBanner(),
              const SizedBox(height: 30),

              // Categories Section Header
              _buildSectionHeader('Categories', () {
                print('See All Categories tapped from Home');
              }),
              const SizedBox(height: 15),

              // Horizontal list of Categories
              _buildCategoriesList(),
              const SizedBox(height: 30),

              // Best Sellers Section Header
              _buildSectionHeader('Best Sellers', () {
                print('See All Best Sellers tapped from Home');
              }),
              const SizedBox(height: 15),

              // Grid of Best Seller Products
              _buildBestSellersGrid(),
              const SizedBox(height: 20), // Padding at the bottom
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Custom Bottom Navigation Bar
    );
  }

  // --- Widget Builders for Reusable UI Components ---

  // Builds the custom AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white, // White background for the app bar
      elevation: 0, // No shadow
      toolbarHeight: 80, // Custom height for the app bar
      titleSpacing: 0, // Remove default title spacing
      title: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Padding for content inside the title
        child: Row(
          children: <Widget>[
            // User Profile Picture
            const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                'https://placehold.co/100x100/FF00FF/FFFFFF?text=User',
              ), // Placeholder image
              // You would typically use an Image.asset or NetworkImage with an actual user image URL
            ),
            const SizedBox(width: 10),
            // Welcome message and user name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Good Morning 👋',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Esther Howard',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Shopping Cart Icon
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: Colors.grey[700],
            size: 28,
          ),
          onPressed: () {
            print('Shopping Cart Tapped');
          },
        ),
        // Notification Icon
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: Colors.grey[700],
            size: 28,
          ),
          onPressed: () {
            print('Notifications Tapped');
          },
        ),
        const SizedBox(width: 10), // Spacing at the end
      ],
    );
  }

  // Builds the Search Bar
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

  // Builds the horizontal list of filter tags
  Widget _buildFilterTags() {
    final List<String> tags = [
      'All Brands',
      'Glowora',
      'Bloomelle',
      'Skinova',
      'AquaSense',
    ];
    return SizedBox(
      height: 40, // Fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final bool isSelected =
              index == 0; // 'All Brands' is selected by default in the image
          return Container(
            margin: const EdgeInsets.only(right: 10), // Spacing between tags
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryPink
                  : Colors.grey[200], // Pink if selected, grey otherwise
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            child: Center(
              child: Text(
                tags[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black, // White text if selected, black otherwise
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the promotional banner
  Widget _buildPromotionBanner() {
    return Container(
      width: double.infinity, // Full width
      height: 200, // Increased height to prevent overflow in the inner Column
      decoration: BoxDecoration(
        color: primaryPink, // Pink background for the banner
        borderRadius: BorderRadius.circular(20), // Rounded corners
        image: const DecorationImage(
          image: NetworkImage(
            'https://placehold.co/600x200/E91E63/FFFFFF?text=Promotional+Image',
          ), // Placeholder for product image
          fit: BoxFit.cover, // Cover the container
          alignment: Alignment.centerRight, // Align image to the right
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '50% Off! Grab\nYour Glow\nToday!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2, // Line height
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                print('Shop Now Tapped');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Rounded corners for button
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
              ),
              child: Text(
                'Shop Now',
                style: TextStyle(
                  color: primaryPink, // Pink text for button
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a standard section header with a "See All" link
  Widget _buildSectionHeader(String title, VoidCallback onSeeAllTap) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Space out title and "See All"
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: onSeeAllTap,
          child: Text(
            'See All',
            style: TextStyle(color: primaryPink, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Builds the horizontal list of product categories
  Widget _buildCategoriesList() {
    final List<Map<String, String>> categories = [
      {
        'name': 'Skincare',
        'image': 'https://placehold.co/100x100/F0F0F0/000000?text=S',
      },
      {
        'name': 'Makeup',
        'image': 'https://placehold.co/100x100/F0F0F0/000000?text=M',
      },
      {
        'name': 'Cream',
        'image': 'https://placehold.co/100x100/F0F0F0/000000?text=C',
      },
      {
        'name': 'Perfume',
        'image': 'https://placehold.co/100x100/F0F0F0/000000?text=P',
      },
      {
        'name': 'Lotion',
        'image': 'https://placehold.co/100x100/F0F0F0/000000?text=L',
      },
    ];

    return SizedBox(
      height: 100, // Fixed height for category items
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80, // Fixed width for each category item
            margin: const EdgeInsets.only(right: 15),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Colors.grey[100], // Light grey background for icon/image
                  backgroundImage: NetworkImage(
                    categories[index]['image']!,
                  ), // Category image
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['name']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Builds the grid of best seller products
  Widget _buildBestSellersGrid() {
    // Using dummy product data. In a real app, this would come from a data source.
    final List<Map<String, String>> products = [
      {
        'name': 'Skincare Product A',
        'price': '\$35.00',
        'discount': '50%',
        'image': 'https://placehold.co/150x150/FF00FF/FFFFFF?text=Product+1',
      },
      {
        'name': 'Makeup Kit B',
        'price': '\$22.50',
        'discount': '20%',
        'image': 'https://placehold.co/150x150/FF00FF/FFFFFF?text=Product+2',
      },
      {
        'name': 'Perfume C',
        'price': '\$49.99',
        'discount': '10%',
        'image': 'https://placehold.co/150x150/FF00FF/FFFFFF?text=Product+3',
      },
      {
        'name': 'Lotion D',
        'price': '\$15.00',
        'discount': '15%',
        'image': 'https://placehold.co/150x150/FF00FF/FFFFFF?text=Product+4',
      },
    ];

    return GridView.builder(
      shrinkWrap: true, // Take only as much space as needed
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling within the grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        crossAxisSpacing: 15, // Horizontal spacing
        mainAxisSpacing: 15, // Vertical spacing
        childAspectRatio:
            0.7, // Aspect ratio of each grid item (height is roughly 1.4 times width)
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  // Helper widget to build individual product cards
  Widget _buildProductCard(Map<String, String> product) {
    return Container(
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
          // Product Image with Discount Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  product['image']!,
                  height: 150, // Fixed height for the image
                  width: double.infinity, // Take full width of the card
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
              if (product['discount'] != null) // Show discount tag if available
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  product['price']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryPink, // Pink for price
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Glowora', // Placeholder brand name
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
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
      type: BottomNavigationBarType
          .fixed, // Ensures all items are visible even with many
      showSelectedLabels: true, // Always show labels for selected item
      showUnselectedLabels: true, // Always show labels for unselected items
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: _onItemTapped, // Call the new handler function
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
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Carts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          label: 'Profile',
        ),
      ],
    );
  }
}
