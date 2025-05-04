import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/models/user/user_model.dart';
import 'package:admin_dashboard/screens/products/products_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
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
    // const OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1E2530),
              title: const Text('KhordaClick Admin Dashboard'),
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isDrawerOpen = !isDrawerOpen;
                  });
                },
              ),
            ),
      drawer: !isDesktop
          ? Sidebar(
              isDesktop: isDesktop,
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
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
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    FirebaseFirestore.instance
        .collection(AppCollections.users)
        .snapshots()
        .listen((data) {
      users.clear();
      users = data.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      setState(() {});
    });
    FirebaseFirestore.instance
        .collection(AppCollections.products)
        .snapshots()
        .listen((data) {
      products.clear();
      products =
          data.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
      setState(() {});
    });
    FirebaseFirestore.instance
        .collection(AppCollections.categories)
        .snapshots()
        .listen((data) {
      categories.clear();
      categories =
          data.docs.map((doc) => CategoryModel.fromJson(doc.data())).toList();
      setState(() {});
    });
    FirebaseFirestore.instance
        .collection(AppCollections.orders)
        .snapshots()
        .listen((data) {
      orders.clear();
      orders = data.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double childAspectRatio;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                  childAspectRatio = 2;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 2;
                  childAspectRatio = 2;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 2.5;
                }
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  children: [
                    StatCard(
                      title: 'Users',
                      value: users.length.toString(),
                      icon: Icons.people,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Categories',
                      value: categories.length.toString(),
                      icon: Icons.category,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Products',
                      value: products.length.toString(),
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Orders',
                      value: orders.length.toString(),
                      icon: Icons.shopping_cart,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
