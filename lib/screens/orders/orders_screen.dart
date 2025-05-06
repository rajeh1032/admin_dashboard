import 'package:admin_dashboard/enums/order_filter.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/screens/orders/order_provider.dart';
import 'package:admin_dashboard/screens/orders/orders_list.dart';
import 'package:admin_dashboard/widgets/add_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider()
        ..fetchCategories()
        ..fetchProducts()
        ..fetchOrders(),
      child: const OrdersDashboard(),
    );
  }
}

class OrdersDashboard extends StatefulWidget {
  const OrdersDashboard({super.key});

  @override
  State<OrdersDashboard> createState() => _OrdersDashbordState();
}

class _OrdersDashbordState extends State<OrdersDashboard> {
  List<OrderModel> orders = [];

  // Future<void> _handleOrderAction(
  //   BuildContext context,
  //   OrderStatus status,
  // ) async {
  //   switch (status) {
  //     case OrderStatus.processing:
  //       final confirmed = await ConfirmDialog.show(
  //         context: context,
  //         title: 'Process Order',
  //         message: 'Are you sure you want to process this order?',
  //         confirmLabel: 'Process',
  //         confirmColor: Colors.blue,
  //         icon: Icons.check_circle,
  //       );
  //       if (confirmed == true) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Order processed successfully')),
  //         );
  //       }
  //       break;
  //     case OrderStatus.cancelled:
  //       final confirmed = await ConfirmDialog.show(
  //         context: context,
  //         title: 'Cancel Order',
  //         message: 'Are you sure you want to cancel this order?',
  //         confirmLabel: 'Cancel Order',
  //         confirmColor: Colors.red,
  //         icon: Icons.cancel,
  //       );
  //       if (confirmed == true) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Order cancelled successfully')),
  //         );
  //       }
  //       break;
  //     default:
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              AddItemButton(
                onPressed: () async {
                  await provider.showOrderDialog(
                    context: context,
                    isAdding: true,
                  );
                },
                label: 'Add Order',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => provider.searchOrder(value),
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
                onSelected: (value) => provider.searchOrder(value.name),
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
                  const PopupMenuItem(
                    value: OrderFilter.viewed,
                    child: Text('Viewed'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.filteredOrders.isNotEmpty)
            Expanded(
              child: OrdersList(
                orders: provider.filteredOrders,
              ),
            )
          else if (provider.filteredOrders.isEmpty &&
              provider.orders.isNotEmpty)
            Expanded(
              child: OrdersList(
                orders: const [],
              ),
            )
//           else
//             Expanded(
//               child: StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection(AppCollections.orders)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return const Center(
//                       child: Text('Error loading orders'),
//                     );
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//                   final orders = snapshot.data!.docs
//                       .map((doc) => OrderModel.fromJson(doc.data()))
//                       .toList();
//                   provider.orders = orders;
//                   return OrdersList(
//                     orders: orders,
//                   );
//                 },
//               ),
//             ),
        ],
      ),
    );
  }
}
