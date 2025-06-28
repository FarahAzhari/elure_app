import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:elure_app/screens/product/product_detail_screen.dart'; // Import ProductDetailScreen

class ProductListScreen extends StatefulWidget {
  final String
  initialSearchQuery; // Optional: to receive search query from HomeScreen

  const ProductListScreen({super.key, this.initialSearchQuery = ''});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/public/';

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<Product> _allProducts = []; // Stores all products fetched from API
  List<Product> _filteredProducts =
      []; // Stores products filtered by search query
  Map<int, Brand> _brandsMap = {};
  Map<int, Category> _categoriesMap = {};

  bool _isLoading = true;
  String? _errorMessage;
  User? _loggedInUser;

  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  // Removed debounce here as it's typically handled where the text is typed (e.g., HomeScreen).
  // If user types directly in this screen's search bar, we'll filter immediately or with simpler debounce.

  @override
  void initState() {
    super.initState();
    _currentSearchQuery = widget.initialSearchQuery;
    _searchController.text = widget.initialSearchQuery; // Set initial text
    _searchController.addListener(
      _onSearchChanged,
    ); // Listen for direct input on this screen

    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentSearchQuery = _searchController.text;
      _filterProducts(); // Re-filter products immediately on change
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _loggedInUser = await _localStorageService.getUserData();

      final brandResponse = await _apiService.getBrands();
      _brandsMap = {for (var b in brandResponse.data ?? []) b.id!: b};

      final categoryResponse = await _apiService.getCategories();
      _categoriesMap = {for (var c in categoryResponse.data ?? []) c.id!: c};

      final productResponse = await _apiService.getProducts();
      _allProducts = productResponse.data ?? [];

      _filterProducts(); // Initial filtering based on initialSearchQuery

      print('ProductListScreen: All data loaded successfully!');
    } on ErrorResponse catch (e) {
      setState(() {
        _errorMessage = 'API Error: ${e.message}';
      });
      print('ProductListScreen: API Error during data load: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
      print('ProductListScreen: Unexpected error during data load: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Filters _allProducts into _filteredProducts based on _currentSearchQuery
  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final productName = product.name?.toLowerCase() ?? '';
        final query = _currentSearchQuery.toLowerCase();
        return productName.contains(query);
      }).toList();
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
        1,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        // No need to update cart count badge here, as this screen doesn't have it.
        // If navigating to CartScreen, it will refresh its own data.
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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSearchBar(), // Local search bar for this screen
                ),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_filteredProducts[index]);
                          },
                        ),
                ),
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
          Navigator.pop(context); // Go back to the Home Screen
        },
      ),
      title: const Text(
        'Product Search',
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
            print('Notifications Tapped from Product List Screen');
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16),
              onSubmitted: (value) {
                // You can add an explicit search action here if needed,
                // but _onSearchChanged already filters on every key stroke
                print('Search submitted: $value');
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
            onPressed: () {
              print('Camera search tapped from Product List');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    String imageUrlToDisplay = '';
    if (product.images != null && product.images!.isNotEmpty) {
      imageUrlToDisplay = product.images!.first;
      if (!imageUrlToDisplay.startsWith('http://') &&
          !imageUrlToDisplay.startsWith('https://')) {
        imageUrlToDisplay = '$_baseUrl$imageUrlToDisplay';
      }
    } else {
      imageUrlToDisplay =
          'https://placehold.co/150x150/FF00FF/FFFFFF?text=${product.name?.substring(0, 1) ?? 'P'}';
    }

    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final double? productPrice = product.price?.toDouble();
    final double? productDiscount = product.discount?.toDouble();

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
        ? '${productDiscount.toStringAsFixed(0)}%'
        : '0%';

    final String brandName =
        _brandsMap[product.brandId]?.name ?? 'Unknown Brand';

    return GestureDetector(
      onTap: () {
        print('Tapped on product: ${product.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(product: product, brandName: brandName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrlToDisplay,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$displayDiscount OFF',
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryPink,
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
                    product.name ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
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
                        displayCurrentPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    brandName,
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
