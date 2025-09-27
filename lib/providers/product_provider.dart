// lib/providers/product_provider.dart (actualizado)
import 'package:flutter/foundation.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<StoreModel> _stores = [];

  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  List<StoreModel> get stores => _stores;

  Future<void> loadProducts() async {
    try {
      final products = await FirestoreService.getActiveProducts();
      _products = products;
      _filteredProducts = products;
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Error loading products: $e'); // Usamos debugPrint en lugar de print
    }
  }

  Future<void> loadStores() async {
    try {
      final stores = await FirestoreService.getActiveStores();
      _stores = stores;
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Error loading stores: $e'); // Usamos debugPrint en lugar de print
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await FirestoreService.createProduct(product);
      _products.add(product);
      _filteredProducts.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Error adding product: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await FirestoreService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
      final filteredIndex =
          _filteredProducts.indexWhere((p) => p.id == product.id);
      if (filteredIndex != -1) {
        _filteredProducts[filteredIndex] = product;
      }
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Error updating product: $e'); // Usamos debugPrint en lugar de print
      rethrow;
    }
  }

  List<ProductModel> getProductsByStore(String storeId) {
    return _products.where((product) => product.storeId == storeId).toList();
  }

  void filterProductsByStore(String storeId) {
    _filteredProducts =
        _products.where((product) => product.storeId == storeId).toList();
    notifyListeners();
  }

  void clearFilters() {
    _filteredProducts = _products;
    notifyListeners();
  }
}
