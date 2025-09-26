import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  // NUEVO: Getter para calcular el total.
  // El método 'fold' suma los precios de todos los productos en la lista.
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.price);

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  // NUEVO: Método para eliminar un producto.
  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  // NUEVO: Método para vaciar el carrito.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
