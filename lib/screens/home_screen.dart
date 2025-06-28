import 'package:flutter/material.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:elure_app/models/api_models.dart';
import 'dart:async'; // Import for Timer
import 'package:elure_app/screens/cart/cart_screen.dart'; // Import CartScreen
import 'package:elure_app/screens/product/product_detail_screen.dart'; // Import ProductDetailScreen
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:intl/intl.dart'; // Import for currency formatting
import 'package:elure_app/screens/search_screen.dart'; // Import the new SearchScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<Product> _products = []; // These are for "Best Sellers"
  Map<int, Brand> _brandsMap = {}; // To map brand IDs to brand names
  Map<int, Category> _categoriesMap =
      {}; // To map category IDs to category names

  bool _isLoading = true; // Overall loading state
  String? _errorMessage; // Overall error message
  User? _loggedInUser; // To store current user data

  // For the banner carousel
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  // Cart item count for the badge
  int _cartItemCount = 0;

  // For Search functionality (now simplified for navigation)
  final TextEditingController _searchController = TextEditingController();

  // Example banner data (you can replace with your actual banner data)
  final List<Map<String, dynamic>> _banners = [
    {
      'image':
          'https://img.freepik.com/premium-vector/anniversary-sale-banner-ads-with-set-skin-care-products-glitterng-background_281653-1359.jpg',
      'title': 'Huge Summer Sale!',
      'subtitle': 'Get 50% off on all beauty products',
    },
    {
      'image':
          'https://i.pinimg.com/736x/36/31/6e/36316e646a53a0f71a0c46388ccc49a0.jpg',
      'title': 'Discover New Arrivals',
      'subtitle': 'Fresh collection just landed!',
    },
    {
      'image':
          'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/nature-cosmetic-product-sale-poster-banner-design-template-28a3a3450d5df1deba865cf54a27a3a6_screen.jpg?ts=1688007268',
      'title': 'Limited Time Offer',
      'subtitle': 'Don\'t miss out on exclusive deals!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData(); // Load all necessary data when the screen initializes
    _startAutoScroll(); // Start auto-scrolling for banners
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  // Function to load all data (user, products, categories, brands, and cart count)
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
    });

    try {
      // 1. Load user data
      _loggedInUser = await _localStorageService.getUserData();

      // 2. Fetch brands first (as products might depend on brand names)
      final brandResponse = await _apiService.getBrands();
      _brandsMap = {for (var b in brandResponse.data ?? []) b.id!: b};

      // 3. Fetch categories
      final categoryResponse = await _apiService.getCategories();
      _categoriesMap = {for (var c in categoryResponse.data ?? []) c.id!: c};

      // 4. Fetch products (assuming these are your "Best Sellers")
      final productResponse = await _apiService.getProducts();
      _products = productResponse.data ?? []; // Store all fetched products

      // 5. Fetch cart item count
      await _fetchCartItemCount();

      print('Home: All data loaded successfully!');
    } on ErrorResponse catch (e) {
      // Handle API specific errors
      setState(() {
        _errorMessage = 'API Error: ${e.message}';
      });
      print('Home: API Error during data load: ${e.message}');
    } catch (e) {
      // Handle other unexpected errors (e.g., network issues)
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
      print('Home: Unexpected error during data load: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fetches the current total quantity of items in the user's cart
  Future<void> _fetchCartItemCount() async {
    if (_loggedInUser?.id == null) {
      if (mounted) {
        setState(() {
          _cartItemCount = 0; // No user logged in, cart is empty
        });
      }
      return;
    }

    try {
      final CartListResponse cartResponse = await _apiService.getCartItems();
      int totalCount = 0;
      if (cartResponse.data != null) {
        for (var item in cartResponse.data!) {
          totalCount += (item.quantity ?? 0).toInt();
        }
      }
      if (mounted) {
        setState(() {
          _cartItemCount = totalCount;
        });
      }
    } on ErrorResponse catch (e) {
      print('Failed to fetch cart count: ${e.message}');
      if (mounted) {
        setState(() {
          _cartItemCount = 0; // Reset count on error
        });
      }
    } catch (e) {
      print('An unexpected error occurred while fetching cart count: $e');
      if (mounted) {
        setState(() {
          _cartItemCount = 0; // Reset count on error
        });
      }
    }
  }

  // Starts the auto-scrolling for the banners
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _banners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // Loop back to the first page
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleAddToCart(Product product) async {
    if (_loggedInUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart.')),
      );
      return;
    }

    if (product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Product ID is invalid.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Adding to cart...')));

    try {
      final CartAddResponse response = await _apiService.addToCart(
        product.id!,
        1, // Always add 1 from the home screen quick add button
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        // Refresh cart count after successful addition
        await _fetchCartItemCount();

        // Optionally, navigate to cart screen after adding
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: ${e.message}')),
        );
        print('Add to Cart Error: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
          ),
        );
        print('Unexpected Add to Cart Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Overall background color of the screen
      appBar: _buildAppBar(), // Custom AppBar widget
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryPink))
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadAllData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh:
                  _loadAllData, // Allows pulling down to refresh all data
              color: primaryPink,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ), // Horizontal padding for the main content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Align children to the start (left)
                    children: <Widget>[
                      const SizedBox(height: 20), // Spacer below app bar
                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 20),

                      // Promotional Banner (now a carousel)
                      _buildPromotionBanner(), // This now contains the carousel logic
                      const SizedBox(height: 30),

                      // Categories Section Header
                      _buildSectionHeader('Categories', () {
                        print('See All Categories tapped from Home');
                        // You can navigate to a dedicated Category Screen here if needed
                        // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen()));
                      }),
                      const SizedBox(height: 15),

                      // Horizontal list of Categories
                      _buildCategoriesList(),
                      const SizedBox(height: 30),

                      // Best Sellers Section Header
                      _buildSectionHeader('Best Sellers', () {
                        print('See All Best Sellers tapped from Home');
                        // You can navigate to a screen showing all products here
                      }),
                      const SizedBox(height: 15),

                      // Grid of Best Seller Products
                      _buildProductGrid(), // Renamed from _buildBestSellersGrid
                      const SizedBox(height: 20), // Padding at the bottom
                    ],
                  ),
                ),
              ),
            ),
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
              ), // Placeholder image (assuming User model doesn't have image URL)
            ),
            const SizedBox(width: 10),
            // Welcome message and user name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Good Morning 👋',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _loggedInUser?.name ??
                      'Guest User', // Display actual user name or 'Guest User'
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Shopping Cart Icon with Badge
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.grey[700],
                size: 28,
              ),
              onPressed: () {
                print('Shopping Cart Tapped');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            if (_cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red, // Red circle for the count
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ), // White border for visibility
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _cartItemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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
            // Navigate to Notifications Screen
            // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
          },
        ),
        const SizedBox(width: 10), // Spacing at the end
      ],
    );
  }

  // Builds the Search Bar (now navigates to SearchScreen)
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () async {
        // Navigate to SearchScreen when the search bar is tapped
        final String? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(
              initialSearchQuery: _searchController.text, // Pass current text
            ),
          ),
        );
        // If a result (e.g., updated search query) is returned from SearchScreen,
        // you can update the _searchController text here if desired.
        if (result != null) {
          _searchController.text = result;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Light grey background
          borderRadius: BorderRadius.circular(30), // Rounded corners
          border: Border.all(color: Colors.grey[200]!), // Light border
        ),
        child: AbsorbPointer(
          // Prevent direct text input on this search bar
          child: Row(
            children: <Widget>[
              Icon(Icons.search, color: Colors.grey[600]), // Search icon
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none, // No underline
                    isDense: true, // Reduce vertical space
                    contentPadding: EdgeInsets.zero, // Remove internal padding
                  ),
                  style: const TextStyle(fontSize: 16),
                  enabled: false, // Make it not directly editable on HomeScreen
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
        ),
      ),
    );
  }

  // Builds the promotional banner (now includes carousel logic)
  Widget _buildPromotionBanner() {
    return Column(
      children: [
        SizedBox(
          height: 180, // Height for the carousel banners
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _buildSimpleBannerItem(
                banner['image'],
                banner['title'], // Pass title for printing/debug purposes
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildPageIndicator(), // Page indicators (dots)
      ],
    );
  }

  // Individual Banner Item for the Carousel (Simplified to match original static design)
  Widget _buildSimpleBannerItem(String imageUrl, String title) {
    return GestureDetector(
      // Added GestureDetector for tap functionality
      onTap: () {
        print('$title banner tapped!');
        // Implement navigation or action for this banner if needed
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5.0,
        ), // Space between banners
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // The image itself will be the primary visual element
      ),
    );
  }

  // Page Indicators (dots) for the carousel
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? primaryPink : Colors.grey[300],
          ),
        );
      }),
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

  // Builds the horizontal list of product categories (now dynamic)
  Widget _buildCategoriesList() {
    if (_categoriesMap.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          'No categories available.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 100, // Fixed height for category items
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categoriesMap.length,
        itemBuilder: (context, index) {
          final category = _categoriesMap.values.elementAt(index);
          return Container(
            width: 80, // Fixed width for each category item
            margin: const EdgeInsets.only(right: 15),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryPink.withOpacity(
                    0.1,
                  ), // Light pink background for icon
                  child: const Icon(
                    Icons.category,
                    color: primaryPink,
                  ), // Generic icon as no image in model
                ),
                const SizedBox(height: 8),
                Text(
                  category.name ?? 'Unknown', // Use category name from API
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Builds the grid of products (Best Sellers)
  Widget _buildProductGrid() {
    if (_isLoading) {
      // Show loading indicator when data is being fetched
      return const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (_errorMessage != null) {
      // Show error message if data fetching failed
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    // This grid now just displays the initially loaded best sellers,
    // as search logic is moved to ProductListScreen
    final List<Product> productsToDisplay = _products;

    if (productsToDisplay.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No products available.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
      itemCount: productsToDisplay.length, // Use productsToDisplay
      itemBuilder: (context, index) {
        return _buildProductCard(productsToDisplay[index]);
      },
    );
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

    // Initialize NumberFormat for Rupiah (IDR) with dot as thousands separator
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp', // Rupiah symbol
      decimalDigits: 0, // No decimal digits for whole rupiah
    );

    // Calculate prices and discount display
    final double? productPrice = product.price?.toDouble();
    final double? productDiscount = product.discount
        ?.toDouble(); // Convert int? to double?

    String displayOriginalPrice = currencyFormatter.format(productPrice ?? 0);
    String displayCurrentPrice;

    if (productPrice != null &&
        productDiscount != null &&
        productDiscount > 0) {
      // Corrected: Divide productDiscount by 100 to get a decimal for calculation
      double discountedPrice = productPrice * (1 - (productDiscount / 100));
      displayCurrentPrice = currencyFormatter.format(discountedPrice);
    } else {
      displayCurrentPrice = currencyFormatter.format(productPrice ?? 0);
    }

    final String displayDiscount =
        (productDiscount != null && productDiscount > 0)
        ? '${productDiscount.toStringAsFixed(0)}%' // Display the integer percentage directly
        : '0%';

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
                        '$displayDiscount OFF', // Use actual calculated discount
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
                      onPressed: () => _handleAddToCart(product),
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
                        style: const TextStyle(
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
