import 'package:flutter/material.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  // Define the primary pink color for consistency.
  static const Color primaryPink = Color(0xFFE91E63);

  // Sample data for featured brands. In a real application, this would come from an API.
  final List<Map<String, String>> _featuredBrands = [
    {
      'name': 'L\'Oréal',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=L',
    },
    {
      'name': 'Estée',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=E',
    },
    {
      'name': 'Maybelline',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=M',
    },
    {
      'name': 'MAC',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=MAC',
    },
    {
      'name': 'Fenty',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=F',
    },
    {
      'name': 'Lancôme',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=LA',
    },
    {
      'name': 'Dior',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=D',
    },
    {
      'name': 'Clinique',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=C',
    },
    {
      'name': 'Charlotte',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=CH',
    },
    {
      'name': 'NARS',
      'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=N',
    },
  ];

  // Sample data for most popular brand.
  final Map<String, String> _mostPopularBrand = {
    'name': 'Fenty Beauty',
    'imageUrl': 'https://placehold.co/100x100/F0F0F0/000000?text=FB',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context), // Custom AppBar for brand screen
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: _buildSearchBar(), // Search bar for brands
            ),
            const SizedBox(height: 20),

            // Featured Brand Section Header
            _buildSectionHeader('Featured Brand', () {
              print('See All Featured Brands tapped');
            }),
            const SizedBox(height: 15),

            // Horizontal list of Featured Brands
            _buildFeaturedBrandsList(),
            const SizedBox(height: 30),

            // Most Popular Section Header
            _buildSectionHeader('Most Popular', () {
              print(
                'See All Most Popular tapped',
              ); // No "See All" in image for this
            }),
            const SizedBox(height: 15),

            // Most Popular Brand List Item
            _buildMostPopularBrandItem(),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // Custom AppBar for the Brand Screen
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
          Navigator.pop(context); // Pop the current screen off the stack
        },
      ),
      title: const Text(
        'Brands',
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
          ), // Notification icon
          onPressed: () {
            print('Notifications Tapped from Brand Screen');
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

  // Builds a standard section header with a "See All" link
  Widget _buildSectionHeader(String title, VoidCallback? onSeeAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (onSeeAllTap != null) // Only show "See All" if onTap is provided
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                'See All',
                style: TextStyle(
                  color: primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builds the horizontal list of featured brands
  Widget _buildFeaturedBrandsList() {
    return SizedBox(
      height: 100, // Height for brand circle and name
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredBrands.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Padding for the list itself
        itemBuilder: (context, index) {
          final brand = _featuredBrands[index];
          return GestureDetector(
            onTap: () {
              print('Tapped on featured brand: ${brand['name']}');
              // Navigate to brand details or products
            },
            child: Container(
              width: 80, // Fixed width for each brand item
              margin: const EdgeInsets.only(
                right: 15,
              ), // Spacing between brands
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Colors.grey[100], // Background for brand logo
                    backgroundImage: NetworkImage(
                      brand['imageUrl']!,
                    ), // Brand logo
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brand['name']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the Most Popular Brand list item
  Widget _buildMostPopularBrandItem() {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[100],
            backgroundImage: NetworkImage(_mostPopularBrand['imageUrl']!),
          ),
          title: Text(
            _mostPopularBrand['name']!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[600],
            size: 20,
          ),
          onTap: () {
            print('Tapped on Most Popular brand: ${_mostPopularBrand['name']}');
            // Navigate to products or details for Fenty Beauty
          },
        ),
        const Divider(
          height: 1,
          indent: 70,
          endIndent: 16,
        ), // Divider below the item
      ],
    );
  }
}
