// Helper to safely parse dynamic values to int?
int? _parseIntSafely(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    // Try to parse string to int, return null if parsing fails
    return int.tryParse(value);
  }
  return null; // Return null for unsupported types
}

// Helper to safely parse dynamic values to double?
double? _parseDoubleSafely(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

// --- Generic Response Wrapper ---
// A general structure for API responses that contain a message and optional data.
class ApiResponse<T> {
  final String message;
  final T? data;

  ApiResponse({required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

// --- Error Models ---
// Represents the detailed error messages often found in validation errors.
class ErrorDetail {
  final List<String>? email;
  final List<String>? password;
  final List<String>? name; // Added for Brand/Category name validation
  final List<String>? description; // Added for Product description
  final List<String>? price; // Added for Product price
  final List<String>? stock; // Added for Product stock
  final List<String>? categoryId; // Added for Product category_id
  final List<String>? brandId; // Added for Product brand_id
  final List<String>? discount; // Added for Product discount
  final List<String>? images; // Added for Product images

  ErrorDetail({
    this.email,
    this.password,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.categoryId,
    this.brandId,
    this.discount,
    this.images,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      email: json['email'] != null
          ? List<String>.from(json['email'].map((x) => x))
          : null,
      password: json['password'] != null
          ? List<String>.from(json['password'].map((x) => x))
          : null,
      name: json['name'] != null
          ? List<String>.from(json['name'].map((x) => x))
          : null,
      description: json['description'] != null
          ? List<String>.from(json['description'].map((x) => x))
          : null,
      price: json['price'] != null
          ? List<String>.from(json['price'].map((x) => x))
          : null,
      stock: json['stock'] != null
          ? List<String>.from(json['stock'].map((x) => x))
          : null,
      categoryId: json['category_id'] != null
          ? List<String>.from(json['category_id'].map((x) => x))
          : null,
      brandId: json['brand_id'] != null
          ? List<String>.from(json['brand_id'].map((x) => x))
          : null,
      discount: json['discount'] != null
          ? List<String>.from(json['discount'].map((x) => x))
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'].map((x) => x))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand_id': brandId,
      'discount': discount,
      'images': images,
    };
  }
}

// Represents an API error response, typically with a message and specific error details.
class ErrorResponse {
  final String message;
  final ErrorDetail? errors;

  ErrorResponse({required this.message, this.errors});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    // Ensure message is never null, providing a fallback string if missing from JSON
    return ErrorResponse(
      message: json['message']?.toString() ?? 'An unknown error occurred.',
      errors: json['errors'] != null
          ? ErrorDetail.fromJson(json['errors'])
          : null,
    );
  }
}

// --- User and Authentication Models ---
// Represents a user object.
class User {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt; // Nullable as per API response
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseIntSafely(json['id']), // Use safe parsing
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Represents the data part of an authentication response (login/register).
class AuthData {
  final String? token;
  final User? user;

  AuthData({this.token, this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user?.toJson()};
  }
}

// Full authentication response model.
class AuthResponse {
  final String message;
  final AuthData? data;

  AuthResponse({required this.message, this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

// --- Brand Models ---
class Brand {
  final int? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  Brand({this.id, this.name, this.createdAt, this.updatedAt});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: _parseIntSafely(json['id']),
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BrandListResponse {
  final String message;
  final List<Brand>? data;

  BrandListResponse({required this.message, this.data});

  factory BrandListResponse.fromJson(Map<String, dynamic> json) {
    return BrandListResponse(
      message: json['message'],
      data: json['data'] != null
          ? List<Brand>.from(json['data'].map((x) => Brand.fromJson(x)))
          : null,
    );
  }
}

class BrandAddResponse {
  final String message;
  final Brand? data;

  BrandAddResponse({required this.message, this.data});

  factory BrandAddResponse.fromJson(Map<String, dynamic> json) {
    return BrandAddResponse(
      message: json['message'],
      data: json['data'] != null ? Brand.fromJson(json['data']) : null,
    );
  }
}

class BrandUpdateResponse {
  final String message;
  final Brand? data;

  BrandUpdateResponse({required this.message, this.data});

  factory BrandUpdateResponse.fromJson(Map<String, dynamic> json) {
    return BrandUpdateResponse(
      message: json['message'],
      data: json['data'] != null ? Brand.fromJson(json['data']) : null,
    );
  }
}

// --- Category Models ---
class Category {
  final int? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  Category({this.id, this.name, this.createdAt, this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseIntSafely(json['id']),
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CategoryListResponse {
  final String message;
  final List<Category>? data;

  CategoryListResponse({required this.message, this.data});

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      message: json['message'],
      data: json['data'] != null
          ? List<Category>.from(json['data'].map((x) => Category.fromJson(x)))
          : null,
    );
  }
}

class CategoryAddResponse {
  final String message;
  final Category? data;

  CategoryAddResponse({required this.message, this.data});

  factory CategoryAddResponse.fromJson(Map<String, dynamic> json) {
    return CategoryAddResponse(
      message: json['message'],
      data: json['data'] != null ? Category.fromJson(json['data']) : null,
    );
  }
}

class CategoryUpdateResponse {
  final String message;
  final Category? data;

  CategoryUpdateResponse({required this.message, this.data});

  factory CategoryUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CategoryUpdateResponse(
      message: json['message'],
      data: json['data'] != null ? Category.fromJson(json['data']) : null,
    );
  }
}

// --- Product Models ---
// Represents a single product.
class Product {
  final int? id;
  final String? name;
  final String? description;
  final int? price;
  final int? stock;
  final int? categoryId; // New field
  final int? brandId; // New field
  final double? discount; // New field, assuming percentage
  final List<String>?
  images; // New field, list of image URLs (base64 or actual URLs)
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.categoryId,
    this.brandId,
    this.discount,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseIntSafely(json['id']), // Use safe parsing
      name: json['name'],
      description: json['description'],
      price: _parseIntSafely(json['price']), // Use safe parsing
      stock: _parseIntSafely(json['stock']), // Use safe parsing
      categoryId: _parseIntSafely(json['category_id']), // Parse new field
      brandId: _parseIntSafely(json['brand_id']), // Parse new field
      discount: _parseDoubleSafely(json['discount']), // Parse new field
      images: json['images'] != null
          ? List<String>.from(json['images'].map((x) => x.toString()))
          : null, // Parse new field
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand_id': brandId,
      'discount': discount,
      'images': images,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Response for a list of products.
class ProductListResponse {
  final String message;
  final List<Product>? data;

  ProductListResponse({required this.message, this.data});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      message: json['message'],
      data: json['data'] != null
          ? List<Product>.from(json['data'].map((x) => Product.fromJson(x)))
          : null,
    );
  }
}

// Response for adding a single product (Admin).
class ProductAddResponse {
  final String message;
  final Product? data; // The newly added product

  ProductAddResponse({required this.message, this.data});

  factory ProductAddResponse.fromJson(Map<String, dynamic> json) {
    return ProductAddResponse(
      message: json['message'],
      data: json['data'] != null ? Product.fromJson(json['data']) : null,
    );
  }
}

class ProductUpdateResponse {
  final String message;
  final Product? data;

  ProductUpdateResponse({required this.message, this.data});

  factory ProductUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProductUpdateResponse(
      message: json['message'],
      data: json['data'] != null ? Product.fromJson(json['data']) : null,
    );
  }
}

// --- Cart Models ---
// Represents a simplified product within a cart item (only ID, name, price needed).
class CartProduct {
  final int? id;
  final String? name;
  final int? price;
  final int? stock; // Added stock field

  CartProduct({this.id, this.name, this.price, this.stock});

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: _parseIntSafely(json['id']), // Use safe parsing
      name: json['name'],
      price: _parseIntSafely(json['price']), // Use safe parsing
      stock: _parseIntSafely(json['stock']), // Use safe parsing for stock
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'stock': stock};
  }
}

// Represents a single item in the shopping cart list.
class CartItem {
  final int? id;
  final CartProduct? product;
  final int? quantity;
  final int? subtotal;

  CartItem({this.id, this.product, this.quantity, this.subtotal});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _parseIntSafely(json['id']), // Use safe parsing
      product: json['product'] != null
          ? CartProduct.fromJson(json['product'])
          : null,
      quantity: _parseIntSafely(json['quantity']), // Use safe parsing
      subtotal: _parseIntSafely(json['subtotal']), // Use safe parsing
    );
  }
}

// Response for adding a product to the cart.
class CartAddResponse {
  final String message;
  final CartAddData? data;

  CartAddResponse({required this.message, this.data});

  factory CartAddResponse.fromJson(Map<String, dynamic> json) {
    return CartAddResponse(
      message: json['message'],
      data: json['data'] != null ? CartAddData.fromJson(json['data']) : null,
    );
  }
}

// Data specific to a cart addition confirmation.
class CartAddData {
  final int? id;
  final int? userId;
  final int? productId;
  final int? quantity;
  final String? createdAt;
  final String? updatedAt;

  CartAddData({
    this.id,
    this.userId,
    this.productId,
    this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  factory CartAddData.fromJson(Map<String, dynamic> json) {
    return CartAddData(
      id: _parseIntSafely(json['id']), // Use safe parsing
      userId: _parseIntSafely(json['user_id']), // Use safe parsing
      productId: _parseIntSafely(json['product_id']), // Use safe parsing
      quantity: _parseIntSafely(json['quantity']), // Use safe parsing
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// Response for retrieving the list of items in the cart.
class CartListResponse {
  final String message;
  final List<CartItem>? data;

  CartListResponse({required this.message, this.data});

  factory CartListResponse.fromJson(Map<String, dynamic> json) {
    return CartListResponse(
      message: json['message'],
      data: json['data'] != null
          ? List<CartItem>.from(json['data'].map((x) => CartItem.fromJson(x)))
          : null,
    );
  }
}

// --- Checkout Models ---
// Represents an item within the checkout response.
class CheckoutItem {
  final CartProduct? product; // Reusing CartProduct as it fits the structure
  final int? quantity;

  CheckoutItem({this.product, this.quantity});

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      product: json['product'] != null
          ? CartProduct.fromJson(json['product'])
          : null,
      quantity: _parseIntSafely(json['quantity']), // Use safe parsing
    );
  }
}

// Represents the data part of a successful checkout response.
class CheckoutData {
  final int? id;
  final int? userId;
  final List<CheckoutItem>? items;
  final int? total;
  final String? createdAt;
  final String? updatedAt;

  CheckoutData({
    this.id,
    this.userId,
    this.items,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      id: _parseIntSafely(json['id']), // Use safe parsing
      userId: _parseIntSafely(json['user_id']), // Use safe parsing
      items: json['items'] != null
          ? List<CheckoutItem>.from(
              json['items'].map((x) => CheckoutItem.fromJson(x)),
            )
          : null,
      total: _parseIntSafely(json['total']), // Use safe parsing
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// Full checkout response model.
class CheckoutResponse {
  final String message;
  final CheckoutData? data;

  CheckoutResponse({required this.message, this.data});

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      message: json['message'],
      data: json['data'] != null ? CheckoutData.fromJson(json['data']) : null,
    );
  }
}

// --- Generic Message Response (for delete operations or simple messages) ---
class MessageResponse {
  final String message;
  final dynamic data; // Can be null for delete operations or simple messages

  MessageResponse({required this.message, this.data});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(message: json['message'], data: json['data']);
  }
}

// --- Transaction History Models ---
// Assuming a structure for history items, if they were to be returned.
// Currently, Postman shows an empty 'data' field for GET Riwayat Belanja.
// This is a placeholder for future expansion if the API changes.
class HistoryItem {
  final int? id;
  final int? userId;
  final List<CheckoutItem>? items; // Reusing CheckoutItem
  final int? total;
  final String? createdAt;
  final String? updatedAt;

  HistoryItem({
    this.id,
    this.userId,
    this.items,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: _parseIntSafely(json['id']),
      userId: _parseIntSafely(json['user_id']),
      items: json['items'] != null
          ? List<CheckoutItem>.from(
              json['items'].map((x) => CheckoutItem.fromJson(x)),
            )
          : null,
      total: _parseIntSafely(json['total']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class HistoryListResponse {
  final String message;
  final List<HistoryItem>? data;

  HistoryListResponse({required this.message, this.data});

  factory HistoryListResponse.fromJson(Map<String, dynamic> json) {
    return HistoryListResponse(
      message: json['message'],
      data: json['data'] != null
          ? List<HistoryItem>.from(
              json['data'].map((x) => HistoryItem.fromJson(x)),
            )
          : null,
    );
  }
}
