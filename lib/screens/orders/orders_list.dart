import 'package:admin_dashboard/enums/order_types.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/screens/orders/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersList extends StatelessWidget {
  OrdersList({super.key, required this.orders});
  final List<OrderModel> orders;
  final statusColor = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.grey,
    Colors.purple,
  ];
  final List<Color?> statusBgColor = [
    Colors.orange[50],
    Colors.blue[50],
    Colors.green[50],
    Colors.red[50],
    Colors.grey[50],
    Colors.purple[50],
  ];
  Color getStatusColor(OrderStatus status) => switch (status) {
        OrderStatus.pending => statusColor[0],
        OrderStatus.processing => statusColor[1],
        OrderStatus.completed => statusColor[2],
        OrderStatus.cancelled => statusColor[3],
        OrderStatus.viewed => statusColor[4],
      };
  Color? getStatusBgColor(OrderStatus status) => switch (status) {
        OrderStatus.pending => statusBgColor[0],
        OrderStatus.processing => statusBgColor[1],
        OrderStatus.completed => statusBgColor[2],
        OrderStatus.cancelled => statusBgColor[3],
        OrderStatus.viewed => statusBgColor[4],
      };
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No Orders found. Add your first Order!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.separated(
      separatorBuilder: (_, index) => const Divider(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${(index + 1).toString().padLeft(6, '0')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.allProducts
                              .firstWhere(
                                  (product) => product.id == order.productId)
                              .name,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price: \$${order.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity : ${order.quantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusBgColor(order.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.name,
                        style: TextStyle(
                          color: getStatusColor(order.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await provider.showOrderDialog(
                            context: context,
                            isAdding: false,
                            order: order,
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await provider.deleteOrder(
                            context: context,
                            order: order,
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
