class StoreModel {
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
  final double deliveryFee;
  // Campos de Pagomovil
  final String paymentPhoneNumber;
  final String paymentBankName;
  final String paymentNationalId;

  StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.phone,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.ownerId,
    this.isActive = true,
    this.isOpen = false,
    this.category = 'General',
    this.openingTime = '09:00',
    this.closingTime = '21:00',
    this.deliveryFee = 5.0,
    required this.paymentPhoneNumber,
    required this.paymentBankName,
    required this.paymentNationalId,
  });

  // Constructor factory para crear una instancia desde un mapa (Firestore)
  factory StoreModel.fromMap(String id, Map<String, dynamic> data) {
    return StoreModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      isActive: data['isActive'] ?? true,
      isOpen: data['isOpen'] ?? false,
      category: data['category'] ?? 'General',
      openingTime: data['openingTime'] ?? '09:00',
      closingTime: data['closingTime'] ?? '21:00',
      deliveryFee: (data['deliveryFee'] ?? 5.0).toDouble(),
      paymentPhoneNumber: data['paymentPhoneNumber'] ?? '',
      paymentBankName: data['paymentBankName'] ?? '',
      paymentNationalId: data['paymentNationalId'] ?? '',
    );
  }

  // Método para convertir la instancia a un mapa (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
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
      'deliveryFee': deliveryFee,
      'paymentPhoneNumber': paymentPhoneNumber,
      'paymentBankName': paymentBankName,
      'paymentNationalId': paymentNationalId,
    };
  }

  // Método copyWith para facilitar la creación de copias con campos modificados
  StoreModel copyWith({
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
    double? deliveryFee,
    String? paymentPhoneNumber,
    String? paymentBankName,
    String? paymentNationalId,
  }) {
    return StoreModel(
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
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentPhoneNumber: paymentPhoneNumber ?? this.paymentPhoneNumber,
      paymentBankName: paymentBankName ?? this.paymentBankName,
      paymentNationalId: paymentNationalId ?? this.paymentNationalId,
    );
  }
}