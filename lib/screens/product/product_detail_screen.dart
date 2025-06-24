import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  static const Color primaryPink = Color(0xFFE91E63);

  // State for image carousel dot indicator
  late PageController _pageController;
  int _currentPage = 0;

  // State for selected size
  String? _selectedSize;

  // State for quantity
  int _quantity = 1;

  // Tab controller for Description, Brands, Reviews
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    // Set initial selected size if available
    _selectedSize = '50ml'; // Default selected size based on image

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dummy list of product image URLs for the carousel and thumbnails
    final List<String> productImages = [
      widget.product['imageUrl']!,
      'https://placehold.co/150x150/FFC0CB/000000?text=Alt1',
      'https://placehold.co/150x150/FFC0CB/000000?text=Alt2',
      'https://placehold.co/150x150/FFC0CB/000000?text=Alt3',
      'https://placehold.co/150x150/FFC0CB/000000?text=Alt4',
    ];

    final List<String> sizes = ['5ml', '15ml', '50ml', '75ml', '90ml'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Product Image Carousel
            _buildImageCarousel(productImages),
            const SizedBox(height: 20),

            // Product Thumbnails
            _buildImageThumbnails(productImages),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['brand']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '4.5', // Static rating from image
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.product['name']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description, Brands, Reviews Tabs
                  _buildTabs(),
                  const SizedBox(height: 10),

                  // TabBarView for content
                  SizedBox(
                    height:
                        100, // Fixed height for tab content, adjust as needed
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDescriptionContent(),
                        const Center(
                          child: Text('Brands Content'),
                        ), // Placeholder
                        const Center(
                          child: Text('Reviews Content'),
                        ), // Placeholder
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Size selection
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSizeOptions(sizes),
                  const SizedBox(height: 20),

                  // Price and Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product['originalPrice']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            widget.product['currentPrice']!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.black, // Changed to black as per image
                            ),
                          ),
                        ],
                      ),
                      _buildQuantitySelector(),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(), // Bottom action buttons
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
        'Product Details',
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
            print('Notifications Tapped from Product Detail Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return SizedBox(
      height: 250, // Height of the image carousel
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            child: Row(
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 10.0 : 6.0,
                  height: _currentPage == index ? 10.0 : 6.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? primaryPink
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnails(List<String> images) {
    return SizedBox(
      height: 70, // Height for the thumbnail row
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            },
            child: Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _currentPage == index
                      ? primaryPink
                      : Colors.transparent,
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryPink,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: primaryPink,
        indicatorWeight: 3.0,
        tabs: const [
          Tab(text: 'Description'),
          Tab(text: 'Brands'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildDescriptionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Give your skin the care it deserves with AXIS-Y Dark Spot\nCorrection Glow Cream. Specially formulated to target\ndark spots and hyperpigmentation... ',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () {
            print('Read more tapped');
            // Implement logic to show full description
          },
          child: const Text(
            'Read more',
            style: TextStyle(
              color: primaryPink,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeOptions(List<String> sizes) {
    return Wrap(
      spacing: 10.0, // Space between buttons horizontally
      runSpacing: 10.0, // Space between rows vertically
      children: sizes.map((size) {
        final bool isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSize = size;
            });
            print('Selected size: $size');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryPink : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primaryPink : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black),
            onPressed: () {
              setState(() {
                if (_quantity > 1) _quantity--;
              });
            },
          ),
          Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              setState(() {
                _quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
      child: Row(
        children: <Widget>[
          // Total price display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: primaryPink,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '\$${(double.parse(widget.product['currentPrice']!.replaceAll('\$', '')) * _quantity).toStringAsFixed(2)} USD',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Cart Icon Button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                print('Add to Cart clicked');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey), // Grey border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Buy Now Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                print('Buy Now clicked');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
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
