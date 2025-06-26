import 'package:elure_app/models/api_models.dart'; // Ensure this contains CartListResponse, CartItem, Product models
import 'package:elure_app/screens/cart/checkout_screen.dart'; // Import the new checkout screen (renamed from cashier_detail_screen)
import 'package:elure_app/services/api_service.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  User? _currentUser;
  late Future<CartListResponse> _cartItemsFuture;

  // Initialize NumberFormat for Rupiah (IDR) with dot as thousands separator
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Indonesian locale
    symbol: 'Rp', // Rupiah symbol
    decimalDigits: 0, // No decimal digits for whole rupiah
  );

  @override
  void initState() {
    super.initState();
    // Initialize _cartItemsFuture synchronously with an empty, resolved Future.
    // This guarantees that _cartItemsFuture is always initialized when the widget first builds,
    // preventing the LateInitializationError.
    _cartItemsFuture = Future.value(
      CartListResponse(message: 'Loading cart data...', data: []),
    );

    // Then, asynchronously load the actual cart data and update the state.
    _loadCartDataFuture()
        .then((data) {
          if (mounted) {
            setState(() {
              _cartItemsFuture = Future.value(data);
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _cartItemsFuture = Future.error(error);
            });
          }
        });
  }

  // A new method to encapsulate the logic for loading user data and fetching cart items
  // This method returns a Future<CartListResponse> which can be directly assigned.
  Future<CartListResponse> _loadCartDataFuture() async {
    try {
      _currentUser = await _localStorageService.getUserData();
      if (!mounted) {
        // If the widget is disposed before user data is loaded, return an empty response
        return CartListResponse(
          message: 'Widget disposed before user data loaded.',
          data: [],
        );
      }

      // If user is not logged in, return an error Future
      if (_currentUser?.id == null) {
        return Future.error(Exception('Please log in to view your cart.'));
      }

      // Fetch cart items
      final CartListResponse cartResponse = await _apiService.getCartItems();
      // FIX: Removed .toJson() call on CartItem as it's not defined for CartItem model
      print('DEBUG: Raw Cart Response Data: ${cartResponse.data?.toList()}');

      // Fetch all products to get their stock and image information
      final ProductListResponse productListResponse = await _apiService
          .getProducts();
      final Map<int, Product> productsMap = {
        for (var product in productListResponse.data ?? [])
          product.id!: product,
      };
      print(
        'DEBUG: Fetched Products Map: ${productsMap.map((key, value) => MapEntry(key, value.toJson()))}',
      );

      // Enrich cart items with stock, image, and discount information
      final List<CartItem> enrichedCartItems = [];
      for (var item in cartResponse.data ?? []) {
        if (item.product?.id != null) {
          final Product? fullProduct = productsMap[item.product!.id!];
          if (fullProduct != null) {
            // Create a new CartProduct with stock, image, and discount information
            final CartProduct enrichedCartProduct = CartProduct(
              id: item.product!.id,
              name: item.product!.name,
              price: item.product!.price,
              stock: fullProduct.stock, // Use stock from full product details
              imageUrl:
                  fullProduct.images != null && fullProduct.images!.isNotEmpty
                  ? fullProduct
                        .images!
                        .first // Get the first image URL
                  : null,
              discount: fullProduct.discount, // Pass the discount
            );
            // Add the enriched CartItem to the list
            enrichedCartItems.add(
              CartItem(
                id: item.id,
                product: enrichedCartProduct,
                quantity: item.quantity,
                subtotal: item.subtotal,
              ),
            );
            print('DEBUG: Enriched Cart Item for ${fullProduct.name}:');
            print('  Product ID: ${enrichedCartProduct.id}');
            print('  Original Price: ${enrichedCartProduct.price}');
            print('  Discount: ${enrichedCartProduct.discount}');
            print('  Image URL: ${enrichedCartProduct.imageUrl}');
          } else {
            // If product details are not found, keep the item but indicate no stock and no image
            enrichedCartItems.add(
              CartItem(
                id: item.id,
                product: item
                    .product, // Keep original product data (will have null stock/imageUrl/discount)
                quantity: item.quantity,
                subtotal: item.subtotal,
              ),
            );
            print(
              'DEBUG: Product details not found for cart item ID: ${item.id}. Product name: ${item.product?.name}',
            );
          }
        }
      }

      return CartListResponse(
        message: cartResponse.message,
        data: enrichedCartItems,
      );
    } catch (e) {
      print('Error loading cart data: $e');
      if (!mounted) {
        // If the widget is disposed during an error, return an empty response
        return CartListResponse(
          message: 'Widget disposed during cart data loading.',
          data: [],
        );
      }
      // Return an error Future if something goes wrong during loading
      return Future.error(Exception('Failed to load cart data: $e'));
    }
  }

  // Refreshes the cart items by re-calling _loadCartDataFuture and updating state
  Future<void> _refreshCart() async {
    // This method is now async to be used with RefreshIndicator
    setState(() {
      _cartItemsFuture = _loadCartDataFuture();
    });
    // Await the future so RefreshIndicator knows when the refresh is complete
    await _cartItemsFuture;
  }

  // Handles checkout process
  Future<void> _handleCheckout() async {
    // Simplified null check: if _currentUser or its id is null, the user is not logged in.
    if (_currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to complete checkout.')),
      );
      return;
    }

    try {
      final checkoutResponse = await _apiService.checkout();
      if (!mounted) return; // Check if the widget is still in the tree

      // Display message from API response
      if (checkoutResponse.message.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(checkoutResponse.message)));
      } else if (checkoutResponse.data?.total != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Checkout successful! Total: ${_currencyFormatter.format(checkoutResponse.data!.total!)}',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Checkout successful!')));
      }

      _refreshCart(); // Refresh cart to show it's empty after checkout

      // Navigate to CheckoutScreen after successful addition
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            checkoutData: checkoutResponse.data,
          ), // Pass checkout data here
        ),
      );
    } on ErrorResponse catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Checkout failed: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
        ),
      );
    }
  }

  // Handles deleting a cart item
  Future<void> _deleteCartItem(int cartItemId) async {
    try {
      final deleteResponse = await _apiService.deleteCartItem(cartItemId);
      if (!mounted) return; // Check if the widget is still in the tree
      // Removed unnecessary null check and '!' for deleteResponse.message
      if (deleteResponse.message.isNotEmpty) {
        // Check if message is not empty string
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(deleteResponse.message)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart.')),
        );
      }
      _refreshCart(); // Refresh cart after deletion
    } on ErrorResponse catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: ${e.message}'),
        ), // Removed `?? 'Unknown API error'`
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: _buildSearchBar(), // Search bar
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              // Added RefreshIndicator here
              onRefresh: _refreshCart, // Calls the refresh method
              color: primaryPink, // Customize refresh indicator color
              child: FutureBuilder<CartListResponse>(
                future: _cartItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryPink),
                    );
                  } else if (snapshot.hasError) {
                    // Display specific error for not logged in, or general error
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              // Cast error to Exception and use its message if available, otherwise default
                              (snapshot.error is Exception)
                                  ? (snapshot.error as Exception)
                                        .toString()
                                        .replaceFirst('Exception: ', '')
                                  : snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            // The `_currentUser?.id == null` check is sufficient.
                            if (_currentUser?.id ==
                                null) // Simplified condition
                              const Text(
                                'Please navigate to the login/signup screen to proceed.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  _refreshCart, // Re-initialize (fetch user + cart)
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Retry / Refresh',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    // `snapshot.data` is non-null here because `snapshot.hasData` is true.
                    // `snapshot.data.data` can still be null, so null-aware access is needed.
                    List<CartItem>? fetchedCartItems = snapshot.data!.data;

                    if (fetchedCartItems == null || fetchedCartItems.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Your cart is empty!',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // --- Consolidate duplicate products ---
                    final Map<int, CartItem> consolidatedItems = {};
                    for (var item in fetchedCartItems) {
                      if (item.product?.id != null) {
                        final int productId = item.product!.id!;
                        if (consolidatedItems.containsKey(productId)) {
                          // If product already exists, update its quantity
                          final existingItem = consolidatedItems[productId]!;
                          consolidatedItems[productId] = CartItem(
                            id: existingItem
                                .id, // Keep the original cart item ID
                            product: existingItem.product,
                            quantity:
                                (existingItem.quantity ?? 0) +
                                (item.quantity ?? 0),
                            subtotal:
                                (existingItem.subtotal ?? 0) +
                                (item.subtotal ?? 0),
                          );
                        } else {
                          // Add new item if not already in the map
                          consolidatedItems[productId] = item;
                        }
                      }
                    }
                    final List<CartItem> displayCartItems = consolidatedItems
                        .values
                        .toList();
                    // Sort by product name for consistent display
                    displayCartItems.sort(
                      (a, b) => (a.product?.name ?? '').compareTo(
                        b.product?.name ?? '',
                      ),
                    );
                    // --- End consolidation logic ---

                    if (displayCartItems.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Your cart is empty!', // Simplified message
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount:
                          displayCartItems.length, // Use the consolidated list
                      itemBuilder: (context, index) {
                        final item = displayCartItems[index];
                        return _buildCartItemCard(item, index);
                      },
                    );
                  } else {
                    return const Center(child: Text('No cart data available.'));
                  }
                },
              ),
            ),
          ),
          // Pass the calculated total price to _buildBottomSummary
          FutureBuilder<CartListResponse>(
            future: _cartItemsFuture,
            builder: (context, snapshot) {
              double currentTotal = 0.0;
              bool isCartEmpty = true;
              int itemCount = 0; // Initialize item count
              // `snapshot.data` is non-null here because `snapshot.hasData` is true.
              // `snapshot.data.data` can still be null, so null-aware access is needed.
              if (snapshot.hasData && snapshot.data!.data != null) {
                // Calculate total and item count from all fetched items (no stock filtering here)
                final Map<int, CartItem> tempConsolidatedItems = {};
                for (var item in snapshot.data!.data!) {
                  if (item.product?.id != null) {
                    final int productId = item.product!.id!;
                    if (tempConsolidatedItems.containsKey(productId)) {
                      tempConsolidatedItems[productId] = CartItem(
                        id: tempConsolidatedItems[productId]!.id,
                        product: tempConsolidatedItems[productId]!.product,
                        quantity:
                            (tempConsolidatedItems[productId]!.quantity ?? 0) +
                            (item.quantity ?? 0),
                        subtotal:
                            (tempConsolidatedItems[productId]!.subtotal ?? 0) +
                            (item.subtotal ?? 0),
                      );
                    } else {
                      tempConsolidatedItems[productId] = item;
                    }
                  }
                }

                for (var item in tempConsolidatedItems.values) {
                  if (item.product?.price != null && item.quantity != null) {
                    // Apply discount when calculating total
                    double itemPrice = item.product!.price!.toDouble();
                    if (item.product?.discount != null &&
                        item.product!.discount! > 0) {
                      itemPrice =
                          itemPrice * (1 - (item.product!.discount! / 100));
                    }
                    currentTotal += (itemPrice * item.quantity!);
                  }
                }

                itemCount = tempConsolidatedItems.values.length;
                isCartEmpty = tempConsolidatedItems.values.isEmpty;
              }

              return _buildBottomSummary(currentTotal, isCartEmpty, itemCount);
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'View Cart',
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
            print('Notifications Tapped from Cart Screen');
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
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
            onPressed: () {
              print('Camera search tapped');
            },
          ),
        ],
      ),
    );
  }

  // Builds an individual cart item card using CartItem model
  Widget _buildCartItemCard(CartItem item, int index) {
    // Ensure product and its properties are not null before accessing
    final productName = item.product?.name ?? 'Unknown Product';
    final int originalPriceInt = item.product?.price ?? 0;
    final int? discount = item.product?.discount; // Discount is int

    // Calculate prices
    double priceAfterDiscount = originalPriceInt.toDouble();
    if (discount != null && discount > 0) {
      priceAfterDiscount = originalPriceInt * (1 - (discount / 100));
    }

    final int currentQuantity = item.quantity ?? 0; // Get current quantity
    final int availableStock = item.product?.stock ?? 0; // Get available stock

    // Determine the image URL for display
    // FIX: Check if imageUrl already contains 'http' or 'https' to avoid double-prefixing
    String? rawImageUrl = item.product?.imageUrl;
    String imageUrlToDisplay;

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http://') ||
          rawImageUrl.startsWith('https://')) {
        imageUrlToDisplay = rawImageUrl; // Already a full URL
      } else {
        imageUrlToDisplay =
            '$_baseUrl$rawImageUrl'; // Prepend base URL for relative paths
      }
    } else {
      imageUrlToDisplay =
          'https://placehold.co/80x80/FFC0CB/000000?text=Product'; // Fallback placeholder
    }

    print('DEBUG in _buildCartItemCard for $productName:');
    print('  Image URL to Display: $imageUrlToDisplay');
    print('  Original Price: $originalPriceInt');
    print('  Discount: $discount');
    print('  Price After Discount: $priceAfterDiscount');

    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Space between cards
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Item Image
          Container(
            width: 80,
            height: 80,
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
              children: <Widget>[
                // Item Name
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Removed the Brand Text widget here as requested
                const SizedBox(height: 10),
                // Price and Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.baseline, // Align text baselines
                  textBaseline: TextBaseline
                      .alphabetic, // Required for baseline alignment
                  children: [
                    // Prices
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (discount != null && discount > 0) ...[
                          Text(
                            _currencyFormatter.format(originalPriceInt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ), // Space between original and discounted price
                        ],
                        Text(
                          _currencyFormatter.format(priceAfterDiscount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (discount != null && discount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${discount.toInt()}% Off', // Display int discount
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Quantity Selector (local state only, no API update for quantity provided)
                    _buildQuantitySelector(
                      item,
                      currentQuantity,
                      availableStock,
                    ),
                  ],
                ),
                // Display "Out of Stock" if stock is 0
                if (availableStock == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Out of Stock',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // item.id is now an int? from the updated api_models.dart, so direct check is fine.
              if (item.id != null) {
                _deleteCartItem(item.id!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Error: Invalid cart item ID. Cannot delete.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Builds the quantity selector for a cart item
  Widget _buildQuantitySelector(
    CartItem item,
    int currentQuantity,
    int availableStock,
  ) {
    // NOTE: This quantity selector currently only updates local state.
    // Your provided API does not have an endpoint to update quantity for an existing cart item.
    // If you need this functionality, an.endpoint like PUT /api/cart/{cart_item_id}
    // with quantity in body would be required, and _apiService would need to be updated.
    final bool canIncrement = currentQuantity < availableStock;
    final bool canDecrement = currentQuantity > 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content tightly
        children: [
          IconButton(
            iconSize: 20,
            constraints: const BoxConstraints(), // Remove default padding
            padding: const EdgeInsets.all(5),
            icon: Icon(
              Icons.remove,
              color: canDecrement ? Colors.black : Colors.grey,
            ), // Conditional color
            onPressed: canDecrement
                ? () {
                    // Placeholder for future API integration
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Quantity update not yet supported by API.',
                        ),
                      ),
                    );
                  }
                : null, // Disable if quantity is 1
          ),
          Text(
            currentQuantity.toString(), // Display current quantity
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            iconSize: 20,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(5),
            icon: Icon(
              Icons.add,
              color: canIncrement ? Colors.black : Colors.grey,
            ), // Conditional color
            onPressed: canIncrement
                ? () {
                    // Placeholder for future API integration
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Quantity update not yet supported by API.',
                        ),
                      ),
                    );
                  }
                : null, // Disable if at max stock
          ),
        ],
      ),
    );
  }

  // Builds the bottom summary bar with total price and action buttons
  Widget _buildBottomSummary(
    double totalCartPrice,
    bool isCartEmpty,
    int itemCount,
  ) {
    // Simplified null check for _currentUser!.id, as _currentUser being null implies id is also null
    final bool checkoutEnabled =
        !isCartEmpty && (_currentUser != null && _currentUser!.id != null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ), // Rounded top corners
      ),
      child: Row(
        children: <Widget>[
          // Total items count and price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryPink,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Text(
                    // Display the actual item count passed from FutureBuilder
                    itemCount.toString(),
                    style: const TextStyle(
                      // Added const for TextStyle
                      color: primaryPink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _currencyFormatter.format(
                    totalCartPrice,
                  ), // Use formatted price
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Chat Icon Button (Placeholder for message)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                print('Chat button clicked');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Icon(Icons.chat_bubble_outline, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 10),
          // Buy Now (Checkout) Button
          Expanded(
            child: ElevatedButton(
              onPressed: checkoutEnabled
                  ? _handleCheckout
                  : null, // Disable if cart empty or not logged in
              style: ElevatedButton.styleFrom(
                backgroundColor: checkoutEnabled
                    ? primaryPink
                    : Colors.grey[400], // Adjust color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(
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
