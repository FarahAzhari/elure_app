import 'dart:convert';

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
  // Add other fields here if different error types appear (e.g., 'name', 'product_id')

  ErrorDetail({this.email, this.password});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      email: json['email'] != null
          ? List<String>.from(json['email'].map((x) => x))
          : null,
      password: json['password'] != null
          ? List<String>.from(json['password'].map((x) => x))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

// Represents an API error response, typically with a message and specific error details.
class ErrorResponse {
  final String message;
  final ErrorDetail? errors;

  ErrorResponse({required this.message, this.errors});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'],
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
      id: json['id'],
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

// --- Product Models ---
// Represents a single product.
class Product {
  final int? id;
  final String? name;
  final String? description;
  final int? price; // Changed to int?
  final int? stock; // Changed to int?
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely parse price and stock, handling potential string or double types
    int? parseToInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt(); // Convert double to int
      if (value is String)
        return int.tryParse(value); // Try parsing string to int
      return null;
    }

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: parseToInt(json['price']), // Use the safe parsing function
      stock: parseToInt(json['stock']), // Use the safe parsing function
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

// --- Cart Models ---
// Represents a simplified product within a cart item (only ID, name, price needed).
class CartProduct {
  final int? id;
  final String? name;
  final int? price;

  CartProduct({this.id, this.name, this.price});

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
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
      id: json['id'],
      product: json['product'] != null
          ? CartProduct.fromJson(json['product'])
          : null,
      quantity: json['quantity'],
      subtotal: json['subtotal'],
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
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
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
      quantity: json['quantity'],
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
      id: json['id'],
      userId: json['user_id'],
      items: json['items'] != null
          ? List<CheckoutItem>.from(
              json['items'].map((x) => CheckoutItem.fromJson(x)),
            )
          : null,
      total: json['total'],
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
