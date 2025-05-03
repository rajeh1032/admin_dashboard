// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      json['orderId'] as String,
      json['customerName'] as String,
      (json['totalAmount'] as num).toDouble(),
      (json['items'] as num).toInt(),
      json['details'] as String,
      $enumDecode(_$OrderStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'customerName': instance.customerName,
      'totalAmount': instance.totalAmount,
      'items': instance.items,
      'details': instance.details,
      'status': _$OrderStatusEnumMap[instance.status]!,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.completed: 'completed',
  OrderStatus.processing: 'processing',
  OrderStatus.canceled: 'canceled',
};
