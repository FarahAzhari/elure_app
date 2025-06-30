import 'package:elure_app/models/api_models.dart'; // Import API models for Category, Product
import 'package:elure_app/screens/category/category_detail_screen.dart'; // Import CategoryDetailScreen
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  Map<int, int> _productsCountMap = {}; // Maps categoryId to product count

  // Combined loading state for initial data
  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  // Lottie animation URL to be used for all category icons
  static const String _lottieCategoryIconUrl =
      'https://lottie.host/f85bc0f6-2c32-4483-aa18-52345c4800c1/sVb4wfsdET.json'; // A general category icon

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Fetch all necessary data when the screen initializes
  }

  // Function to fetch all initial data (categories and products)
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataErrorMessage = null;
    });

    try {
      await Future.wait([
        _fetchCategories(), // Fetch categories
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
        print('CategoryScreen: Error fetching initial data: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'CategoryScreen: Failed to load initial data: ${e.toString()}';
          _isLoadingInitialData = false;
        });
        print('CategoryScreen: Unexpected error fetching initial data: $e');
      }
    }
  }

  // Function to fetch categories from the API
  Future<void> _fetchCategories() async {
    try {
      final CategoryListResponse response = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = response.data ?? [];
        });
        print('Categories fetched successfully: ${_categories.length} items');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nCategories: ${e.message}'
            : 'Categories: ${e.message}';
        print('Error fetching categories: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nCategories: ${e.toString()}'
            : 'Categories: ${e.toString()}';
        print('Unexpected error fetching categories: $e');
      }
    }
  }

  // Function to fetch all products and then count them per category
  Future<void> _fetchProductsAndCount() async {
    try {
      final ProductListResponse response = await _apiService.getProducts();
      if (mounted) {
        final Map<int, int> tempCountMap = {};
        for (var product in response.data ?? []) {
          if (product.categoryId != null) {
            tempCountMap.update(
              product.categoryId!,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
          }
        }
        setState(() {
          _productsCountMap = tempCountMap;
        });
        print('Product counts per category calculated.');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        _initialDataErrorMessage = _initialDataErrorMessage != null
            ? '$_initialDataErrorMessage\nProducts: ${e.message}'
            : 'Products: ${e.message}';
        print('Error fetching products for count: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
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
      appBar: _buildAppBar(context), // Custom AppBar for category screen
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
                // Kept SingleChildScrollView inside RefreshIndicator
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
                      child: _buildSearchBar(), // Search bar for categories
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader('All Categories', null),
                    const SizedBox(height: 15),

                    _buildCategoryList(),
                    const SizedBox(height: 20), // Padding at the bottom
                  ],
                ),
              ),
            ),
    );
  }

  // Custom AppBar for the Category Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Categories',
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
            print('Notifications Tapped from Category Screen');
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

  // Builds the list of categories (now with product count)
  Widget _buildCategoryList() {
    if (_categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No categories found.',
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
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          // Get product count for the current category, default to 0 if not found
          final int productCount = _productsCountMap[category.id] ?? 0;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Lottie.network(
                      _lottieCategoryIconUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.category_outlined,
                        color: primaryPink,
                      ), // Fallback
                    ),
                  ),
                ),
                title: Text(
                  category.name ?? 'Unknown Category',
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
                  print('Tapped on ${category.name}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailScreen(
                        categoryId: category.id!,
                        categoryName: category.name ?? 'Unknown Category',
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
