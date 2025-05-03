import 'package:admin_dashboard/enums/order_types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String orderId;
  final String customerName;
  final double totalAmount;
  final int items;
  final String details;
  final DateTime createdAt;
  final OrderStatus status;

  OrderModel(this.orderId, this.customerName, this.totalAmount, this.items,
      this.details, this.status, this.createdAt);
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
