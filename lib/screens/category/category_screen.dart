import 'package:elure_app/models/api_models.dart'; // Import API models for Category
import 'package:elure_app/screens/category/category_detail_screen.dart';
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);

  // Instance of ApiService
  final ApiService _apiService = ApiService();

  // State variables for categories
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoriesErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the screen initializes
  }

  // Function to fetch categories from the API
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesErrorMessage = null; // Clear previous error messages
    });

    try {
      final CategoryListResponse response = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories =
              response.data ?? []; // Update the list with fetched data
          _isLoadingCategories = false;
        });
        print('Categories fetched successfully: ${_categories.length} items');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _categoriesErrorMessage = e.message;
          _isLoadingCategories = false;
        });
        print('Error fetching categories: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesErrorMessage =
              'Failed to load categories: ${e.toString()}';
          _isLoadingCategories = false;
        });
        print('Unexpected error fetching categories: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context), // Custom AppBar for category screen
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: _buildSearchBar(), // Search bar for categories
            ),
            const SizedBox(height: 20),
            // Build the list of categories dynamically from API data
            _buildCategoryList(),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // Custom AppBar for the Category Screen
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
        'Choose a Category',
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

  // Builds the Search Bar (reused from home_screen for consistency)
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

  // Builds the list of categories (now using fetched data)
  Widget _buildCategoryList() {
    if (_isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: primaryPink),
        ),
      );
    } else if (_categoriesErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _categoriesErrorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_categories.isEmpty) {
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
          // As the API Category model doesn't include productCount or subCategories,
          // we simplify to a non-expandable list item.
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[100],
                  // Placeholder image as Category model does not have an image field
                  backgroundImage: NetworkImage(
                    'https://placehold.co/100x100/F0F0F0/000000?text=${category.name?.substring(0, 1) ?? 'C'}',
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
                // Display a generic product count or 'N/A'
                subtitle: Text(
                  'Approx. 100+ Product available', // Dummy product count
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: () {
                  print('Tapped on ${category.name}');
                  // Navigate to products list for this category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailScreen(
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
