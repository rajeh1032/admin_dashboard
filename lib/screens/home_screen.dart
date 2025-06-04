import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/enums/order_types.dart';
import 'package:admin_dashboard/enums/product_status.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/models/user/user_model.dart';
import 'package:admin_dashboard/screens/orders/orders_screen.dart';
import 'package:admin_dashboard/screens/products/products_screen.dart';
import 'package:admin_dashboard/widgets/ui_components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/sidebar.dart';
import 'categories/categories_screen.dart';
import 'users/users_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isDrawerOpen = true;
  int selectedIndex = 0;

  final List<Widget> _screens = [
    _DashboardContent(),
    const UsersScreen(),
    const CategoriesScreen(),
    const ProductsScreen(),
    const OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.primary,
              title: const Text(
                'KhordaClick Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isDrawerOpen = !isDrawerOpen;
                  });
                },
              ),
              elevation: 0,
            ),
      drawer: !isDesktop
          ? Sidebar(
              isDesktop: isDesktop,
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
                Navigator.pop(
                    context); // Close drawer after selection on mobile
              },
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            Sidebar(
              isDesktop: isDesktop,
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          Expanded(
            child: _screens[selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  List<UserModel> users = [];
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _fetchUsers(),
        _fetchProducts(),
        _fetchCategories(),
        _fetchOrders(),
      ]);
    } catch (e) {
      // Handle errors
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    FirebaseFirestore.instance
        .collection(AppCollections.users)
        .snapshots()
        .listen((data) {
      setState(() {
        users = data.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      });
    });
  }

  Future<void> _fetchProducts() async {
    FirebaseFirestore.instance
        .collection(AppCollections.products)
        .snapshots()
        .listen((data) {
      setState(() {
        products =
            data.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
      });
    });
  }

  Future<void> _fetchCategories() async {
    FirebaseFirestore.instance
        .collection(AppCollections.categories)
        .snapshots()
        .listen((data) {
      setState(() {
        categories =
            data.docs.map((doc) => CategoryModel.fromJson(doc.data())).toList();
      });
    });
  }

  Future<void> _fetchOrders() async {
    FirebaseFirestore.instance
        .collection(AppCollections.orders)
        .snapshots()
        .listen((data) {
      setState(() {
        orders =
            data.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      alignment: Alignment.topCenter,
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Welcome to your KhordaClick administration panel',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AppButton(
                  onPressed: _fetchData,
                  isOutlined: true,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 4),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Main stats cards
            isSmallScreen
                ? Column(
                    children: [
                      _buildStatCard(
                        title: 'Total Users',
                        value: users.length.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                        description: 'Registered users',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStatCard(
                        title: 'Total Categories',
                        value: categories.length.toString(),
                        icon: Icons.category,
                        color: Colors.orange,
                        description: 'Product categories',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStatCard(
                        title: 'Total Products',
                        value: products.length.toString(),
                        icon: Icons.inventory_2,
                        color: Colors.green,
                        description: 'Available products',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStatCard(
                        title: 'Total Orders',
                        value: orders.length.toString(),
                        icon: Icons.shopping_cart,
                        color: Colors.purple,
                        description: 'Processed orders',
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Users',
                          value: users.length.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          description: 'Registered users',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Categories',
                          value: categories.length.toString(),
                          icon: Icons.category,
                          color: Colors.orange,
                          description: 'Product categories',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Products',
                          value: products.length.toString(),
                          icon: Icons.inventory_2,
                          color: Colors.green,
                          description: 'Available products',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Orders',
                          value: orders.length.toString(),
                          icon: Icons.shopping_cart,
                          color: Colors.purple,
                          description: 'Processed orders',
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: AppSpacing.xl),

            // Order summary section
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            isSmallScreen
                ? Column(
                    children: [
                      _buildOrderSummaryCard(
                        title: 'Pending',
                        count: orders
                            .where((o) => o.status == OrderStatus.pending)
                            .length,
                        color: Colors.orange,
                        icon: Icons.hourglass_empty,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildOrderSummaryCard(
                        title: 'Processing',
                        count: orders
                            .where((o) => o.status == OrderStatus.processing)
                            .length,
                        color: Colors.blue,
                        icon: Icons.pending_actions,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildOrderSummaryCard(
                        title: 'Completed',
                        count: orders
                            .where((o) => o.status == OrderStatus.completed)
                            .length,
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildOrderSummaryCard(
                        title: 'Cancelled',
                        count: orders
                            .where((o) => o.status == OrderStatus.cancelled)
                            .length,
                        color: Colors.red,
                        icon: Icons.cancel,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildOrderSummaryCard(
                          title: 'Pending',
                          count: orders
                              .where((o) => o.status == OrderStatus.pending)
                              .length,
                          color: Colors.orange,
                          icon: Icons.hourglass_empty,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildOrderSummaryCard(
                          title: 'Processing',
                          count: orders
                              .where((o) => o.status == OrderStatus.processing)
                              .length,
                          color: Colors.blue,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildOrderSummaryCard(
                          title: 'Completed',
                          count: orders
                              .where((o) => o.status == OrderStatus.completed)
                              .length,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildOrderSummaryCard(
                          title: 'Cancelled',
                          count: orders
                              .where((o) => o.status == OrderStatus.cancelled)
                              .length,
                          color: Colors.red,
                          icon: Icons.cancel,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return AppCard(
      boxShadow: AppShadows.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return AppCard(
      boxShadow: AppShadows.small,
      backgroundColor: color.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                '$count orders',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward,
            color: color,
            size: 18,
          ),
        ],
      ),
    );
  }
}
