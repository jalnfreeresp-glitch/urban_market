import 'package:flutter/foundation.dart';
// Se añaden alias para consistencia
import 'package:urban_market/models/cart_item_model.dart' as cim;
import 'package:urban_market/models/product_model.dart' as pm;

class CartProvider with ChangeNotifier {
  Map<String, cim.CartItemModel> _items = {};

  Map<String, cim.CartItemModel> get items => {..._items};

  int get itemCount {
    // Retorna el total de unidades de productos en el carrito.
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  String? get storeId {
    if (_items.isEmpty) return null;
    return _items.values.first.product.storeId;
  }

  double get subtotal {
    return _items.values
        .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Lógica de ejemplo para la tarifa de envío
  double get deliveryFee {
    if (subtotal == 0.0) return 0.0;
    // Tarifa fija o basada en el subtotal
    return 5.0;
  }

  double get totalAmount => subtotal + deliveryFee;

  void addItem(pm.ProductModel product, {int quantity = 1}) {
    if (_items.isNotEmpty &&
        _items.values.first.product.storeId != product.storeId) {
      // Si se intenta añadir un producto de otra tienda, se limpia el carrito primero.
      clear();
      debugPrint('Carrito limpiado. Añadiendo producto de nueva tienda.');
    }

    _items.update(
      product.id,
      (existingItem) => existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      ),
      ifAbsent: () => cim.CartItemModel(
        product: product,
        quantity: quantity,
      ),
    );
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity - 1,
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
