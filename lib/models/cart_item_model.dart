import 'package:urban_market/models/product_model.dart';

/// Modelo para representar un ítem dentro de un carrito de compras o una orden.
class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.product,
    required this.quantity,
  });

  String get productName => product.name;
  double get price => product.price;

  /// Factory constructor para crear una instancia desde un mapa (leído de Firestore, usualmente anidado en una orden).
  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      // Se reconstruye el objeto ProductModel a partir del mapa anidado.
      // Esto asume que el mapa 'product' contiene todos los campos necesarios.
      product: ProductModel.fromMap(
          data['product']['id'] ?? '', // Extrae el id del mapa anidado
          data['product'] as Map<String, dynamic>),
      quantity: data['quantity'] ?? 0,
    );
  }

  /// Convierte la instancia a un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    // Se llama al toMap() del producto para crear un mapa anidado.
    final productMap = product.toMap();
    // Es importante asegurarse de que el 'id' esté en el mapa anidado
    // para poder reconstruirlo después con fromMap.
    productMap['id'] = product.id;

    return {
      'product': productMap,
      'quantity': quantity,
    };
  }

  /// Crea una copia de la instancia actual con los campos proporcionados modificados.
  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}