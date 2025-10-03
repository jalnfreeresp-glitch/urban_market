// lib/models/cart_item_model.dart
import 'package:urban_market/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  // --- MÉTODO CORREGIDO ---
  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    final productData = data['product'] as Map<String, dynamic>?;

    // Verificamos si los datos del producto existen antes de usarlos.
    if (productData == null) {
      // Si no hay datos de producto, es un dato corrupto.
      // Lanzamos un error claro en lugar de dejar que la app crashee.
      throw StateError(
          'Se encontró un item de carrito sin datos de producto. ID del item: ${data['id']}');
    }

    return CartItemModel(
      // Usamos '??' para proveer valores por defecto en caso de que un campo sea nulo.
      id: data['id'] ?? '',
      product: ProductModel.fromMap(productData['id'] ?? '', productData),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product
          .toMapWithId(), // Asegúrate de que este método exista en ProductModel
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
