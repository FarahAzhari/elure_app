import 'dart:convert'; // Import for jsonEncode

import 'package:elure_app/models/api_models.dart'; // Import API models
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';

class ManageBrandsScreen extends StatefulWidget {
  const ManageBrandsScreen({super.key});

  @override
  State<ManageBrandsScreen> createState() => _ManageBrandsScreenState();
}

class _ManageBrandsScreenState extends State<ManageBrandsScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _addBrandFormKey = GlobalKey<FormState>();
  final TextEditingController _brandNameController = TextEditingController();

  List<Brand> _brands = [];
  bool _isLoadingBrands = true;
  String? _brandsErrorMessage;

  // For editing
  Brand? _editingBrand;
  final TextEditingController _editBrandNameController =
      TextEditingController();
  final GlobalKey<FormState> _editBrandFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchBrands(); // Fetch brands when the screen initializes
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _editBrandNameController.dispose();
    super.dispose();
  }

  // Function to fetch brands from the API
  Future<void> _fetchBrands() async {
    setState(() {
      _isLoadingBrands = true;
      _brandsErrorMessage = null;
    });

    try {
      final BrandListResponse response = await _apiService.getBrands();
      setState(() {
        _brands = response.data ?? [];
        _isLoadingBrands = false;
      });
      print('Admin: Brands fetched successfully: ${_brands.length} items');
    } on ErrorResponse catch (e) {
      setState(() {
        _brandsErrorMessage = e.message;
        _isLoadingBrands = false;
      });
      print('Admin: Error fetching brands: ${e.message}');
    } catch (e) {
      setState(() {
        _brandsErrorMessage = 'Admin: Failed to load brands: ${e.toString()}';
        _isLoadingBrands = false;
      });
      print('Admin: Unexpected error fetching brands: $e');
    }
  }

  // Function to handle adding a new brand
  Future<void> _handleAddBrand() async {
    if (_addBrandFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adding brand...')));

      try {
        final BrandAddResponse response = await _apiService.addBrand(
          _brandNameController.text,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));

        _brandNameController.clear();
        _fetchBrands(); // Refresh the list after adding a brand
      } on ErrorResponse catch (e) {
        String errorMessage = e.message;
        if (e.errors != null) {
          errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add brand: $errorMessage')),
        );
        print('Admin: Add Brand Error: $errorMessage');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Admin: An unexpected error occurred: ${e.toString()}',
            ),
          ),
        );
        print('Admin: Unexpected Add Brand Error: $e');
      }
    }
  }

  // Function to handle updating an existing brand
  Future<void> _handleUpdateBrand() async {
    if (_editBrandFormKey.currentState!.validate() && _editingBrand != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Updating brand...')));

      try {
        final BrandUpdateResponse response = await _apiService.updateBrand(
          _editingBrand!.id!,
          _editBrandNameController.text,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));

        // Clear editing state and refresh list
        setState(() {
          _editingBrand = null;
          _editBrandNameController.clear();
        });
        _fetchBrands();
        Navigator.pop(context); // Close the edit dialog/sheet
      } on ErrorResponse catch (e) {
        String errorMessage = e.message;
        if (e.errors != null) {
          errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update brand: $errorMessage')),
        );
        print('Admin: Update Brand Error: $errorMessage');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Admin: An unexpected error occurred: ${e.toString()}',
            ),
          ),
        );
        print('Admin: Unexpected Update Brand Error: $e');
      }
    }
  }

  // Function to confirm and delete a brand
  Future<void> _confirmAndDeleteBrand(int brandId, String brandName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete brand "$brandName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await _apiService.deleteBrand(brandId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        _fetchBrands(); // Refresh the list after deletion
      } on ErrorResponse catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete brand: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // Show edit dialog
  void _showEditBrandDialog(Brand brand) {
    setState(() {
      _editingBrand = brand;
      _editBrandNameController.text = brand.name ?? '';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to be full height
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Form(
            key: _editBrandFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Brand: ${brand.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _editBrandNameController,
                  labelText: 'Brand Name',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter brand name'
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleUpdateBrand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Update Brand',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
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
          'Manage Brands',
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
            // Add New Brand Form
            _buildSectionTitle('Add New Brand'),
            const SizedBox(height: 10),
            _buildAddBrandForm(),
            const SizedBox(height: 30),

            // Brand List
            _buildSectionTitle('Existing Brands'),
            const SizedBox(height: 10),
            _buildBrandList(),
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

  // Form to add a new brand
  Widget _buildAddBrandForm() {
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
        key: _addBrandFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _brandNameController,
              labelText: 'Brand Name',
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter brand name'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleAddBrand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add Brand',
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
      decoration: _inputDecoration(labelText),
      validator: validator,
    );
  }

  // Helper for consistent InputDecoration
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }

  // Displays the list of existing brands
  Widget _buildBrandList() {
    if (_isLoadingBrands) {
      return const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (_brandsErrorMessage != null) {
      return Center(
        child: Text(
          _brandsErrorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_brands.isEmpty) {
      return const Center(
        child: Text(
          'No brands added yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _brands.length,
        itemBuilder: (context, index) {
          final brand = _brands[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      brand.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditBrandDialog(brand),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (brand.id != null) {
                            _confirmAndDeleteBrand(
                              brand.id!,
                              brand.name ?? 'this brand',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
