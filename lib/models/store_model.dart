class Store {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String phone;
  final double rating;
  final int totalReviews;
  final String ownerId;
  final bool isActive;
  final bool isOpen;
  final String category;
  final String openingTime;
  final String closingTime;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.phone,
    required this.rating,
    required this.totalReviews,
    required this.ownerId,
    this.isActive = true,
    this.isOpen = false,
    this.category = '',
    this.openingTime = '09:00',
    this.closingTime = '21:00',
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ownerId: json['ownerId'] ?? '',
      isActive: json['isActive'] ?? true,
      isOpen: json['isOpen'] ?? false,
      category: json['category'] ?? '',
      openingTime: json['openingTime'] ?? '09:00',
      closingTime: json['closingTime'] ?? '21:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'rating': rating,
      'totalReviews': totalReviews,
      'ownerId': ownerId,
      'isActive': isActive,
      'isOpen': isOpen,
      'category': category,
      'openingTime': openingTime,
      'closingTime': closingTime,
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    String? phone,
    double? rating,
    int? totalReviews,
    String? ownerId,
    bool? isActive,
    bool? isOpen,
    String? category,
    String? openingTime,
    String? closingTime,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
      isOpen: isOpen ?? this.isOpen,
      category: category ?? this.category,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }
}
