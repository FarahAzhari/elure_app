import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/screens/product/product_detail_screen.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:flutter/material.dart';

// HomeScreen now represents the content of the "Home" tab.
// It no longer manages the BottomNavigationBar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the primary pink color for consistency, as observed in your designs.
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  // Instance of ApiService
  final ApiService _apiService = ApiService();

  // State variables for products
  List<Product> _bestSellerProducts = [];
  // Maps for quick lookup of brand names by ID (needed for ProductDetailScreen)
  Map<int, Brand> _brandsMap = {};
  bool _isLoadingProducts = true;
  String? _productsErrorMessage;
  bool _isLoadingBrands = true; // Track loading for brands
  String? _brandsErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBrands().then((_) {
      // Fetch brands first
      _fetchBestSellerProducts(); // Then fetch products
    });
  }

  // Function to fetch brands from the API (copied from ManageProductsScreen)
  Future<void> _fetchBrands() async {
    setState(() {
      _isLoadingBrands = true;
      _brandsErrorMessage = null;
    });

    try {
      final brandResponse = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _brandsMap = {for (var b in brandResponse.data ?? []) b.id!: b};
          _isLoadingBrands = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _brandsErrorMessage = e.message;
          _isLoadingBrands = false;
        });
        print('Home: Error fetching brands: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _brandsErrorMessage = 'Home: Failed to load brands: ${e.toString()}';
          _isLoadingBrands = false;
        });
        print('Home: Unexpected error fetching brands: $e');
      }
    }
  }

  // Function to fetch best seller products from the API
  Future<void> _fetchBestSellerProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsErrorMessage = null; // Clear previous error messages
    });

    try {
      final ProductListResponse response = await _apiService.getProducts();
      setState(() {
        _bestSellerProducts =
            response.data ?? []; // Update the list with fetched data
        _isLoadingProducts = false;
      });
      print(
        'Products fetched successfully: ${_bestSellerProducts.length} items',
      );
    } on ErrorResponse catch (e) {
      setState(() {
        _productsErrorMessage = e.message;
        _isLoadingProducts = false;
      });
      print('Error fetching products: ${e.message}');
    } catch (e) {
      setState(() {
        _productsErrorMessage = 'Failed to load products: ${e.toString()}';
        _isLoadingProducts = false;
      });
      print('Unexpected error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Overall background color of the screen
      appBar: _buildAppBar(), // Custom AppBar widget
      body: SingleChildScrollView(
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
                // You can potentially use DefaultTabController.of(context).animateTo(index)
                // if you want to switch tabs from within a content page.
                // For now, this just prints to console.
              }),
              const SizedBox(height: 15),

              // Horizontal list of Categories
              _buildCategoriesList(),
              const SizedBox(height: 30),

              // Best Sellers Section Header
              _buildSectionHeader('Best Sellers', () {
                print('See All Best Sellers tapped from Home');
                // Similarly, this just prints for now.
              }),
              const SizedBox(height: 15),

              // Grid of Best Seller Products
              _buildBestSellersGrid(),
              const SizedBox(height: 20), // Padding at the bottom
            ],
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(), // REMOVED: Now managed by MainNavigationScreen
    );
  }

  // --- Widget Builders for Reusable UI Components (unchanged from your original) ---

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
            // If you want to navigate to the cart tab, you'd need to access the MainNavigationScreen's state.
            // This usually involves a callback or a global state management solution.
            // For now, it just prints.
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
    if (_isLoadingProducts || _isLoadingBrands) {
      // Also check if brands are loading
      return const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (_productsErrorMessage != null || _brandsErrorMessage != null) {
      String errorMessage = '';
      if (_productsErrorMessage != null)
        errorMessage += 'Products: $_productsErrorMessage\n';
      if (_brandsErrorMessage != null)
        errorMessage += 'Brands: $_brandsErrorMessage\n';
      return Center(
        child: Text(
          errorMessage.trim(),
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_bestSellerProducts.isEmpty) {
      return const Center(
        child: Text(
          'No best seller products found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true, // Take only as much space as needed
        physics:
            const NeverScrollableScrollPhysics(), // Disable scrolling within the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 15, // Horizontal spacing
          mainAxisSpacing: 15, // Vertical spacing
          childAspectRatio: 0.7, // Aspect ratio of each grid item
        ),
        itemCount: _bestSellerProducts.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_bestSellerProducts[index]);
        },
      );
    }
  }

  // Helper widget to build individual product cards
  Widget _buildProductCard(Product product) {
    // Determine the image URL for the product card
    String imageUrlToDisplay = '';
    if (product.images != null && product.images!.isNotEmpty) {
      imageUrlToDisplay = product.images!.first;
      // Prepend base URL if it's a relative path
      if (!imageUrlToDisplay.startsWith('http://') &&
          !imageUrlToDisplay.startsWith('https://')) {
        imageUrlToDisplay = '$_baseUrl$imageUrlToDisplay';
      }
    } else {
      // Fallback placeholder image if no image is provided by API
      imageUrlToDisplay =
          'https://placehold.co/150x150/FF00FF/FFFFFF?text=${product.name?.substring(0, 1) ?? 'P'}';
    }

    // Calculate prices and discount display
    final double? productPrice = product.price?.toDouble();
    final int? productDiscount = product.discount;

    String displayOriginalPrice =
        '\$${productPrice?.toStringAsFixed(0) ?? '0'}.00';
    String displayCurrentPrice;

    if (productPrice != null &&
        productDiscount != null &&
        productDiscount > 0) {
      double discountedPrice = productPrice * (1 - productDiscount);
      displayCurrentPrice = '\$${discountedPrice.toStringAsFixed(0)}.00';
    } else {
      displayCurrentPrice = '\$${productPrice?.toStringAsFixed(0) ?? '0'}.00';
    }

    final String displayDiscount =
        (productDiscount != null && productDiscount > 0)
        ? '${(productDiscount * 100).toStringAsFixed(0)}%'
        : '0%'; // Convert discount to percentage string

    // Get brand name from the map using brandId
    final String brandName =
        _brandsMap[product.brandId]?.name ?? 'Unknown Brand';

    return GestureDetector(
      onTap: () {
        print('Tapped on product: ${product.name}');
        // Pass the Product object and the resolved brandName directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              brandName: brandName, // Pass the actual brand name
            ),
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
            // Product Image with Discount Tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrlToDisplay, // Use determined image URL
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
                // Discount tag
                if (product.discount != null &&
                    product.discount! > 0) // Only show if there's a discount
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
                        displayDiscount, // Use actual calculated discount
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
                    product.name ??
                        'Unknown Product', // Use product name from API
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    // Added Row to hold price texts
                    children: [
                      if (productPrice != null &&
                          productDiscount != null &&
                          productDiscount > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            displayOriginalPrice,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      Text(
                        displayCurrentPrice, // Use current price (from API price)
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryPink, // Pink for price
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    brandName, // Use resolved brand name
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
