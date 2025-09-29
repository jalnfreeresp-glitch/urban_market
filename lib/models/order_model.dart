// lib/models/order_model.dart (Definitivo)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urban_market/models/cart_item_model.dart';

// Enum para los estados del pedido. Es más seguro que usar Strings.
enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blueAccent;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String storeId;
  final String storeName;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final OrderStatus status;
  final DateTime createdAt;
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final String? paymentMethod;
  final String? paymentTransactionId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    this.deliveryPersonId,
    this.deliveryPersonName,
    this.paymentMethod,
    this.paymentTransactionId,
  });

  DateTime get orderDate => createdAt;
  String? get paymentReference => paymentTransactionId;
  double get totalAmount => total;

  // Constructor factory para crear una instancia desde un mapa (Firestore)
  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((itemData) =>
                  CartItemModel.fromMap(itemData as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryPersonId: data['deliveryPersonId'],
      deliveryPersonName: data['deliveryPersonName'],
      paymentMethod: data['paymentMethod'],
      paymentTransactionId: data['paymentTransactionId'],
    );
  }

  // Método para convertir la instancia a un mapa (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'storeId': storeId,
      'storeName': storeName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'status': status.name, // Guardamos el nombre del enum como String
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': deliveryPersonName,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
    };
  }

  // Método copyWith para crear copias con campos modificados
  OrderModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? storeId,
    String? storeName,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? deliveryAddress,
    OrderStatus? status,
    DateTime? createdAt,
    String? deliveryPersonId,
    String? deliveryPersonName,
    String? paymentMethod,
    String? paymentTransactionId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      storeId: storeId ?? this.storeId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      storeName: storeName ?? this.storeName,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
    );
  }
}
