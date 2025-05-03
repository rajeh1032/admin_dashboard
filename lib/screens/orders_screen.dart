import 'package:flutter/material.dart';
import '../widgets/confirm_dialog.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Future<void> _handleOrderAction(
      BuildContext context, String action, int orderId) async {
    switch (action) {
      case 'view':
        // TODO: Navigate to order details screen
        break;
      case 'process':
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Process Order',
          message: 'Are you sure you want to process this order?',
          confirmLabel: 'Process',
          confirmColor: Colors.blue,
          icon: Icons.check_circle,
        );
        if (confirmed == true) {
          // TODO: Implement order processing logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order processed successfully')),
          );
        }
        break;
      case 'cancel':
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Cancel Order',
          message: 'Are you sure you want to cancel this order?',
          confirmLabel: 'Cancel Order',
          confirmColor: Colors.red,
          icon: Icons.cancel,
        );
        if (confirmed == true) {
          // TODO: Implement order cancellation logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
        }
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
              PopupMenuButton<String>(
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
                    value: 'all',
                    child: Text('All Orders'),
                  ),
                  const PopupMenuItem(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                  const PopupMenuItem(
                    value: 'processing',
                    child: Text('Processing'),
                  ),
                  const PopupMenuItem(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final statusIndex = index % 4;
                  final status = [
                    'Pending',
                    'Processing',
                    'Completed',
                    'Cancelled'
                  ][statusIndex];
                  final statusColor = [
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red
                  ][statusIndex];
                  final statusBgColor = [
                    Colors.orange[50],
                    Colors.blue[50],
                    Colors.green[50],
                    Colors.red[50]
                  ][statusIndex];

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
                                    'Order #${index.toString().padLeft(6, '0')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer: John Doe',
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
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) =>
                                  _handleOrderAction(context, value, index),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'process',
                                  child: Text('Process Order'),
                                ),
                                const PopupMenuItem(
                                  value: 'cancel',
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
