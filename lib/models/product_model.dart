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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      stock: json['stock'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

  // Método copyWith para crear copias con campos modificados
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
