import 'package:flutter/material.dart';
import 'nav_item.dart';

class Sidebar extends StatelessWidget {
  final bool isDesktop;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.isDesktop,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: isDesktop ? 0 : 2,
      child: Container(
        width: 250,
        color: const Color(0xFF1E2530),
        child: Column(
          children: [
            if (!isDesktop)
              const DrawerHeader(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isDesktop)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            NavItem(
              icon: Icons.dashboard,
              title: 'Overview',
              isSelected: selectedIndex == 0,
              onTap: () {
                onItemSelected(0);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
            ),
            NavItem(
              icon: Icons.people,
              title: 'Users',
              isSelected: selectedIndex == 1,
              onTap: () {
                onItemSelected(1);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
            ),
            NavItem(
              icon: Icons.category,
              title: 'Categories',
              isSelected: selectedIndex == 2,
              onTap: () {
                onItemSelected(2);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
            ),
            NavItem(
              icon: Icons.inventory,
              title: 'Products',
              isSelected: selectedIndex == 3,
              onTap: () {
                onItemSelected(3);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
            ),
            NavItem(
              icon: Icons.shopping_cart,
              title: 'Orders',
              isSelected: selectedIndex == 4,
              onTap: () {
                onItemSelected(4);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
