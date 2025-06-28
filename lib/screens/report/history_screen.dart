import 'package:elure_app/screens/report/history_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:elure_app/services/local_storage_service.dart';

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

  late Future<HistoryListResponse> _historyFuture;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<HistoryListResponse> _fetchHistory() async {
    try {
      // Check if user is logged in before attempting to fetch history
      final user = await _localStorageService.getUserData();
      if (user == null || user.id == null) {
        throw Exception('Please log in to view your transaction history.');
      }
      return await _apiService.getTransactionHistory();
    } catch (e) {
      print('Error fetching history: $e');
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: FutureBuilder<HistoryListResponse>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryPink),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _historyFuture = _fetchHistory(); // Retry
                        });
                      },
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
            );
          } else if (snapshot.hasData) {
            final List<HistoryItem> history = snapshot.data!.data ?? [];
            if (history.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No order history found.',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryCard(item);
              },
            );
          } else {
            return const Center(child: Text('No history data available.'));
          }
        },
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
                }).toList()
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
