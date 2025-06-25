import 'package:elure_app/models/api_models.dart'; // Import API models for User and responses
import 'package:elure_app/screens/cart/cart_screen.dart'; // Import CartScreen to navigate to it
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:elure_app/services/local_storage_service.dart'; // Import LocalStorageService
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  // ApiService and LocalStorageService instances
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  // State for selected quantity to add
  int _selectedQuantityToAdd = 1;

  // State for quantity of this product already in the cart
  int _currentProductInCartQuantity = 0;

  // State for selected size and variant (dummy for now as API doesn't support)
  String? _selectedSize;
  String? _selectedVariant;

  // Available stock for the product, initialized from product data
  late int _availableStock;

  @override
  void initState() {
    super.initState();
    // Initialize selected size/variant if they exist in the product data
    if (widget.product['sizes'] != null &&
        widget.product['sizes']!.isNotEmpty) {
      _selectedSize = widget.product['sizes']!.split(',').first;
    }
    if (widget.product['variants'] != null &&
        widget.product['variants']!.isNotEmpty) {
      _selectedVariant = widget.product['variants']!.split(',').first;
    }

    // Initialize available stock from the passed product data
    _availableStock = int.tryParse(widget.product['stock'] ?? '0') ?? 0;

    // Load the quantity of this product already in the user's cart
    _loadCurrentProductCartQuantity();
  }

  // Function to load the current quantity of this product in the user's cart
  Future<void> _loadCurrentProductCartQuantity() async {
    final int? productId = int.tryParse(widget.product['id'] ?? '');
    if (productId == null) return; // Cannot check cart for invalid product ID

    try {
      final CartListResponse cartResponse = await _apiService.getCartItems();
      if (mounted) {
        final CartItem? existingCartItem = cartResponse.data?.firstWhere(
          (item) => item.product?.id == productId,
          orElse: () => CartItem(), // Return a dummy CartItem if not found
        );

        setState(() {
          if (existingCartItem?.product?.id == productId) {
            _currentProductInCartQuantity = existingCartItem!.quantity ?? 0;
          } else {
            _currentProductInCartQuantity = 0; // Not in cart
          }

          // Always initialize _selectedQuantityToAdd to 1 if there's available stock
          // beyond what's already in the cart. Otherwise, set to 0.
          if (_currentProductInCartQuantity >= _availableStock) {
            _selectedQuantityToAdd =
                0; // Cannot add more if already at max stock
          } else {
            _selectedQuantityToAdd = 1; // Start with 1 if there's room to add
          }
        });
      }
    } catch (e) {
      print('Error loading current product quantity in cart: $e');
      // Handle error, e.g., show a snackbar. Keep _currentProductInCartQuantity as 0.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load current cart status: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  // Function to handle adding the product to cart
  Future<void> _handleAddToCart() async {
    // Ensure product ID can be parsed to an integer
    final int? productId = int.tryParse(widget.product['id'] ?? '');

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Product ID is invalid.')),
      );
      return;
    }

    final int totalQuantityAfterAdd =
        _selectedQuantityToAdd + _currentProductInCartQuantity;

    // Check if the current quantity (selected to add + existing) exceeds available stock
    if (_selectedQuantityToAdd == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quantity to add.')),
      );
      return;
    }

    if (totalQuantityAfterAdd > _availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adding $_selectedQuantityToAdd would exceed total stock. Only $_availableStock in stock. Your cart currently has $_currentProductInCartQuantity of this item.',
          ),
        ),
      );
      return; // Stop the function if quantity is too high
    }

    // Check if user is logged in
    final User? currentUser = await _localStorageService.getUserData();
    if (currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Adding to cart...')));

    try {
      final CartAddResponse response = await _apiService.addToCart(
        productId,
        _selectedQuantityToAdd,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));

      // Refresh cart quantity after successful addition
      await _loadCurrentProductCartQuantity(); // Re-fetch current quantity in cart

      // Navigate to CartScreen after successful addition
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } on ErrorResponse catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: ${e.message}')),
      );
      print('Add to Cart Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
        ),
      );
      print('Unexpected Add to Cart Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract product details from the passed map
    final String name = widget.product['name'] ?? 'Unknown Product';
    final String brand = widget.product['brand'] ?? 'Unknown Brand';
    final String originalPrice = widget.product['originalPrice'] ?? '';
    final String currentPrice = widget.product['currentPrice'] ?? '\$0.00';
    final String discount = widget.product['discount'] ?? '';
    final String imageUrl =
        widget.product['imageUrl'] ??
        'https://placehold.co/300x300?text=Product';
    final String description =
        widget.product['description'] ?? 'No description available.';
    final List<String> availableSizes =
        (widget.product['sizes']?.split(',') ?? [])
            .where((s) => s.isNotEmpty)
            .toList();
    final List<String> availableVariants =
        (widget.product['variants']?.split(',') ?? [])
            .where((v) => v.isNotEmpty)
            .toList();

    // Determine if the add to cart button should be enabled
    final bool canAddToCart =
        _selectedQuantityToAdd > 0 &&
        (_selectedQuantityToAdd + _currentProductInCartQuantity) <=
            _availableStock &&
        _availableStock > 0;

    String addToCartButtonText;
    if (_availableStock == 0) {
      addToCartButtonText = 'Out of Stock';
    } else if (_currentProductInCartQuantity >= _availableStock) {
      addToCartButtonText = 'Already Max In Cart';
    } else if ((_selectedQuantityToAdd + _currentProductInCartQuantity) >
        _availableStock) {
      addToCartButtonText = 'Quantity Exceeds Stock';
    } else if (_selectedQuantityToAdd == 0 &&
        _currentProductInCartQuantity < _availableStock) {
      addToCartButtonText = 'Select Quantity'; // Prompt user to select quantity
    } else {
      addToCartButtonText = 'Add to Cart';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      if (originalPrice.isNotEmpty &&
                          originalPrice != currentPrice)
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: originalPrice.isNotEmpty ? 10 : 0),
                      Text(
                        currentPrice,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryPink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (discount.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryPink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$discount Off',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Size selection (if available)
                  if (availableSizes.isNotEmpty) ...[
                    const Text(
                      'Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableSizes.map((size) {
                        final isSelected =
                            (_selectedSize == null &&
                                size == availableSizes.first) ||
                            _selectedSize == size;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryPink
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? primaryPink
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Variant selection (if available)
                  if (availableVariants.isNotEmpty) ...[
                    const Text(
                      'Variant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableVariants.map((variant) {
                        final isSelected =
                            (_selectedVariant == null &&
                                variant == availableVariants.first) ||
                            _selectedVariant == variant;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVariant = variant;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryPink
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? primaryPink
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              variant,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quantity Selector
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQuantitySelector(),
                  const SizedBox(height: 30),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: canAddToCart ? _handleAddToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        addToCartButtonText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom AppBar for the Product Detail Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        widget.product['name'] ?? 'Product Details',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share_outlined, color: Colors.grey[700], size: 28),
          onPressed: () {
            print('Share product tapped');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // Builds the quantity selector
  Widget _buildQuantitySelector() {
    final int totalQuantityIfAdded =
        _selectedQuantityToAdd + _currentProductInCartQuantity;
    final bool canIncrement = totalQuantityIfAdded < _availableStock;
    final bool canDecrement =
        _selectedQuantityToAdd > 1; // Allows decrementing down to 1

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content tightly
        children: [
          IconButton(
            iconSize: 24,
            padding: const EdgeInsets.all(10),
            icon: const Icon(Icons.remove, color: Colors.black),
            onPressed: canDecrement
                ? () {
                    setState(() {
                      _selectedQuantityToAdd--;
                    });
                  }
                : null, // Disable if quantity is 1
          ),
          Text(
            _selectedQuantityToAdd.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            iconSize: 24,
            padding: const EdgeInsets.all(10),
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: canIncrement
                ? () {
                    setState(() {
                      _selectedQuantityToAdd++;
                    });
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cannot add more. Total quantity (current in cart: $_currentProductInCartQuantity + selected: $_selectedQuantityToAdd) would exceed available stock of $_availableStock.',
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
