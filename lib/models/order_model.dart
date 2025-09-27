import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pendientePago,
  enProceso,
  enCamino,
  entregado,
  cancelado,
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String storeId;
  final String storeName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final DateTime? deliveryTime;
  final String? paymentReference;
  final String notes;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pendientePago,
    this.deliveryPersonId,
    this.deliveryPersonName,
    this.deliveryTime,
    this.paymentReference,
    this.notes = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      status: OrderStatus.values[json['status'] ?? OrderStatus.pendientePago.index],
      deliveryPersonId: json['deliveryPersonId'],
      deliveryPersonName: json['deliveryPersonName'],
      deliveryTime: json['deliveryTime'] != null
          ? (json['deliveryTime'] as Timestamp).toDate()
          : null,
      paymentReference: json['paymentReference'],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'storeId': storeId,
      'storeName': storeName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.index,
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': deliveryPersonName,
      'deliveryTime': deliveryTime != null ? Timestamp.fromDate(deliveryTime!) : null,
      'paymentReference': paymentReference,
      'notes': notes,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? storeId,
    String? storeName,
    List<OrderItemModel>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? deliveryPersonId,
    String? deliveryPersonName,
    DateTime? deliveryTime,
    String? paymentReference,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String storeId;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.storeId,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      storeId: json['storeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'storeId': storeId,
    };
  }
}
