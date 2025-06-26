import 'package:elure_app/models/api_models.dart'; // Ensure this contains CartListResponse, CartItem, Product models
import 'package:elure_app/screens/cart/checkout_screen.dart'; // Import the new checkout screen (renamed from cashier_detail_screen)
import 'package:elure_app/services/api_service.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  User? _currentUser;
  late Future<CartListResponse> _cartItemsFuture;

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

      // Fetch all products to get their stock information
      final ProductListResponse productListResponse = await _apiService
          .getProducts();
      final Map<int, Product> productsMap = {
        for (var product in productListResponse.data ?? [])
          product.id!: product,
      };

      // Enrich cart items with stock information
      final List<CartItem> enrichedCartItems = [];
      for (var item in cartResponse.data ?? []) {
        if (item.product?.id != null) {
          final Product? fullProduct = productsMap[item.product!.id!];
          if (fullProduct != null) {
            // Create a new CartProduct with stock information
            final CartProduct enrichedCartProduct = CartProduct(
              id: item.product!.id,
              name: item.product!.name,
              price: item.product!.price,
              stock: fullProduct.stock, // Use stock from full product details
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
  void _refreshCart() {
    setState(() {
      _cartItemsFuture = _loadCartDataFuture();
    });
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
              'Checkout successful! Total: \$${checkoutResponse.data!.total!.toStringAsFixed(2)}',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Checkout successful!')));
      }

      _refreshCart(); // Refresh cart to show it's empty after checkout

      // Navigate to CheckoutScreen after successful checkout, passing the CheckoutData
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during checkout: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
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
                          if (_currentUser?.id == null) // Simplified condition
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
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // --- Filter out items with 0 stock and consolidate duplicate products ---
                  final Map<int, CartItem> consolidatedItems = {};
                  for (var item in fetchedCartItems) {
                    // Only process items that have a product and stock > 0
                    if (item.product?.id != null &&
                        (item.product?.stock ?? 0) > 0) {
                      final int productId = item.product!.id!;
                      if (consolidatedItems.containsKey(productId)) {
                        // If product already exists, update its quantity
                        final existingItem = consolidatedItems[productId]!;
                        consolidatedItems[productId] = CartItem(
                          id: existingItem.id, // Keep the original cart item ID
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
                    } else if (item.product?.id != null &&
                        (item.product?.stock ?? 0) <= 0) {
                      // If stock is 0 or less, attempt to delete the item from the backend
                      // This is an optional behavior. You might instead just display it as "out of stock"
                      // without automatically deleting. For now, we'll keep the auto-delete for zero stock.
                      _deleteCartItem(item.id!);
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
                  // --- End filtering and consolidation logic ---

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
                            'Your cart is empty (all available items are out of stock)!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
                // Re-calculate total based on the original fetched data before consolidation
                // to match the API's actual sum if consolidation is only for display.
                // If the API consolidates, then `snapshot.data!.data!` would already be consolidated.
                // Assuming API returns individual items, so iterate raw fetched items for true total.

                // Filter out items with 0 stock before calculating total and item count
                final List<CartItem> availableItems = snapshot.data!.data!
                    .where((item) => (item.product?.stock ?? 0) > 0)
                    .toList();

                for (var item in availableItems) {
                  if (item.product?.price != null && item.quantity != null) {
                    currentTotal += (item.product!.price! * item.quantity!);
                  }
                }

                // For itemCount, you would apply the consolidation logic here as well before counting.
                final Map<int, CartItem> tempConsolidatedItems = {};
                if (availableItems.isNotEmpty) {
                  for (var item in availableItems) {
                    if (item.product?.id != null) {
                      final int productId = item.product!.id!;
                      if (tempConsolidatedItems.containsKey(productId)) {
                        tempConsolidatedItems[productId] = CartItem(
                          id: tempConsolidatedItems[productId]!.id,
                          product: tempConsolidatedItems[productId]!.product,
                          quantity:
                              (tempConsolidatedItems[productId]!.quantity ??
                                  0) +
                              (item.quantity ?? 0),
                          subtotal:
                              (tempConsolidatedItems[productId]!.subtotal ??
                                  0) +
                              (item.subtotal ?? 0),
                        );
                      } else {
                        tempConsolidatedItems[productId] = item;
                      }
                    }
                  }
                }
                itemCount = tempConsolidatedItems
                    .values
                    .length; // Count of unique items with stock > 0
                isCartEmpty = tempConsolidatedItems
                    .values
                    .isEmpty; // Check if unique items list is empty after filtering
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
    final productPrice = item.product?.price ?? 0;
    final int currentQuantity = item.quantity ?? 0; // Get current quantity
    final int availableStock = item.product?.stock ?? 0; // Get available stock

    // --- Using Dummy Data for missing API fields as requested ---
    // These will be used if the corresponding fields are NOT available in your CartProduct model
    final imageUrl =
        'https://placehold.co/80x80/FFC0CB/000000?text=Product'; // Dummy image URL
    final productBrand = 'Dummy Brand'; // Dummy brand name
    final double? productOriginalPrice =
        null; // No original price from API, so keep it null for conditional rendering

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
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
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
                const SizedBox(height: 5),
                // Item Brand (always show a brand, even if dummy)
                Text(
                  productBrand,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                // Price and Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prices
                    Row(
                      children: [
                        // Original price - only show if available and greater than current price
                        if (productOriginalPrice != null &&
                            productOriginalPrice > productPrice)
                          Text(
                            '\$${productOriginalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        // Always show current price from fetched data
                        Text(
                          '\$${productPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
            icon: const Icon(Icons.remove, color: Colors.black),
            onPressed: () {
              // For now, this button has no effect on the backend.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quantity update not yet supported by API.'),
                ),
              );
            },
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
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Check if current quantity is less than available stock before allowing increment
              if (currentQuantity < availableStock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quantity update not yet supported by API.'),
                  ),
                );
                // If you were to update the quantity locally and then call an API:
                // setState(() {
                //   item.quantity = currentQuantity + 1; // This would require `item.quantity` to be non-final
                // });
                // _apiService.updateCartItemQuantity(item.id!, currentQuantity + 1); // Hypothetical API call
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Maximum stock of $availableStock reached for this product.',
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
                  '\$${totalCartPrice.toStringAsFixed(2)} USD', // Use actual total price
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
