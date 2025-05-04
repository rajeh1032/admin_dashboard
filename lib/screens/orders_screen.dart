import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/enums/order_filter.dart';
import 'package:admin_dashboard/enums/order_types.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/confirm_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> orders = [];
  final statusColor = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.grey,
  ];
  final List<Color?> statusBgColor = [
    Colors.orange[50],
    Colors.blue[50],
    Colors.green[50],
    Colors.red[50],
    Colors.grey[50],
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
  Future<void> _handleOrderAction(
      BuildContext context, OrderStatus status) async {
    switch (status) {
      case OrderStatus.processing:
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Process Order',
          message: 'Are you sure you want to process this order?',
          confirmLabel: 'Process',
          confirmColor: Colors.blue,
          icon: Icons.check_circle,
        );
        if (confirmed == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order processed successfully')),
          );
        }
        break;
      case OrderStatus.cancelled:
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Cancel Order',
          message: 'Are you sure you want to cancel this order?',
          confirmLabel: 'Cancel Order',
          confirmColor: Colors.red,
          icon: Icons.cancel,
        );
        if (confirmed == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<OrderFilter>(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text('Status'),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: OrderFilter.all,
                    child: Text('All Orders'),
                  ),
                  const PopupMenuItem(
                    value: OrderFilter.pending,
                    child: Text('Pending'),
                  ),
                  const PopupMenuItem(
                    value: OrderFilter.processing,
                    child: Text('Processing'),
                  ),
                  const PopupMenuItem(
                    value: OrderFilter.completed,
                    child: Text('Completed'),
                  ),
                  const PopupMenuItem(
                    value: OrderFilter.cancelled,
                    child: Text('Cancelled'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(AppCollections.orders)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading orders'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == null ||
                      snapshot.data?.docs.isEmpty == true) {
                    return const Center(
                      child: Text('No orders found'),
                    );
                  }
                  final orders = snapshot.data!.docs
                      .map((doc) => OrderModel.fromJson(doc.data()))
                      .toList();

                  return ListView.builder(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          order.customerName,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total: \$${(index + 1) * 100}.00',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Items: ${index + 1}',
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
                                  PopupMenuButton<OrderStatus>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) => _handleOrderAction(
                                      context,
                                      order.status,
                                    ),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: OrderStatus.viewed,
                                        child: Text('View Details'),
                                      ),
                                      const PopupMenuItem(
                                        value: OrderStatus.processing,
                                        child: Text('Process Order'),
                                      ),
                                      const PopupMenuItem(
                                        value: OrderStatus.cancelled,
                                        child: Text('Cancel Order'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (index < 9) const Divider(),
                          ],
                        );
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
