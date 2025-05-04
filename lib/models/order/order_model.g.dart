// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      json['orderId'] as String,
      json['customerName'] as String,
      (json['price'] as num).toDouble(),
      (json['quantity'] as num).toInt(),
      json['details'] as String,
      $enumDecode(_$OrderStatusEnumMap, json['status']),
      DateTime.parse(json['createdAt'] as String),
      json['productId'] as String,
      json['categoryId'] as String,
      json['phoneNumber'] as String,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'customerName': instance.customerName,
      'price': instance.price,
      'quantity': instance.quantity,
      'details': instance.details,
      'productId': instance.productId,
      'categoryId': instance.categoryId,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'phoneNumber': instance.phoneNumber,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.completed: 'completed',
  OrderStatus.processing: 'processing',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.viewed: 'viewed',
  OrderStatus.fromUser: 'fromUser',
};
