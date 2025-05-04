import 'package:admin_dashboard/enums/order_types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String orderId;
  final String customerName;
  final double price;
  final int quantity;
  final String details;
  final String productId;
  final String categoryId;
  final DateTime createdAt;
  final OrderStatus status;

  OrderModel(
      this.orderId,
      this.customerName,
      this.price,
      this.quantity,
      this.details,
      this.status,
      this.createdAt,
      this.productId,
      this.categoryId);
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
