import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para representar a un usuario en la aplicación.
/// Contiene toda la información relevante del usuario y métodos
/// para convertir los datos desde y hacia el formato de Firestore.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'Administrador', 'Vendedor', 'Cliente', 'Repartidor'
  final String? address;
  final String? storeId; // Vincula un vendedor a una tienda
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.storeId,
    required this.createdAt,
    this.isActive = true,
  });

  /// Factory constructor para crear una instancia de UserModel desde un documento de Firestore.
  /// El 'id' del documento se pasa por separado del mapa de datos.
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'Cliente',
      address: data['address'],
      storeId: data['storeId'],
      // Firestore devuelve un Timestamp, hay que convertirlo a DateTime.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convierte la instancia de UserModel a un mapa de datos para guardarlo en Firestore.
  /// El 'id' no se incluye aquí porque es el identificador del documento.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'storeId': storeId,
      'createdAt': Timestamp.fromDate(createdAt), // Se convierte a Timestamp.
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? address,
    String? storeId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
