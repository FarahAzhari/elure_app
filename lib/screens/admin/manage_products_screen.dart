import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Import for jsonEncode

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _addProductFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _productsErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the screen initializes
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Function to fetch products from the API
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsErrorMessage = null;
    });

    try {
      final ProductListResponse response = await _apiService.getProducts();
      setState(() {
        _products = response.data ?? [];
        _isLoadingProducts = false;
      });
      print('Admin: Products fetched successfully: ${_products.length} items');
    } on ErrorResponse catch (e) {
      setState(() {
        _productsErrorMessage = e.message;
        _isLoadingProducts = false;
      });
      print('Admin: Error fetching products: ${e.message}');
    } catch (e) {
      setState(() {
        _productsErrorMessage =
            'Admin: Failed to load products: ${e.toString()}';
        _isLoadingProducts = false;
      });
      print('Admin: Unexpected error fetching products: $e');
    }
  }

  // Function to handle adding a new product
  Future<void> _handleAddProduct() async {
    if (_addProductFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adding product...')));

      try {
        final ProductAddResponse response = await _apiService.addProduct(
          _nameController.text,
          _descriptionController.text,
          int.parse(_priceController.text), // Parse price to int
          int.parse(_stockController.text), // Parse stock to int
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));

        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _stockController.clear();

        _fetchProducts(); // Refresh the list after adding a product
      } on ErrorResponse catch (e) {
        String errorMessage = e.message;
        if (e.errors != null) {
          // Convert the ErrorDetail object to a JSON string for better display
          errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $errorMessage')),
        );
        print('Admin: Add Product Error: $errorMessage');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Admin: An unexpected error occurred: ${e.toString()}',
            ),
          ),
        );
        print('Admin: Unexpected Add Product Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the Admin Dashboard
          },
        ),
        title: const Text(
          'Manage Products',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Add New Product Form
            _buildSectionTitle('Add New Product'),
            const SizedBox(height: 10),
            _buildAddProductForm(),
            const SizedBox(height: 30),

            // Product List
            _buildSectionTitle('Existing Products'),
            const SizedBox(height: 10),
            _buildProductList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
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

  // Form to add a new product
  Widget _buildAddProductForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _addProductFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              labelText: 'Product Name',
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter product name'
                  : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _descriptionController,
              labelText: 'Description',
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter description'
                  : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _priceController,
              labelText: 'Price',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter price';
                if (int.tryParse(value) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _stockController,
              labelText: 'Stock',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter stock quantity';
                if (int.tryParse(value) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleAddProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for consistent text input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
      ),
      validator: validator,
    );
  }

  // Displays the list of existing products
  Widget _buildProductList() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (_productsErrorMessage != null) {
      return Center(
        child: Text(
          _productsErrorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_products.isEmpty) {
      return const Center(
        child: Text(
          'No products added yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.description ?? 'No description',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: \$${product.price?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryPink,
                        ),
                      ),
                      Text(
                        'Stock: ${product.stock ?? '0'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  // You can add Edit/Delete buttons here if desired
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
