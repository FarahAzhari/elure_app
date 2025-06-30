import 'package:elure_app/models/api_models.dart'; // Import API models for Brand, Product
import 'package:elure_app/screens/brand/brand_detail_screen.dart'; // Import the new BrandDetailScreen
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);

  // Instance of ApiService
  final ApiService _apiService = ApiService();

  // State variables for brands and product counts
  List<Brand> _brands = [];
  Map<int, int> _productsCountMap = {}; // Maps brandId to product count

  // Combined loading state for initial data
  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  // Lottie animation URL to be used for all brand icons
  // You can replace this with any Lottie animation URL you prefer from LottieFiles.com
  static const String _lottieBrandIconUrl =
      'https://lottie.host/802bce28-03ba-473b-8df5-d98600c6ce82/BaPYcYlxwF.json';

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Fetch all necessary data when the screen initializes
  }

  // Function to fetch all initial data (brands and products)
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataErrorMessage = null;
    });

    try {
      await Future.wait([
        _fetchBrands(), // Fetch brands
        _fetchProductsAndCount(), // Fetch products and populate count map
      ]);

      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = e.message;
          _isLoadingInitialData = false;
        });
        print('BrandScreen: Error fetching initial data: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'BrandScreen: Failed to load initial data: ${e.toString()}';
          _isLoadingInitialData = false;
        });
        print('BrandScreen: Unexpected error fetching initial data: $e');
      }
    }
  }

  // Function to fetch brands from the API
  Future<void> _fetchBrands() async {
    try {
      final BrandListResponse response = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _brands = response.data ?? []; // Update the list with fetched data
        });
        print('Brands fetched successfully: ${_brands.length} items');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        // Append error message to initial data error
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nBrands: ${e.message}'
            : 'Brands: ${e.message}';
        print('Error fetching brands: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        // Append error message to initial data error
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nBrands: ${e.toString()}'
            : 'Brands: ${e.toString()}';
        print('Unexpected error fetching brands: $e');
      }
    }
  }

  // Function to fetch all products and then count them per brand
  Future<void> _fetchProductsAndCount() async {
    try {
      final ProductListResponse response = await _apiService.getProducts();
      if (mounted) {
        final Map<int, int> tempCountMap = {};
        for (var product in response.data ?? []) {
          if (product.brandId != null) {
            tempCountMap.update(
              product.brandId!,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
          }
        }
        setState(() {
          _productsCountMap = tempCountMap;
        });
        print('Product counts per brand calculated.');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        // Append error message to initial data error
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nProducts: ${e.message}'
            : 'Products: ${e.message}';
        print('Error fetching products for count: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        // Append error message to initial data error
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nProducts: ${e.toString()}'
            : 'Products: ${e.toString()}';
        print('Unexpected error fetching products for count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context), // Custom AppBar for brand screen
      body: _isLoadingInitialData
          ? const Center(child: CircularProgressIndicator(color: primaryPink))
          : _initialDataErrorMessage != null
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
                      _initialDataErrorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchInitialData,
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
              // Added RefreshIndicator here
              onRefresh:
                  _fetchInitialData, // Calls _fetchInitialData on pull-to-refresh
              color: primaryPink, // Customize the refresh indicator color
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator in case content is small
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: _buildSearchBar(), // Search bar for brands
                    ),
                    const SizedBox(height: 20),

                    // Section Header for Brands List
                    _buildSectionHeader(
                      'All Brands',
                      null,
                    ), // "See All" not needed as it's the main list
                    const SizedBox(height: 15),

                    // List of Brands dynamically from API data
                    _buildBrandList(),
                    const SizedBox(height: 20), // Padding at the bottom
                  ],
                ),
              ),
            ),
    );
  }

  // Custom AppBar for the Brand Screen
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
          Navigator.pop(context); // Pop the current screen off the stack
        },
      ),
      title: const Text(
        'Brands',
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
          ), // Notification icon
          onPressed: () {
            print('Notifications Tapped from Brand Screen');
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

  // Builds a standard section header with an optional "See All" link
  Widget _buildSectionHeader(String title, VoidCallback? onSeeAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (onSeeAllTap != null) // Only show "See All" if onTap is provided
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                'See All',
                style: TextStyle(
                  color: primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builds the list of brands (now using fetched data and Lottie animation)
  Widget _buildBrandList() {
    if (_brands.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No brands found.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true, // Take only as much space as needed
        physics:
            const NeverScrollableScrollPhysics(), // Disable scrolling within this list
        itemCount: _brands.length,
        itemBuilder: (context, index) {
          final brand = _brands[index];
          // Get product count for the current brand, default to 0 if not found
          final int productCount = _productsCountMap[brand.id] ?? 0;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: Container(
                  // Replaced CircleAvatar with Container for Lottie
                  width: 50, // Match the radius * 2
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(
                      0.1,
                    ), // Light pink background
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    // Clip the Lottie animation to a circle
                    child: Lottie.network(
                      _lottieBrandIconUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      repeat: true, // Loop the animation
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.diamond_outlined,
                        color: primaryPink,
                      ), // Fallback to icon on error
                    ),
                  ),
                ),
                title: Text(
                  brand.name ?? 'Unknown Brand',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  '$productCount products', // Display product count
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: () {
                  print('Tapped on ${brand.name}');
                  // Navigate to the new BrandDetailScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrandDetailScreen(
                        brandId: brand.id!, // Pass the brand ID
                        brandName:
                            brand.name ??
                            'Unknown Brand', // Pass the brand name
                      ),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
              ), // Divider below the item
            ],
          );
        },
      );
    }
  }
}
