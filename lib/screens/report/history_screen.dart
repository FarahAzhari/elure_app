import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/screens/report/history_detail_screen.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/public/';

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  // Store all fetched history items
  List<HistoryItem> _allHistoryItems = [];
  // Store currently displayed (filtered) history items
  List<HistoryItem> _filteredHistoryItems = [];
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _searchController.addListener(
      _filterHistory,
    ); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHistory); // Remove listener
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Function to fetch history and populate lists
  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _localStorageService.getUserData();
      if (user == null || user.id == null) {
        throw Exception('Please log in to view your transaction history.');
      }
      final response = await _apiService.getTransactionHistory();
      if (mounted) {
        setState(() {
          _allHistoryItems = response.data ?? [];
          _isLoading = false;
        });
        _filterHistory(); // Apply initial filter (empty query shows all)
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
      print('Error fetching history: $e');
    }
  }

  // Function to filter history items based on the search query
  void _filterHistory() {
    final String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistoryItems = _allHistoryItems.where((historyItem) {
        // Search by Order ID
        final String orderIdString = historyItem.id?.toString() ?? '';
        if (orderIdString.contains(query)) {
          return true;
        }

        // Search by Product Name within the order items
        if (historyItem.items != null) {
          for (var item in historyItem.items!) {
            if (item.product?.name?.toLowerCase().contains(query) ?? false) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    });
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
                    Text(
                      'Error: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchHistory, // Retry
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
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchHistory, // Re-fetch data on pull-to-refresh
              color: primaryPink, // Customize the refresh indicator color
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: _buildSearchBar(), // Search bar
                  ),
                  Expanded(
                    child: _filteredHistoryItems.isEmpty
                        ? ListView(
                            // Use ListView to ensure RefreshIndicator works even when empty
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.2, // Adjust height
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 80,
                                      color: Colors.grey[400], // Lighter grey
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _searchController.text.isNotEmpty
                                          ? 'No orders match your search.'
                                          : 'No order history found.',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey[600], // Darker grey
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _filteredHistoryItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredHistoryItems[index];
                              return _buildHistoryCard(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Order History',
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
            print('Notifications Tapped from History Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // Builds the Search Bar with consistent design
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
                hintText: 'Search by Order ID or Product Name...', // Hint text
                border: InputBorder.none, // No underline
                isDense: true, // Reduce vertical space
                contentPadding: EdgeInsets.zero, // Remove internal padding
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Camera icon for visual consistency with other search bars
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

  Widget _buildHistoryCard(HistoryItem historyItem) {
    final String formattedDate = historyItem.createdAt != null
        ? DateFormat(
            'MMMM dd,yyyy',
          ).format(DateTime.parse(historyItem.createdAt!))
        : 'N/A';
    final String totalAmount = _currencyFormatter.format(
      historyItem.total ?? 0,
    );

    return GestureDetector(
      // Wrap with GestureDetector to make it tappable
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailScreen(historyItem: historyItem),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: ${historyItem.id ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              if (historyItem.items != null && historyItem.items!.isNotEmpty)
                ...historyItem.items!.map((item) {
                  final productName = item.product?.name ?? 'Unknown Product';
                  final quantity = item.quantity ?? 0;
                  final price = item.product?.price ?? 0;
                  // Calculate item total considering discount from CartProduct
                  double itemPrice = price.toDouble();
                  if (item.product?.discount != null &&
                      item.product!.discount! > 0) {
                    itemPrice =
                        itemPrice * (1 - (item.product!.discount! / 100));
                  }
                  final itemSubtotal = _currencyFormatter.format(
                    itemPrice * quantity,
                  );

                  String imageUrlToDisplay =
                      item.product?.imageUrl != null &&
                          item.product!.imageUrl!.isNotEmpty
                      ? (item.product!.imageUrl!.startsWith('http')
                            ? item.product!.imageUrl!
                            : '$_baseUrl${item.product!.imageUrl!}')
                      : 'https://placehold.co/50x50/FFC0CB/000000?text=P';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        // Item Image
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrlToDisplay,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 20),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: $quantity',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          itemSubtotal,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                const Text(
                  'No items found for this order.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    totalAmount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryPink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
