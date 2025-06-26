import 'package:elure_app/models/api_models.dart'; // Import API models for Product, Category, Brand
import 'package:elure_app/screens/product/product_detail_screen.dart';
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  Map<int, Brand> _brandsMap = {}; // To map brand IDs to brand names
  Map<String, int> _categoriesNameToIdMap = {}; // To map category names to IDs

  // State variable to hold the count of products in the current category
  int _productCount = 0;

  bool _isLoadingProducts = true;
  String? _productsErrorMessage;
  bool _isLoadingBrands = true;
  String? _brandsErrorMessage;
  bool _isLoadingCategoriesMapping = true;
  String? _categoriesMappingErrorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch brands and categories first, then products
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([_fetchBrands(), _fetchCategoriesForMapping()]);
    // After brands and category mapping are ready, fetch products
    _fetchProductsByCategory();
  }

  // Function to fetch brands and create a map for quick lookup
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
        print('CategoryDetail: Error fetching brands: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _brandsErrorMessage =
              'CategoryDetail: Failed to load brands: ${e.toString()}';
          _isLoadingBrands = false;
        });
        print('CategoryDetail: Unexpected error fetching brands: $e');
      }
    }
  }

  // Function to fetch categories to create a name-to-ID map
  Future<void> _fetchCategoriesForMapping() async {
    setState(() {
      _isLoadingCategoriesMapping = true;
      _categoriesMappingErrorMessage = null;
    });

    try {
      final categoryResponse = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categoriesNameToIdMap = {
            for (var c in categoryResponse.data ?? []) c.name!: c.id!,
          };
          _isLoadingCategoriesMapping = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _categoriesMappingErrorMessage = e.message;
          _isLoadingCategoriesMapping = false;
        });
        print(
          'CategoryDetail: Error fetching categories for mapping: ${e.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesMappingErrorMessage =
              'CategoryDetail: Failed to load categories for mapping: ${e.toString()}';
          _isLoadingCategoriesMapping = false;
        });
        print(
          'CategoryDetail: Unexpected error fetching categories for mapping: $e',
        );
      }
    }
  }

  // Function to fetch products and filter them by the current category name
  Future<void> _fetchProductsByCategory() async {
    setState(() {
      _isLoadingProducts = true;
      _productsErrorMessage = null;
    });

    try {
      final ProductListResponse response = await _apiService.getProducts();
      if (mounted) {
        // Filter products by categoryName
        final int? targetCategoryId =
            _categoriesNameToIdMap[widget.categoryName];

        List<Product> filteredProducts = [];
        if (targetCategoryId != null) {
          filteredProducts =
              response.data
                  ?.where((p) => p.categoryId == targetCategoryId)
                  .toList() ??
              [];
        } else {
          // If category ID not found for the given name, assume no products for this category.
          print('Category ID not found for: ${widget.categoryName}');
        }

        setState(() {
          _products = filteredProducts;
          _productCount = filteredProducts.length; // Update product count
          _isLoadingProducts = false;
        });
        print(
          'CategoryDetail: Products fetched and filtered successfully for ${widget.categoryName}: ${_products.length} items',
        );
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _productsErrorMessage = e.message;
          _isLoadingProducts = false;
        });
        print('CategoryDetail: Error fetching products: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productsErrorMessage =
              'CategoryDetail: Failed to load products: ${e.toString()}';
          _isLoadingProducts = false;
        });
        print('CategoryDetail: Unexpected error fetching products: $e');
      }
    }
  }

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
        // Display the category name and product count
        '${widget.categoryName} (${_productCount} products)',
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
    // Check all loading states for a comprehensive loading indicator
    if (_isLoadingProducts || _isLoadingBrands || _isLoadingCategoriesMapping) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: primaryPink),
        ),
      );
    } else if (_productsErrorMessage != null ||
        _brandsErrorMessage != null ||
        _categoriesMappingErrorMessage != null) {
      String errorMessage = '';
      if (_productsErrorMessage != null)
        errorMessage += 'Products: $_productsErrorMessage\n';
      if (_brandsErrorMessage != null)
        errorMessage += 'Brands: $_brandsErrorMessage\n';
      if (_categoriesMappingErrorMessage != null)
        errorMessage += 'Category Map: $_categoriesMappingErrorMessage\n';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            errorMessage.trim(),
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_products.isEmpty) {
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
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_products[index]);
        },
      );
    }
  }

  // Helper widget to build individual product cards (similar to HomeScreen)
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
      // Corrected discount calculation: divide by 100 as discount is a percentage integer
      double discountedPrice = productPrice * (1 - (productDiscount / 100));
      displayCurrentPrice = '\$${discountedPrice.toStringAsFixed(0)}.00';
    } else {
      displayCurrentPrice = '\$${productPrice?.toStringAsFixed(0) ?? '0'}.00';
    }

    final String displayDiscount =
        (productDiscount != null && productDiscount > 0)
        ? '${productDiscount.toStringAsFixed(0)}%' // Display as percentage string
        : '0%';

    // Get brand name from the map using brandId
    final String brandName =
        _brandsMap[product.brandId]?.name ?? 'Unknown Brand';

    return GestureDetector(
      // Added GestureDetector here
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
                    brandName,
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
