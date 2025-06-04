import 'package:admin_dashboard/enums/order_filter.dart';
import 'package:admin_dashboard/enums/order_types.dart';
import 'package:admin_dashboard/enums/product_status.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/screens/orders/order_provider.dart';
import 'package:admin_dashboard/screens/orders/orders_list.dart';
import 'package:admin_dashboard/widgets/ui_components.dart';
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
  State<OrdersDashboard> createState() => _OrdersDashboardState();
}

class _OrdersDashboardState extends State<OrdersDashboard> {
  final TextEditingController searchController = TextEditingController();
  OrderFilter? selectedFilter;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(context, provider),

          const SizedBox(height: AppSpacing.lg),

          // Stats cards
          if (!isSmallScreen && provider.orders.isNotEmpty)
            _buildStatsCards(provider),

          const SizedBox(height: AppSpacing.lg),

          // Search and filter section
          _buildSearchAndFilters(provider),

          const SizedBox(height: AppSpacing.lg),

          // Orders list
          Expanded(
            child: _buildOrdersContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrderProvider provider) {
    return Responsive(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            onPressed: () async {
              await provider.showOrderDialog(
                context: context,
                isAdding: true,
              );
            },
            isFullWidth: true,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: AppSpacing.sm),
                Text('Create New Order'),
              ],
            ),
          ),
        ],
      ),
      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Order Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppButton(
            onPressed: () async {
              await provider.showOrderDialog(
                context: context,
                isAdding: true,
              );
            },
            child: const Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: AppSpacing.sm),
                Text('Create New Order'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(OrderProvider provider) {
    // Count orders by status
    final pendingCount =
        provider.orders.where((o) => o.status == OrderStatus.pending).length;
    final processingCount =
        provider.orders.where((o) => o.status == OrderStatus.processing).length;
    final completedCount =
        provider.orders.where((o) => o.status == OrderStatus.completed).length;
    final cancelledCount =
        provider.orders.where((o) => o.status == OrderStatus.cancelled).length;

    // Calculate total revenue from completed orders
    final totalRevenue = provider.orders
        .where((o) => o.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + (order.price * order.quantity));

    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              title: 'Total Orders',
              value: provider.orders.length.toString(),
              icon: Icons.shopping_cart,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard(
              title: 'Pending Orders',
              value: pendingCount.toString(),
              icon: Icons.hourglass_empty,
              color: Colors.orange,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard(
              title: 'Completed Orders',
              value: completedCount.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildStatCard(
              title: 'Processing',
              value: processingCount.toString(),
              icon: Icons.pending_actions,
              color: AppColors.info,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard(
              title: 'Cancelled',
              value: cancelledCount.toString(),
              icon: Icons.cancel,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard(
              title: 'Total Revenue',
              value: '\$${totalRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.green.shade700,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        boxShadow: AppShadows.small,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(OrderProvider provider) {
    return Responsive(
      mobile: Column(
        children: [
          AppTextField(
            controller: searchController,
            label: 'Search',
            hint: 'Search by order #, customer name or product',
            prefixIcon: Icons.search,
            onChanged: (value) {
              provider.searchOrder(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<OrderFilter?>(
            value: selectedFilter,
            hint: 'Filter by status',
            icon: Icons.filter_list,
            items: [
              const DropdownMenuItem<OrderFilter?>(
                value: null,
                child: Text('All Orders'),
              ),
              ...OrderFilter.values
                  .map((filter) => DropdownMenuItem<OrderFilter?>(
                        value: filter,
                        child: Text(filter.name),
                      )),
            ],
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
              });
              provider.searchOrder(value?.name ?? 'all');
            },
          ),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppTextField(
              controller: searchController,
              label: 'Search',
              hint: 'Search by order #, customer name or product',
              prefixIcon: Icons.search,
              onChanged: (value) {
                provider.searchOrder(value);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 1,
            child: AppDropdown<OrderFilter?>(
              value: selectedFilter,
              hint: 'Filter by status',
              icon: Icons.filter_list,
              items: [
                const DropdownMenuItem<OrderFilter?>(
                  value: null,
                  child: Text('All Orders'),
                ),
                ...OrderFilter.values
                    .map((filter) => DropdownMenuItem<OrderFilter?>(
                          value: filter,
                          child: Text(filter.name),
                        )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
                provider.searchOrder(value?.name ?? 'all');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent(OrderProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.orders.isEmpty) {
      return AppEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'No Orders Yet',
        message: 'Create your first order to get started',
        action: AppButton(
          onPressed: () async {
            await provider.showOrderDialog(
              context: context,
              isAdding: true,
            );
          },
          child: const Text('Create Order'),
        ),
      );
    }

    if (provider.filteredOrders.isEmpty && provider.orders.isNotEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: 'No Matching Orders',
        message: 'Try adjusting your search or filters',
      );
    }

    return provider.filteredOrders.isNotEmpty
        ? AppCard(
            padding: EdgeInsets.zero,
            child: ImprovedOrdersList(
              orders: provider.filteredOrders,
              parentContext: context,
            ),
          )
        : const SizedBox();
  }
}

class ImprovedOrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final BuildContext parentContext;

  const ImprovedOrdersList({
    super.key,
    required this.orders,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    if (isSmallScreen) {
      return _buildMobileOrdersList(provider);
    } else {
      return _buildDesktopOrdersList(provider);
    }
  }

  Widget _buildMobileOrdersList(OrderProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemCount: provider.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = provider.filteredOrders[index];
        final product = provider.allProducts.firstWhere(
          (product) => product.id == order.productId,
          orElse: () => ProductModel(
            id: '',
            name: 'Product not found',
            description: '',
            price: 0,
            quantity: 0,
            imageUrl: '',
            categoryID: '',
            createdAt: DateTime.now(),
            status: ProductStatus.fromUser,
          ),
        );

        return AppCard(
          boxShadow: AppShadows.small,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderId.substring(0, 6)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.sm),

              // Order details
              Row(
                children: [
                  const Icon(Icons.person,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.shopping_bag,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.phone,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(order.phoneNumber),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.sm),

              // Order summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.quantity} × \$${order.price}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Total: \$${(order.quantity * order.price).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppIconButton(
                    icon: Icons.edit,
                    color: AppColors.info,
                    size: 36,
                    onPressed: () async {
                      await provider.showOrderDialog(
                        context: parentContext,
                        isAdding: false,
                        order: order,
                      );
                    },
                    tooltip: 'Edit Order',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppIconButton(
                    icon: Icons.delete,
                    color: AppColors.error,
                    size: 36,
                    onPressed: () async {
                      await provider.deleteOrder(
                        context: parentContext,
                        order: order,
                      );
                    },
                    tooltip: 'Delete Order',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopOrdersList(OrderProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: Theme(
        // Override default data table theme to ensure better visibility
        data: Theme.of(parentContext).copyWith(
          dataTableTheme: const DataTableThemeData(
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            dataTextStyle: TextStyle(
              color: AppColors.textPrimary,
            ),
            dividerThickness: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columnSpacing: 16,
              horizontalMargin: 8,
              border: const TableBorder(
                horizontalInside:
                    BorderSide(color: AppColors.divider, width: 1),
              ),
              dataRowHeight: 65,
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: provider.filteredOrders.map((order) {
                final product = provider.allProducts.firstWhere(
                  (product) => product.id == order.productId,
                  orElse: () => ProductModel(
                    id: '',
                    name:
                        'Product from user\n please open the product to see the details',
                    description: '',
                    price: 0,
                    quantity: 0,
                    imageUrl: '',
                    categoryID: '',
                    createdAt: DateTime.now(),
                    status: ProductStatus.fromUser,
                  ),
                );

                return DataRow(
                  cells: [
                    // Order ID
                    DataCell(
                      Text(
                        '#${order.orderId.substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Customer
                    DataCell(
                      Text(
                        "${order.customerName}\n ${order.phoneNumber}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Product
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Quantity
                    DataCell(
                      Center(
                        child: Text(
                          order.quantity.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Price
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${order.price}'),
                          Text(
                            'Total: \$${(order.quantity * order.price).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status
                    DataCell(_buildStatusBadge(order.status)),

                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIconButton(
                            icon: Icons.edit,
                            color: AppColors.info,
                            size: 32,
                            onPressed: () async {
                              await provider.showOrderDialog(
                                context: parentContext,
                                isAdding: false,
                                order: order,
                              );
                            },
                            tooltip: 'Edit Order',
                          ),
                          const SizedBox(width: 8),
                          AppIconButton(
                            icon: Icons.delete,
                            color: AppColors.error,
                            size: 32,
                            onPressed: () async {
                              await provider.deleteOrder(
                                context: parentContext,
                                order: order,
                              );
                            },
                            tooltip: 'Delete Order',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text = status.name;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        text = 'Pending';
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        icon = Icons.pending_actions;
        text = 'Processing';
        break;
      case OrderStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Completed';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Cancelled';
        break;
      case OrderStatus.viewed:
        color = Colors.purple;
        icon = Icons.visibility;
        text = 'Viewed';
        break;
    }

    return AppBadge(
      text: text,
      color: color,
      icon: icon,
    );
  }
}
