import 'package:flutter/foundation.dart';
import 'package:urban_market/models/cart_item_model.dart';
import 'package:urban_market/models/product_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  String? get storeId {
    if (_items.isEmpty) {
      return null;
    }
    return _items.values.first.product.storeId;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product, int quantity) {
    if (_items.isNotEmpty &&
        _items.values.first.product.storeId != product.storeId) {
      throw Exception('Solo puedes añadir productos de la misma tienda.');
    }

    if (_items.containsKey(product.id)) {
      // change quantity
      _items.update(
        product.id,
        (existingCartItem) => CartItemModel(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      // add new item
      _items.putIfAbsent(
        product.id,
        () => CartItemModel(
          id: DateTime.now().toString(),
          product: product,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItemModel(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}