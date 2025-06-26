import 'dart:convert'; // Import for jsonEncode

import 'package:elure_app/models/api_models.dart'; // Import API models
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  static const Color primaryPink = Color(0xFFE91E63);

  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _addCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();

  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoriesErrorMessage;

  // For editing
  Category? _editingCategory;
  final TextEditingController _editCategoryNameController =
      TextEditingController();
  final GlobalKey<FormState> _editCategoryFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the screen initializes
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _editCategoryNameController.dispose();
    super.dispose();
  }

  // Function to fetch categories from the API
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesErrorMessage = null;
    });

    try {
      final CategoryListResponse response = await _apiService.getCategories();
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _categories = response.data ?? [];
          _isLoadingCategories = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _categoriesErrorMessage = e.message;
          _isLoadingCategories = false;
        });
        print('Admin: Error fetching categories: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _categoriesErrorMessage =
              'Admin: Failed to load categories: ${e.toString()}';
          _isLoadingCategories = false;
        });
        print('Admin: Unexpected error fetching categories: $e');
      }
    }
  }

  // Function to handle adding a new category
  Future<void> _handleAddCategory() async {
    if (_addCategoryFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adding category...')));

      try {
        final CategoryAddResponse response = await _apiService.addCategory(
          _categoryNameController.text,
        );

        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));

          _categoryNameController.clear();
          _fetchCategories(); // Refresh the list after adding a category
        }
      } on ErrorResponse catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          String errorMessage = e.message;
          if (e.errors != null) {
            errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add category: $errorMessage')),
          );
          print('Admin: Add Category Error: $errorMessage');
        }
      } catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Admin: An unexpected error occurred: ${e.toString()}',
              ),
            ),
          );
          print('Admin: Unexpected Add Category Error: $e');
        }
      }
    }
  }

  // Function to handle updating an existing category
  Future<void> _handleUpdateCategory() async {
    if (_editCategoryFormKey.currentState!.validate() &&
        _editingCategory != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Updating category...')));

      try {
        final CategoryUpdateResponse response = await _apiService
            .updateCategory(
              _editingCategory!.id!,
              _editCategoryNameController.text,
            );

        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));

          // Clear editing state and refresh list
          setState(() {
            _editingCategory = null;
            _editCategoryNameController.clear();
          });
          _fetchCategories();
          Navigator.pop(context); // Close the edit dialog/sheet
        }
      } on ErrorResponse catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          String errorMessage = e.message;
          if (e.errors != null) {
            errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update category: $errorMessage')),
          );
          print('Admin: Update Category Error: $errorMessage');
        }
      } catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Admin: An unexpected error occurred: ${e.toString()}',
              ),
            ),
          );
          print('Admin: Unexpected Update Category Error: $e');
        }
      }
    }
  }

  // Function to confirm and delete a category
  Future<void> _confirmAndDeleteCategory(
    int categoryId,
    String categoryName,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete category "$categoryName"?',
          ),
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
        final response = await _apiService.deleteCategory(categoryId);
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
          _fetchCategories(); // Refresh the list after deletion
        }
      } on ErrorResponse catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete category: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  // Show edit dialog
  void _showEditCategoryDialog(Category category) {
    setState(() {
      _editingCategory = category;
      _editCategoryNameController.text = category.name ?? '';
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
            key: _editCategoryFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Category: ${category.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _editCategoryNameController,
                  labelText: 'Category Name',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter category name'
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleUpdateCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Update Category',
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
          'Manage Categories',
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
            // Add New Category Form
            _buildSectionTitle('Add New Category'),
            const SizedBox(height: 10),
            _buildAddCategoryForm(),
            const SizedBox(height: 30),

            // Category List
            _buildSectionTitle('Existing Categories'),
            const SizedBox(height: 10),
            _buildCategoryList(),
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

  // Form to add a new category
  Widget _buildAddCategoryForm() {
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
        key: _addCategoryFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _categoryNameController,
              labelText: 'Category Name',
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter category name'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleAddCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add Category',
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

  // Displays the list of existing categories
  Widget _buildCategoryList() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (_categoriesErrorMessage != null) {
      return Center(
        child: Text(
          _categoriesErrorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories added yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
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
                      category.name ?? 'N/A',
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
                        onPressed: () => _showEditCategoryDialog(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (category.id != null) {
                            _confirmAndDeleteCategory(
                              category.id!,
                              category.name ?? 'this category',
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
