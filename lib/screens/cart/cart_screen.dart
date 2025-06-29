import 'package:elure_app/screens/cart/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/public/';

  final ApiService _apiService = ApiService();
  // Removed: final LocalStorageService _localStorageService = LocalStorageService(); // No longer used in this screen

  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _subtotal = 0.0;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 1. Fetch basic cart items
      final CartListResponse cartResponse = await _apiService.getCartItems();

      // 2. Fetch all products to get detailed information (including images and full stock)
      final ProductListResponse productListResponse = await _apiService.getProducts();
      final Map<int, Product> productsMap = {
        for (var product in productListResponse.data ?? [])
          product.id!: product,
      };
      print(
          'DEBUG: Fetched Products Map: ${productsMap.map((key, value) => MapEntry(key, value.name))}'); // Log product names for clarity


      // 3. Enrich cart items with detailed product information
      final List<CartItem> enrichedCartItems = [];
      for (var item in cartResponse.data ?? []) {
        if (item.product?.id != null) {
          final Product? fullProduct = productsMap[item.product!.id!];
          if (fullProduct != null) {
            // Create a new CartProduct with enriched data from the full Product model
            final CartProduct enrichedCartProduct = CartProduct(
              id: item.product!.id,
              name: item.product!.name,
              price: item.product!.price,
              stock: fullProduct.stock, // Use stock from full product details
              imageUrl: fullProduct.images != null && fullProduct.images!.isNotEmpty
                  ? fullProduct.images!.first // Get the first image URL from the full Product
                  : null, // No image if list is empty or null
              discount: fullProduct.discount, // Pass the discount
            );
            // Add the enriched CartItem to the list
            enrichedCartItems.add(
              CartItem(
                id: item.id,
                product: enrichedCartProduct, // Use the enriched product
                quantity: item.quantity,
                subtotal: item.subtotal,
              ),
            );
            print('DEBUG: Enriched Cart Item for ${fullProduct.name}:');
            print('    Product ID: ${enrichedCartProduct.id}');
            print('    Original Price: ${enrichedCartProduct.price}');
            print('    Discount: ${enrichedCartProduct.discount}');
            print('    Image URL: ${enrichedCartProduct.imageUrl}');
          } else {
            // If product details are not found in the full product list,
            // keep the original item but log a warning.
            enrichedCartItems.add(item); // Keep original item
            print(
                'DEBUG: Product details not found in full product list for cart item ID: ${item.id}. Product name: ${item.product?.name}');
          }
        } else {
          // If product ID is null in cart item, add original and log warning
          enrichedCartItems.add(item);
          print('DEBUG: Cart item with null product ID encountered: ${item.id}');
        }
      }

      setState(() {
        _cartItems = enrichedCartItems; // Use the enriched list
        _calculateSubtotal();
      });
    } on ErrorResponse catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      print('Cart Error: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
      print('Unexpected Cart Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateSubtotal() {
    _subtotal = 0.0;
    for (var item in _cartItems) {
      // Ensure price and quantity are not null before calculation
      double itemPrice = (item.product?.price ?? 0).toDouble();
      int itemQuantity = (item.quantity ?? 0).toInt();

      // Apply discount if present
      double discountPercentage = (item.product?.discount ?? 0).toDouble();
      if (discountPercentage > 0) {
        itemPrice = itemPrice * (1 - (discountPercentage / 100));
      }

      _subtotal += itemPrice * itemQuantity;
    }
  }

  Future<void> _deleteCartItem(int cartItemId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _apiService.deleteCartItem(cartItemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart.')),
        );
      }
      _fetchCartItems(); // Refresh the cart list after deletion
    } on ErrorResponse catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: ${e.message}')),
        );
      }
      print('Delete Cart Item Error: ${e.message}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
      print('Unexpected Delete Cart Item Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryPink))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchCartItems,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator( // Added RefreshIndicator here
                        onRefresh: _fetchCartItems, // Calls _fetchCartItems on pull-to-refresh
                        color: primaryPink, // Customize the refresh indicator color
                        child: _cartItems.isEmpty
                            ? ListView( // Changed to ListView to allow RefreshIndicator for empty state
                                children: const [ // Children list for ListView
                                  SizedBox(height: 100), // Add some space from top
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                                        SizedBox(height: 20),
                                        Text(
                                          'Your cart is empty.',
                                          style: TextStyle(fontSize: 20, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  return _buildCartItemCard(_cartItems[index]);
                                },
                              ),
                      ),
                    ),
                    _buildBottomNavigationBar(), // Contains Checkout Button and Total
                  ],
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'My Cart',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[700], size: 28),
          onPressed: () {
            print('Notifications Tapped from Cart Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    // Determine the image URL for display
    String? rawImageUrl = item.product?.imageUrl;
    String imageUrlToDisplay;
    final String productName = item.product?.name ?? 'Unknown Product'; // For error logging

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http://') ||
          rawImageUrl.startsWith('https://')) {
        imageUrlToDisplay = rawImageUrl; // Already a full URL
      } else {
        // Prepend base URL for relative paths
        String finalBaseUrl = _baseUrl;
        if (!finalBaseUrl.endsWith('/')) {
          finalBaseUrl += '/';
        }
        String cleanedImageUrl = rawImageUrl;
        // If rawImageUrl already contains 'public/', remove it to avoid duplication if _baseUrl also has it
        if (rawImageUrl.startsWith('public/')) {
          cleanedImageUrl = rawImageUrl.substring('public/'.length);
        }
        if (cleanedImageUrl.startsWith('/') && cleanedImageUrl.length > 1) {
          cleanedImageUrl = cleanedImageUrl.substring(1);
        }

        imageUrlToDisplay = '$finalBaseUrl$cleanedImageUrl';
      }
    } else {
      imageUrlToDisplay =
          'https://placehold.co/80x80/FFC0CB/000000?text=Product'; // Fallback placeholder
    }

    final double itemPrice = (item.product?.price ?? 0).toDouble();
    final int itemQuantity = (item.quantity ?? 0).toInt();

    // Calculate price after discount
    double priceAfterDiscount = itemPrice;
    double discountPercentage = (item.product?.discount ?? 0).toDouble();
    if (discountPercentage > 0) {
      priceAfterDiscount = itemPrice * (1 - (discountPercentage / 100));
    }

    final String displayPrice = _currencyFormatter.format(priceAfterDiscount);
    final String displaySubtotal = _currencyFormatter.format(priceAfterDiscount * itemQuantity);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Container(
              width: 80, // Adjusted width as per your old code
              height: 80, // Adjusted height as per your old code
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: ClipRRect(
                // Clip to apply border radius
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrlToDisplay, // Use the determined image URL
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      'ERROR: Image loading failed for $productName. URL: $imageUrlToDisplay. Error: $error',
                    );
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.product?.name ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // Product Price (with discount if applicable)
                  Row(
                    children: [
                      if (item.product?.discount != null && item.product!.discount! > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _currencyFormatter.format(itemPrice), // Original price
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      Text(
                        displayPrice, // Price after discount
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryPink,
                        ),
                      ),
                    ],
                  ),
                  if (item.product?.discount != null && item.product!.discount! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '${item.product!.discount!.toInt()}% Off',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Quantity and Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity controls (simplified, actual update logic for API would be here)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Qty: ${itemQuantity}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      Text(
                        displaySubtotal, // Subtotal for this item
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                if (item.id != null) {
                  _deleteCartItem(item.id!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot delete item: ID is missing.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                _currencyFormatter.format(_subtotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _cartItems.isEmpty
                  ? null // Disable button if cart is empty
                  : () {
                      // Navigate to the new CheckoutScreen (confirmation screen)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            cartItems: _cartItems, // Pass the cart items
                            subtotal: _subtotal, // Pass the calculated subtotal
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
