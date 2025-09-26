import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Importar para debugPrint
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/models/store_model.dart';

class ApiService {
  static const String _baseUrl =
      'https://your-api-url.com/api'; // Reemplaza con tu URL real

  // Products API
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      debugPrint(
          'Error getting products: $e'); // Usamos debugPrint en lugar de print
      return [];
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      debugPrint(
          'Error creating product: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      debugPrint(
          'Error updating product: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }

  // Stores API
  Future<List<Store>> getStores() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stores'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Store.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      debugPrint(
          'Error getting stores: $e'); // Usamos debugPrint en lugar de print
      return [];
    }
  }

  Future<void> createStore(Store store) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/stores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(store.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create store');
      }
    } catch (e) {
      debugPrint(
          'Error creating store: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }

  // Orders API
  Future<List<Order>> getOrders(String userId, String role) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/orders?userId=$userId&role=$role'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      debugPrint(
          'Error getting orders: $e'); // Usamos debugPrint en lugar de print
      return [];
    }
  }

  Future<List<Order>> getPendingOrders() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders/pending'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pending orders');
      }
    } catch (e) {
      debugPrint(
          'Error getting pending orders: $e'); // Usamos debugPrint en lugar de print
      return [];
    }
  }

  Future<void> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      debugPrint(
          'Error creating order: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status.index}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      debugPrint(
          'Error updating order status: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }
}
