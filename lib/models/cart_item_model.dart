import 'package:urban_market/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });
}
