/// Modelo para representar un producto.
/// Cada producto está asociado a una tienda (storeId).
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String storeId;
  final String storeName;
  final int stock;
  final List<String> categories;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.stock,
    required this.categories,
    this.isActive = true,
  });

  /// Factory constructor para crear una instancia de ProductModel desde un documento de Firestore.
  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      stock: data['stock'] ?? 0,
      // Se convierte la lista dinámica de Firestore a una List<String>.
      categories: List<String>.from(data['categories'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convierte la instancia de ProductModel a un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'storeName': storeName,
      'stock': stock,
      'categories': categories,
      'isActive': isActive,
    };
  }

  // ✅ --- MÉTODO AÑADIDO ---
  /// Convierte la instancia a un mapa incluyendo el ID del producto.
  /// Es útil para anidar este objeto dentro de otro, como en CartItemModel.
  Map<String, dynamic> toMapWithId() {
    final map = toMap();
    map['id'] = id;
    return map;
  }
  // --- FIN DEL MÉTODO AÑADIDO ---

  /// Crea una copia de la instancia actual con los campos proporcionados modificados.
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? storeId,
    String? storeName,
    int? stock,
    List<String>? categories,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      stock: stock ?? this.stock,
      categories: categories ?? this.categories,
      isActive: isActive ?? this.isActive,
    );
  }
}
