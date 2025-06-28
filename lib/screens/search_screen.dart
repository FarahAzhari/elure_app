import 'package:elure_app/screens/product/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:elure_app/services/local_storage_service.dart'; // Import LocalStorageService

class SearchScreen extends StatefulWidget {
  final String
  initialSearchQuery; // Optional: to receive search query from HomeScreen

  const SearchScreen({super.key, this.initialSearchQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocalStorageService _localStorageService =
      LocalStorageService(); // Instance of LocalStorageService

  List<String> _recentSearches = []; // Now dynamically loaded

  final List<String> _trendingSearches = [
    'HydraGlow Moisturizer by Lumière Skin',
    'Velvet Radiance Serum by Bloom Beauty',
    'CrystalClear Cleanser by PureSkin Lab',
    'Golden Dew Face Oil by Elixir Botanica',
    'Silken Touch Primer by Aura Blends',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text =
        widget.initialSearchQuery; // Set initial query from HomeScreen
    _loadRecentSearches(); // Load recent searches when the screen initializes
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    final searches = await _localStorageService.getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  // Function to navigate to ProductListScreen with the search query
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      _localStorageService.saveRecentSearch(
        query.trim(),
      ); // Save the search query
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductListScreen(initialSearchQuery: query.trim()),
        ),
      ).then((_) {
        // When returning from ProductListScreen, refresh recent searches
        _loadRecentSearches();
      });
    } else {
      // Show a message if search query is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term.')),
      );
    }
  }

  // Function to remove a search query from recent searches
  Future<void> _removeSearchFromRecent(String queryToRemove) async {
    await _localStorageService.removeSpecificRecentSearch(queryToRemove);
    _loadRecentSearches(); // Reload the list to update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Search Input Field
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Recent Searches Section
            if (_recentSearches.isNotEmpty) ...[
              _buildSectionTitle('Recent Searches'),
              const SizedBox(height: 10),
              _buildSearchHistoryList(_recentSearches),
              const SizedBox(height: 20),
            ],

            // Trending Searches Section
            if (_trendingSearches.isNotEmpty) ...[
              _buildSectionTitle('Trending Searches'),
              const SizedBox(height: 10),
              _buildTrendingSearchList(_trendingSearches),
              const SizedBox(height: 20),
            ],

            // You can add more sections like "Popular Categories" or "Top Products" here
          ],
        ),
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
        'Search',
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
            print('Notifications Tapped from Search Screen');
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
              autofocus: true, // Automatically focus the search bar
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 12.0,
                ), // Adjust vertical padding for centering
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    // When clearing, also refresh recent searches to reflect any changes if recent searches were cleared programmatically
                    // This specific reload might not be strictly necessary if clear only affects current input,
                    // but it ensures consistency if we had a clear all button for recent searches on this screen.
                    // For now, it doesn't harm.
                  },
                ),
              ),
              style: const TextStyle(fontSize: 16),
              onSubmitted:
                  _performSearch, // Trigger search when enter is pressed
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSearchHistoryList(List<String> searches) {
    return Column(
      children: searches
          .map((search) => _buildSearchHistoryItem(search))
          .toList(),
    );
  }

  Widget _buildSearchHistoryItem(String searchText) {
    return GestureDetector(
      onTap: () {
        _searchController.text = searchText; // Populate search bar
        _performSearch(searchText); // Perform search for the tapped item
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                searchText,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            // NEW: 'x' button to remove the item
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
              onPressed: () {
                _removeSearchFromRecent(searchText); // Call remove function
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSearchList(List<String> searches) {
    return Column(
      children: searches
          .map((search) => _buildTrendingSearchItem(search))
          .toList(),
    );
  }

  Widget _buildTrendingSearchItem(String searchText) {
    return GestureDetector(
      onTap: () {
        _searchController.text = searchText; // Populate search bar
        _performSearch(searchText); // Perform search for the tapped item
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                searchText,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 16),
          ],
        ),
      ),
    );
  }
}
