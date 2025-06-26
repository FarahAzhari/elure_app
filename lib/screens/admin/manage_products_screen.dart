import 'dart:convert'; // Import for jsonEncode and base64Encode
import 'dart:io'; // Import for File
import 'dart:typed_data'; // New import for Uint8List

import 'package:elure_app/models/api_models.dart'; // Import API models
import 'package:elure_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // New import for image picking

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _addProductFormKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  // Text editing controllers for product fields (Add Product Form)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  // Text editing controllers for product fields (Edit Product Form)
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDescriptionController =
      TextEditingController();
  final TextEditingController _editPriceController = TextEditingController();
  final TextEditingController _editStockController = TextEditingController();
  final TextEditingController _editDiscountController = TextEditingController();

  // State for lists of products, categories, and brands
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Brand> _brands = [];

  // Maps for quick lookup of category and brand names by ID
  Map<int, Category> _categoriesMap = {};
  Map<int, Brand> _brandsMap = {};

  // State for selected category and brand in the add product form
  Category? _selectedCategory;
  Brand? _selectedBrand;

  // For editing a product
  Product? _editingProduct; // The product currently being edited
  Category? _editSelectedCategory; // Selected category in edit form
  Brand? _editSelectedBrand; // Selected brand in edit form
  final GlobalKey<FormState> _editProductFormKey = GlobalKey<FormState>();

  // Lists to hold Base64 image strings for API submission (for NEW images)
  final List<String> _addImagesBase64 = [];
  final List<String> _newEditImagesBase64 = []; // New images picked during edit

  // Lists to hold Uint8List image bytes for local preview (for NEW images)
  final List<Uint8List> _pickedAddImageBytes = [];
  final List<Uint8List> _newPickedEditImageBytes =
      []; // Bytes for preview of new edit images

  // List to hold existing image URLs from the API for the product being edited
  final List<String> _existingEditProductUrls = [];

  // Loading and error states
  bool _isLoadingProducts = true;
  String? _productsErrorMessage;
  bool _isLoadingCategories = true;
  String? _categoriesErrorMessage;
  bool _isLoadingBrands = true;
  String? _brandsErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndBrands().then((_) {
      _fetchProducts(); // Only fetch products after categories and brands are loaded
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _discountController.dispose();

    _editNameController.dispose();
    _editDescriptionController.dispose();
    _editPriceController.dispose();
    _editStockController.dispose();
    _editDiscountController.dispose();
    super.dispose();
  }

  // Function to pick multiple images and convert them to Base64
  Future<void> _pickImages({bool isEdit = false}) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (mounted) {
        setState(() {
          for (XFile image in images) {
            final File imageFile = File(image.path);
            final List<int> imageBytes = imageFile
                .readAsBytesSync(); // Read synchronously for simplicity
            final String base64Image = base64Encode(imageBytes);

            if (isEdit) {
              _newEditImagesBase64.add(base64Image);
              _newPickedEditImageBytes.add(Uint8List.fromList(imageBytes));
            } else {
              _addImagesBase64.add(base64Image);
              _pickedAddImageBytes.add(Uint8List.fromList(imageBytes));
            }
          }
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${images.length} images selected and converted to Base64.',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No images selected.')));
      }
    }
  }

  // Function to clear a specific image (Base64 string and preview)
  void _removeImage(int index, {bool isEdit = false, bool isExisting = false}) {
    setState(() {
      if (isEdit) {
        if (isExisting) {
          // Remove from existing URLs
          if (index >= 0 && index < _existingEditProductUrls.length) {
            _existingEditProductUrls.removeAt(index);
          }
        } else {
          // Remove from newly picked Base64 images
          if (index >= 0 && index < _newEditImagesBase64.length) {
            _newEditImagesBase64.removeAt(index);
            _newPickedEditImageBytes.removeAt(index);
          }
        }
      } else {
        // For add form
        if (index >= 0 && index < _addImagesBase64.length) {
          _addImagesBase64.removeAt(index);
          _pickedAddImageBytes.removeAt(index);
        }
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image removed.')));
  }

  // Function to fetch categories and brands
  Future<void> _fetchCategoriesAndBrands() async {
    setState(() {
      _isLoadingCategories = true;
      _isLoadingBrands = true;
      _categoriesErrorMessage = null;
      _brandsErrorMessage = null;
    });

    try {
      final categoryResponse = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categoryResponse.data ?? [];
          _categoriesMap = {for (var c in _categories) c.id!: c};
          _isLoadingCategories = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _categoriesErrorMessage = e.message;
          _isLoadingCategories = false;
        });
        print('Admin: Error fetching categories: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesErrorMessage =
              'Admin: Failed to load categories: ${e.toString()}';
          _isLoadingCategories = false;
        });
        print('Admin: Unexpected error fetching categories: $e');
      }
    }

    try {
      final brandResponse = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _brands = brandResponse.data ?? [];
          _brandsMap = {for (var b in _brands) b.id!: b};
          _isLoadingBrands = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _brandsErrorMessage = e.message;
          _isLoadingBrands = false;
        });
        print('Admin: Error fetching brands: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _brandsErrorMessage = 'Admin: Failed to load brands: ${e.toString()}';
          _isLoadingBrands = false;
        });
        print('Admin: Unexpected error fetching brands: $e');
      }
    }
  }

  // Function to fetch products from the API
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsErrorMessage = null;
    });

    try {
      final ProductListResponse response = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _products = response.data ?? [];
          _isLoadingProducts = false;
        });
        print(
          'Admin: Products fetched successfully: ${_products.length} items',
        );
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _productsErrorMessage = e.message;
          _isLoadingProducts = false;
        });
        print('Admin: Error fetching products: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productsErrorMessage =
              'Admin: Failed to load products: ${e.toString()}';
          _isLoadingProducts = false;
        });
        print('Admin: Unexpected error fetching products: $e');
      }
    }
  }

  // Function to handle adding a new product
  Future<void> _handleAddProduct() async {
    if (_addProductFormKey.currentState!.validate()) {
      if (_addImagesBase64.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one image.')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Adding product...')));
      }

      try {
        final ProductAddResponse response = await _apiService.addProduct(
          _nameController.text,
          _descriptionController.text,
          int.parse(_priceController.text),
          int.parse(_stockController.text),
          categoryId: _selectedCategory?.id,
          brandId: _selectedBrand?.id,
          discount: double.tryParse(_discountController.text),
          images: _addImagesBase64, // Pass the list of Base64 images
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));

          _nameController.clear();
          _descriptionController.clear();
          _priceController.clear();
          _stockController.clear();
          _discountController.clear();
          setState(() {
            _selectedCategory = null;
            _selectedBrand = null;
            _addImagesBase64.clear(); // Clear Base64 list
            _pickedAddImageBytes.clear(); // Clear preview list
          });

          _fetchProducts();
        }
      } on ErrorResponse catch (e) {
        if (mounted) {
          String errorMessage = e.message;
          if (e.errors != null) {
            errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add product: $errorMessage')),
          );
          print('Admin: Add Product Error: $errorMessage');
        }
      } catch (e) {
        if (mounted) {
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
  }

  // Function to handle updating an existing product
  Future<void> _handleUpdateProduct() async {
    if (_editProductFormKey.currentState!.validate() &&
        _editingProduct?.id != null) {
      if (_existingEditProductUrls.isEmpty && _newEditImagesBase64.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one image.')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updating product...')));
      }

      // Combine existing URLs and new Base64 images
      final List<String> allImagesToSend = [
        ..._existingEditProductUrls,
        ..._newEditImagesBase64,
      ];

      try {
        final ProductUpdateResponse response = await _apiService.editProduct(
          _editingProduct!.id!,
          _editNameController.text,
          _editDescriptionController.text,
          int.parse(_editPriceController.text),
          int.parse(_editStockController.text),
          categoryId: _editSelectedCategory?.id,
          brandId: _editSelectedBrand?.id,
          discount: double.tryParse(_editDiscountController.text),
          images: allImagesToSend, // Pass the combined list of images
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));

          // Clear editing state and refresh list
          setState(() {
            _editingProduct = null;
            _editNameController.clear();
            _editDescriptionController.clear();
            _editPriceController.clear();
            _editStockController.clear();
            _editDiscountController.clear();
            _newEditImagesBase64.clear(); // Clear new Base64 list
            _newPickedEditImageBytes.clear(); // Clear new preview list
            _existingEditProductUrls.clear(); // Clear existing URLs
            _editSelectedCategory = null;
            _editSelectedBrand = null;
          });
          _fetchProducts();
          Navigator.pop(context); // Close the edit dialog/sheet
        }
      } on ErrorResponse catch (e) {
        if (mounted) {
          String errorMessage = e.message;
          if (e.errors != null) {
            errorMessage += '\nDetails: ${jsonEncode(e.errors!.toJson())}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update product: $errorMessage')),
          );
          print('Admin: Update Product Error: $errorMessage');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Admin: An unexpected error occurred: ${e.toString()}',
              ),
            ),
          );
          print('Admin: Unexpected Update Product Error: $e');
        }
      }
    }
  }

  Future<void> _confirmAndDeleteProduct(
    int productId,
    String productName,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "$productName"?'),
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
        final response = await _apiService.deleteProduct(productId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
          _fetchProducts(); // Refresh the list after deletion
        }
      } on ErrorResponse catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete product: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  // Show edit product dialog (as a modal bottom sheet)
  void _showEditProductDialog(Product product) {
    // Ensure state updates are batched for opening the modal
    setState(() {
      _editingProduct = product;
      _editNameController.text = product.name ?? '';
      _editDescriptionController.text = product.description ?? '';
      _editPriceController.text = product.price?.toString() ?? '';
      _editStockController.text = product.stock?.toString() ?? '';
      _editDiscountController.text = product.discount?.toString() ?? '';

      // Clear previous images for edit form
      _existingEditProductUrls.clear(); // Clear existing URLs
      _newEditImagesBase64.clear(); // Clear newly picked Base64s
      _newPickedEditImageBytes.clear(); // Clear bytes for new Base64 previews

      print('Opening edit dialog for product: ${product.name}');
      print(
        'Product images from API: ${product.images}',
      ); // Debug: Check raw images from API

      // Populate existing images from product.images (which are URLs)
      if (product.images != null && product.images!.isNotEmpty) {
        for (String imageString in product.images!) {
          // Add only if it's a valid string and not an empty string
          if (imageString.isNotEmpty) {
            String imageUrlToDisplay = imageString;
            // If it's not already a full URL (check for http:// or https://), prepend the base URL
            if (!imageString.startsWith('http://') &&
                !imageString.startsWith('https://')) {
              imageUrlToDisplay = '$_baseUrl$imageString';
            }
            _existingEditProductUrls.add(imageUrlToDisplay);
            print(
              'Processed image URL for display: $imageUrlToDisplay',
            ); // Debug
          }
        }
      }
      print(
        'After loading existing images in edit dialog, _existingEditProductUrls count: ${_existingEditProductUrls.length}',
      ); // Debug print

      _editSelectedCategory = _categoriesMap[product.categoryId];
      _editSelectedBrand = _brandsMap[product.brandId];
    });

    // Show the modal bottom sheet after the state has been fully updated
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
          child: SingleChildScrollView(
            // Allow scrolling within the modal
            child: Form(
              key: _editProductFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Product: ${product.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _editNameController,
                    labelText: 'Product Name',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter product name'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _editDescriptionController,
                    labelText: 'Description',
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter description'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _editPriceController,
                    labelText: 'Price',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter price';
                      if (int.tryParse(value) == null)
                        return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _editStockController,
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
                  const SizedBox(height: 15),
                  // Category Dropdown for Edit Form
                  _isLoadingCategories
                      ? const Center(
                          child: CircularProgressIndicator(color: primaryPink),
                        )
                      : _categoriesErrorMessage != null
                      ? Text(
                          _categoriesErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : DropdownButtonFormField<Category>(
                          decoration: _inputDecoration('Category'),
                          value: _editSelectedCategory,
                          hint: const Text('Select Category'),
                          onChanged: (Category? newValue) {
                            setState(() {
                              _editSelectedCategory = newValue;
                            });
                          },
                          items: _categories.map<DropdownMenuItem<Category>>((
                            Category category,
                          ) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name ?? 'Unknown Category'),
                            );
                          }).toList(),
                          validator: (value) =>
                              value == null ? 'Please select a category' : null,
                        ),
                  const SizedBox(height: 15),
                  // Brand Dropdown for Edit Form
                  _isLoadingBrands
                      ? const Center(
                          child: CircularProgressIndicator(color: primaryPink),
                        )
                      : _brandsErrorMessage != null
                      ? Text(
                          _brandsErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : DropdownButtonFormField<Brand>(
                          decoration: _inputDecoration('Brand'),
                          value: _editSelectedBrand,
                          hint: const Text('Select Brand'),
                          onChanged: (Brand? newValue) {
                            setState(() {
                              _editSelectedBrand = newValue;
                            });
                          },
                          items: _brands.map<DropdownMenuItem<Brand>>((
                            Brand brand,
                          ) {
                            return DropdownMenuItem<Brand>(
                              value: brand,
                              child: Text(brand.name ?? 'Unknown Brand'),
                            );
                          }).toList(),
                          validator: (value) =>
                              value == null ? 'Please select a brand' : null,
                        ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _editDiscountController,
                    labelText: 'Discount (e.g., 0.10 for 10%)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Please enter a valid number for discount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Image picker and preview for edit form
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Images:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _pickImages(isEdit: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Pick Images'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Use StatefulBuilder here to ensure this section of the modal rebuilds
                  // when _existingEditProductUrls or _newPickedEditImageBytes change
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter modalSetState) {
                      return Wrap(
                        spacing: 8.0, // horizontal space between images
                        runSpacing:
                            8.0, // vertical space between lines of images
                        children: [
                          // Display existing images from URL
                          for (
                            int i = 0;
                            i < _existingEditProductUrls.length;
                            i++
                          )
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      _existingEditProductUrls[i],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print(
                                          'Error loading existing image URL: ${_existingEditProductUrls[i]}, Error: $error',
                                        );
                                        return Container(
                                          height: 100,
                                          width: 100,
                                          color: Colors.grey[200],
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                'Load Error',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      // Use modalSetState to update the state within the modal
                                      modalSetState(() {
                                        _removeImage(
                                          i,
                                          isEdit: true,
                                          isExisting: true,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          // Display newly picked images (Base64)
                          for (
                            int i = 0;
                            i < _newPickedEditImageBytes.length;
                            i++
                          )
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      _newPickedEditImageBytes[i],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      // Use modalSetState to update the state within the modal
                                      modalSetState(() {
                                        _removeImage(
                                          i,
                                          isEdit: true,
                                          isExisting: false,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleUpdateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Update Product',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
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
            const SizedBox(height: 15),
            // Category Dropdown
            _isLoadingCategories
                ? const Center(
                    child: CircularProgressIndicator(color: primaryPink),
                  )
                : _categoriesErrorMessage != null
                ? Text(
                    _categoriesErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                : DropdownButtonFormField<Category>(
                    decoration: _inputDecoration('Category'),
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: _categories.map<DropdownMenuItem<Category>>((
                      Category category,
                    ) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name ?? 'Unknown Category'),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
            const SizedBox(height: 15),
            // Brand Dropdown
            _isLoadingBrands
                ? const Center(
                    child: CircularProgressIndicator(color: primaryPink),
                  )
                : _brandsErrorMessage != null
                ? Text(
                    _brandsErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                : DropdownButtonFormField<Brand>(
                    decoration: _inputDecoration('Brand'),
                    value: _selectedBrand,
                    hint: const Text('Select Brand'),
                    onChanged: (Brand? newValue) {
                      setState(() {
                        _selectedBrand = newValue;
                      });
                    },
                    items: _brands.map<DropdownMenuItem<Brand>>((Brand brand) {
                      return DropdownMenuItem<Brand>(
                        value: brand,
                        child: Text(brand.name ?? 'Unknown Brand'),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Please select a brand' : null,
                  ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _discountController,
              labelText: 'Discount (e.g., 0.10 for 10%)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return 'Please enter a valid number for discount';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            // Image picker and preview for add form
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Images:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickImages(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Pick Images'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0, // horizontal space between images
              runSpacing: 8.0, // vertical space between lines of images
              children: [
                for (int i = 0; i < _pickedAddImageBytes.length; i++)
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _pickedAddImageBytes[i],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 24,
                          ),
                          onPressed: () => _removeImage(i),
                        ),
                      ),
                    ],
                  ),
              ],
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

  // Displays the list of existing products
  Widget _buildProductList() {
    if (_isLoadingProducts || _isLoadingCategories || _isLoadingBrands) {
      return const Center(child: CircularProgressIndicator(color: primaryPink));
    } else if (_productsErrorMessage != null ||
        _categoriesErrorMessage != null ||
        _brandsErrorMessage != null) {
      String errorMessage = '';
      if (_productsErrorMessage != null)
        errorMessage += 'Products: $_productsErrorMessage\n';
      if (_categoriesErrorMessage != null)
        errorMessage += 'Categories: $_categoriesErrorMessage\n';
      if (_brandsErrorMessage != null)
        errorMessage += 'Brands: $_brandsErrorMessage\n';
      return Center(
        child: Text(
          errorMessage.trim(),
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
          final categoryName =
              _categoriesMap[product.categoryId]?.name ?? 'N/A';
          final brandName = _brandsMap[product.brandId]?.name ?? 'N/A';

          // Determine the image URL for display
          Widget productImageWidget;
          if (product.images != null && product.images!.isNotEmpty) {
            String imageUrlToDisplay = product.images!.first;
            // Prepend base URL if it's a relative path
            if (!imageUrlToDisplay.startsWith('http://') &&
                !imageUrlToDisplay.startsWith('https://')) {
              imageUrlToDisplay = '$_baseUrl$imageUrlToDisplay';
            }
            productImageWidget = Image.network(
              imageUrlToDisplay,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            );
          } else {
            productImageWidget = Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            );
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: productImageWidget,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
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
                          'Category: $categoryName',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Brand: $brandName',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.description ?? 'No description',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                            if (product.discount != null &&
                                product.discount! > 0)
                              Text(
                                'Disc: ${(product.discount! * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green, // Highlight discount
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Action buttons for Edit and Delete
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                print('Edit ${product.name} tapped');
                                _showEditProductDialog(
                                  product,
                                ); // Call the edit dialog
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                print('Delete ${product.name} tapped');
                                if (product.id != null) {
                                  _confirmAndDeleteProduct(
                                    product.id!,
                                    product.name ?? 'this product',
                                  );
                                }
                              },
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
