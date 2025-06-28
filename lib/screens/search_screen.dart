import 'package:elure_app/screens/product/product_list_screen.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final String
  initialSearchQuery; // To pre-fill the search bar if coming from HomeScreen

  const SearchScreen({super.key, this.initialSearchQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Placeholder for recent searches (can be made dynamic with local storage later)
  final List<String> _recentSearches = [
    'Calvin Klein Eternity EDT Perfume',
    'Chanel No. 5 Perfume EDP',
    'Yves Saint Laurent Blouse EDP',
    'Armani Code Eau de Toilette Refillble',
  ];

  final List<String> _trendingSearches = [
    'Ethereal Charm by Divine Scents',
    'Moonlit Desire by Midnight Essence',
    'Rosewood Elixir by Natura Perfumery',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text =
        widget.initialSearchQuery; // Set initial query from HomeScreen
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to navigate to ProductListScreen with the search query
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductListScreen(initialSearchQuery: query.trim()),
        ),
      );
      // Optionally, you might want to pop this search screen after navigating
      // if you don't want it in the back stack when the product list is shown.
      // Navigator.pop(context); // Consider if this is desired UX
    } else {
      // Show a message if search query is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term.')),
      );
    }
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
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    // Optionally clear recent searches or update suggestions
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
            Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 16),
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
