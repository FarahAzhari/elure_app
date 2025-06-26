import 'package:elure_app/screens/category/category_detail_screen.dart';
import 'package:flutter/material.dart';
// Import the new detail screen

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Sample data for categories. In a real application, this would come from an API.
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Healing & Repair Creams',
      'productCount': 1020,
      'imageUrl':
          'https://placehold.co/100x100/ADD8E6/FFFFFF?text=HR', // Placeholder light blue
      'subCategories': [], // No subcategories for this one in the image
    },
    {
      'name': 'Clear Skin Essentials',
      'productCount': 1350,
      'imageUrl':
          'https://placehold.co/100x100/90EE90/FFFFFF?text=CS', // Placeholder light green
      'subCategories': [
        'Facial Cleansers',
        'Exfoliating Scrubs',
        'Hydrating Moisturizers',
        'Acne Spot Treatments',
        'Clay & Sheet Masks',
        'Skin Toners & Mists',
      ],
    },
    {
      'name': 'Clear Skin Essentials', // This appears again in the image
      'productCount': 750,
      'imageUrl':
          'https://placehold.co/100x100/FFB6C1/FFFFFF?text=CS', // Placeholder light pink
      'subCategories': [],
    },
    {
      'name': 'Baby Bath & Hygiene',
      'productCount': 1500,
      'imageUrl':
          'https://placehold.co/100x100/FFE4B5/000000?text=BB', // Placeholder peach
      'subCategories': [],
    },
    // You can add more categories here as per your design
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context), // Custom AppBar for category screen
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: _buildSearchBar(), // Search bar for categories
            ),
            // Build the list of categories with expandable sections
            ListView.builder(
              shrinkWrap: true, // Take only as much space as needed
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling within this list
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                if (category['subCategories'].isEmpty) {
                  // Render a simple list tile if no subcategories
                  return _buildCategoryListItem(
                    name: category['name'],
                    productCount: category['productCount'],
                    imageUrl: category['imageUrl'],
                  );
                } else {
                  // Render an expandable tile if subcategories exist
                  return _buildExpandableCategoryListItem(
                    name: category['name'],
                    productCount: category['productCount'],
                    imageUrl: category['imageUrl'],
                    subCategories: category['subCategories'],
                  );
                }
              },
            ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // Custom AppBar for the Category Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Choose a Category',
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
            print('Notifications Tapped from Category Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // Builds the Search Bar (reused from home_screen for consistency)
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

  // Builds a non-expandable category list item
  Widget _buildCategoryListItem({
    required String name,
    required int productCount,
    required String imageUrl,
  }) {
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
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            '$productCount Product available',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          onTap: () {
            print('Tapped on $name');
            // Navigate to products list for this category
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(categoryName: name),
              ),
            );
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

  // Builds an expandable category list item with subcategories
  Widget _buildExpandableCategoryListItem({
    required String name,
    required int productCount,
    required String imageUrl,
    required List<String> subCategories,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 1,
          ), // Bottom border for the main tile
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[100],
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          '$productCount Product available',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ), // Default trailing icon
        // Custom trailing icon builder to change icon on expansion
        // This is commented out for now to match the image's static arrow down/up
        // onExpansionChanged: (isExpanded) {
        //   // You can update state here if you need to change the icon dynamically
        // },
        children: subCategories.map((subCategory) {
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(
                  left: 70.0,
                  right: 16.0,
                  top: 5,
                  bottom: 5,
                ), // Indent subcategories
                title: Text(
                  subCategory,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                onTap: () {
                  print('Tapped on sub-category: $subCategory');
                  // Navigate to products list for this sub-category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryDetailScreen(categoryName: subCategory),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
              ), // Divider for sub-items
            ],
          );
        }).toList(),
      ),
    );
  }
}
