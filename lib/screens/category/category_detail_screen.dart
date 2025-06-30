import 'package:elure_app/models/api_models.dart'; // Import API models for Product, Category, Brand
import 'package:elure_app/screens/product/product_detail_screen.dart'; // For navigating to product details
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId; // The ID of the category
  final String categoryName; // The name of the category to display

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  final ApiService _apiService = ApiService();

  List<Product> _products = []; // Stores all products for this category
  List<Product> _filteredProducts =
      []; // Stores products filtered by search query
  Map<int, Brand> _brandsMap =
      {}; // To map brand IDs to brand names for product cards
  Map<int, Category> _categoriesMap =
      {}; // To map category IDs to category names for product cards

  // Combined loading state for initial data
  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Fetch all necessary data when the screen initializes
    _searchController.addListener(
      _filterProducts,
    ); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts); // Remove listener
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Function to filter products based on the search query
  void _filterProducts() {
    final String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        // Get the brand name safely
        final String? brandName = _brandsMap[product.brandId]?.name;

        // Filter by product name, description, or brand name
        return (product.name?.toLowerCase().contains(query) ?? false) ||
            (product.description?.toLowerCase().contains(query) ?? false) ||
            (brandName?.toLowerCase().contains(query) ??
                false); // Safely check brand name
      }).toList();
    });
  }

  // Fetches initial data: categories, brands (for product card display) and then products by category
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataErrorMessage = null;
    });

    try {
      await Future.wait([
        _fetchCategories(), // First, fetch categories to build the map
        _fetchBrands(), // Then, fetch brands to build the map
      ]);
      await _fetchProductsByCategory(); // Finally, fetch and filter products

      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
        _filterProducts(); // After fetching, filter to show all initially
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = e.message;
          _isLoadingInitialData = false;
        });
        print('CategoryDetail: Error fetching initial data: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'CategoryDetail: Failed to load initial data: ${e.toString()}';
          _isLoadingInitialData = false;
        });
        print('CategoryDetail: Unexpected error fetching initial data: $e');
      }
    }
  }

  // Function to fetch categories and create a map for quick lookup
  Future<void> _fetchCategories() async {
    try {
      final categoryResponse = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categoriesMap = {
            for (var c in categoryResponse.data ?? []) c.id!: c,
          };
        });
      }
    } on ErrorResponse catch (e) {
      print('CategoryDetail: Error fetching categories: ${e.message}');
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = _initialDataErrorMessage != null
              ? '$_initialDataErrorMessage\nCategories: ${e.message}'
              : 'Categories: ${e.message}';
        });
      }
    } catch (e) {
      print('CategoryDetail: Unexpected error fetching categories: $e');
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = _initialDataErrorMessage != null
              ? '$_initialDataErrorMessage\nCategories: ${e.toString()}'
              : 'Categories: ${e.toString()}';
        });
      }
    }
  }

  // Function to fetch brands and create a map for quick lookup
  Future<void> _fetchBrands() async {
    try {
      final brandResponse = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _brandsMap = {for (var b in brandResponse.data ?? []) b.id!: b};
        });
      }
    } on ErrorResponse catch (e) {
      print('CategoryDetail: Error fetching brands: ${e.message}');
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = _initialDataErrorMessage != null
              ? '$_initialDataErrorMessage\nBrands: ${e.message}'
              : 'Brands: ${e.message}';
        });
      }
    } catch (e) {
      print('CategoryDetail: Unexpected error fetching brands: $e');
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = _initialDataErrorMessage != null
              ? '$_initialDataErrorMessage\nBrands: ${e.toString()}'
              : 'Brands: ${e.toString()}';
        });
      }
    }
  }

  // Function to fetch all products and then filter them by the current category ID
  Future<void> _fetchProductsByCategory() async {
    try {
      final ProductListResponse response = await _apiService.getProducts();
      if (mounted) {
        // Filter products by categoryId (widget.categoryId is guaranteed non-null due to 'required' in constructor)
        List<Product> productsForCategory =
            response.data
                ?.where((p) => p.categoryId == widget.categoryId)
                .toList() ??
            [];

        setState(() {
          _products =
              productsForCategory; // Store all products for the category
        });
        print(
          'CategoryDetail: Products fetched and filtered successfully for ${widget.categoryName}: ${_products.length} items',
        );
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = _initialDataErrorMessage != null
              ? '$_initialDataErrorMessage\nProducts: ${e.message}'
              : 'Products: ${e.message}';
        });
        print('CategoryDetail: Error fetching products: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = _initialDataErrorMessage != null
              ? '$_initialDataErrorMessage\nProducts: ${e.toString()}'
              : 'Products: ${e.toString()}';
        });
        print('CategoryDetail: Unexpected error fetching products: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryPink)),
      );
    }

    if (_initialDataErrorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _initialDataErrorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context), // Custom App Bar for this screen
      body: RefreshIndicator(
        // Added RefreshIndicator here
        onRefresh:
            _fetchInitialData, // Calls _fetchInitialData on pull-to-refresh
        color: primaryPink, // Customize the refresh indicator color
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
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
        widget.categoryName, // Display category name and product count
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
          Expanded(
            child: TextField(
              controller: _searchController, // Connect controller
              decoration: const InputDecoration(
                hintText: 'Search products...', // Updated hint text
                border: InputBorder.none, // No underline
                isDense: true, // Reduce vertical space
                contentPadding: EdgeInsets.zero, // Remove internal padding
              ),
              style: const TextStyle(fontSize: 16),
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
    if (_filteredProducts.isEmpty) {
      if (_products.isEmpty && _initialDataErrorMessage == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No products found for this category.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else if (_searchController.text.isNotEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No products match your search in this category.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return const SizedBox.shrink(); // Should not be reached if previous checks cover
    } else {
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
        itemCount: _filteredProducts.length, // Use filtered list
        itemBuilder: (context, index) {
          return _buildProductCard(_filteredProducts[index]);
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

    // Initialize NumberFormat for Rupiah (IDR) with dot as thousands separator
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp', // Rupiah symbol
      decimalDigits: 0, // No decimal digits for whole rupiah
    );

    // Calculate prices and discount display
    final double? productPrice = product.price?.toDouble();
    final double? productDiscount = product.discount
        ?.toDouble(); // Explicitly cast to double?

    String displayOriginalPrice = currencyFormatter.format(productPrice ?? 0);
    String displayCurrentPrice;

    if (productPrice != null &&
        productDiscount != null &&
        productDiscount > 0) {
      double discountedPrice = productPrice * (1 - (productDiscount / 100));
      displayCurrentPrice = currencyFormatter.format(discountedPrice);
    } else {
      displayCurrentPrice = currencyFormatter.format(productPrice ?? 0);
    }

    final String displayDiscount =
        (productDiscount != null && productDiscount > 0)
        ? '${productDiscount.toStringAsFixed(0)}%' // Display as percentage string
        : '0%';

    // Get brand name from the map
    final String brandName =
        _brandsMap[product.brandId]?.name ?? 'Unknown Brand';
    // Get category name from the map (can also use widget.categoryName as it's the current screen's category)
    final String categoryName =
        _categoriesMap[product.categoryId]?.name ?? 'Unknown Category';

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
            // Product Image with Discount Tag and Heart Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrlToDisplay, // Use determined image URL
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
                if (product.discount != null &&
                    product.discount! >
                        0) // Show discount tag if available and not N/A
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
                        '$displayDiscount OFF', // Display discount as "XX% OFF"
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
                        print('Add ${product.name} to cart');
                        // Implement add to cart logic here
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
                    // Display both brand and category
                    '$brandName · $categoryName',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.name ?? 'Unknown Product',
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
                      if (productPrice != null &&
                          productDiscount != null &&
                          productDiscount >
                              0) // Show original price only if different from current
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            displayOriginalPrice,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration
                                  .lineThrough, // Strikethrough for original price
                            ),
                          ),
                        ),
                      Text(
                        displayCurrentPrice,
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
