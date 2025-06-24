import 'dart:convert';
import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://apptoko.mobileprojp.com/api';
  final LocalStorageService _localStorageService = LocalStorageService();

  // Helper method for making POST requests
  Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/$endpoint');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('POST Request to: $uri');
    print('Request Body: ${jsonEncode(body)}');
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

  // Helper method for making GET requests
  Future<http.Response> _get(String endpoint, {String? token}) async {
    final Uri uri = Uri.parse('$_baseUrl/$endpoint');
    final Map<String, String> headers = {'Accept': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('GET Request to: $uri');
    return await http.get(uri, headers: headers);
  }

  // Helper method for making DELETE requests
  Future<http.Response> _delete(String endpoint, {String? token}) async {
    final Uri uri = Uri.parse('$_baseUrl/$endpoint');
    final Map<String, String> headers = {'Accept': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('DELETE Request to: $uri');
    return await http.delete(uri, headers: headers);
  }

  // --- Authentication Endpoints ---

  // Register Pembeli
  Future<AuthResponse> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final response = await _post('register', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final AuthResponse authResponse = AuthResponse.fromJson(
        jsonDecode(response.body),
      );
      if (authResponse.data?.token != null && authResponse.data?.user != null) {
        await _localStorageService.saveUserToken(authResponse.data!.token!);
        await _localStorageService.saveUserData(authResponse.data!.user!);
      }
      return authResponse;
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // Login
  Future<AuthResponse> loginUser(String email, String password) async {
    final response = await _post('login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final AuthResponse authResponse = AuthResponse.fromJson(
        jsonDecode(response.body),
      );
      if (authResponse.data?.token != null && authResponse.data?.user != null) {
        await _localStorageService.saveUserToken(authResponse.data!.token!);
        await _localStorageService.saveUserData(authResponse.data!.user!);
      }
      return authResponse;
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // --- Product Endpoints (Admin) ---

  // POST Tambah Produk (Admin)
  // Requires authentication token
  Future<ProductAddResponse> addProduct(
    String name,
    String description,
    int price,
    int stock,
  ) async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _post('products', {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    }, token: token);

    if (response.statusCode == 200) {
      return ProductAddResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // GET Daftar Produk
  // Requires authentication token
  Future<ProductListResponse> getProducts() async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _get('products', token: token);

    if (response.statusCode == 200) {
      return ProductListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // --- Cart Endpoints ---

  // POST Tambah ke Keranjang
  Future<CartAddResponse> addToCart(int productId, int quantity) async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _post('cart', {
      'product_id': productId,
      'quantity': quantity,
    }, token: token);

    if (response.statusCode == 200) {
      return CartAddResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // GET List Keranjang
  Future<CartListResponse> getCartItems() async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _get('cart', token: token);

    if (response.statusCode == 200) {
      return CartListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // DELETE Produk dari Keranjang
  Future<MessageResponse> deleteCartItem(int cartItemId) async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _delete('cart/$cartItemId', token: token);

    if (response.statusCode == 200) {
      return MessageResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // POST Checkout
  Future<CheckoutResponse> checkout() async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _post(
      'checkout',
      {},
      token: token,
    ); // Empty body as per Postman

    if (response.statusCode == 200) {
      return CheckoutResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }

  // GET Riwayat Belanja
  Future<dynamic> getTransactionHistory() async {
    final token = await _localStorageService.getUserToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await _get('history', token: token);

    if (response.statusCode == 200) {
      // The history endpoint response body is empty in the Postman collection provided.
      // If it returns a list of history items, you'll need to define a model for that.
      // For now, it returns dynamic as it's an empty response.
      // If it returns a structured JSON, you'd do:
      // return HistoryListResponse.fromJson(jsonDecode(response.body));
      print('History response: ${response.body}');
      return jsonDecode(
        response.body,
      ); // Or return a specific model if structure is provided
    } else {
      throw ErrorResponse.fromJson(jsonDecode(response.body));
    }
  }
}
