import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/sidebar.dart';
import 'users/users_screen.dart';
import 'categories/categories_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';

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
    UsersScreen(),
    const CategoriesScreen(),
    ProductsScreen(),
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

class _DashboardContent extends StatelessWidget {
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
                  children: const [
                    StatCard(
                      title: 'Users',
                      value: '22',
                      icon: Icons.people,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Categories',
                      value: '5',
                      icon: Icons.category,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Products',
                      value: '10',
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Orders',
                      value: '0',
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
