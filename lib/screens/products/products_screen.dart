import 'package:admin_dashboard/enums/product_filter.dart';
import 'package:admin_dashboard/screens/products/all_products.dart';
import 'package:admin_dashboard/screens/products/product_provider.dart';
import 'package:admin_dashboard/widgets/add_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider()
        ..getCategories()
        ..fetchProducts(),
      child: const ProdcutsDashboard(),
    );
  }
}

class ProdcutsDashboard extends StatelessWidget {
  const ProdcutsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and add button
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AddItemButton(
                        onPressed: () async => await provider.showProductDialog(
                          context: context,
                          isAdding: true,
                        ),
                        label: 'Add Product',
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    AddItemButton(
                      onPressed: () async => await provider.showProductDialog(
                        context: context,
                        isAdding: true,
                      ),
                      label: 'Add Product',
                    ),
                  ],
                ),

          const SizedBox(height: 24),

          // Search and filter section
          isSmallScreen
              ? Column(
                  children: [
                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Products...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      onChanged: (value) => provider.searchProducts(value),
                    ),
                    const SizedBox(height: 16),

                    // Filter dropdown
                    _buildFilterDropdown(provider),
                  ],
                )
              : Row(
                  children: [
                    // Search field
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Products...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.blue),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        onChanged: (value) => provider.searchProducts(value),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Filter dropdown
                    Expanded(
                      flex: 1,
                      child: _buildFilterDropdown(provider),
                    ),
                  ],
                ),

          const SizedBox(height: 24),

          // Statistics cards
          if (!isSmallScreen &&
              !provider.isLoading &&
              provider.products.isNotEmpty) ...[
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Total Products',
                  provider.products.length.toString(),
                  Icons.inventory_2,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  'In Stock',
                  provider.products
                      .where((p) => p.quantity > 0)
                      .length
                      .toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  'Out of Stock',
                  provider.products
                      .where((p) => p.quantity <= 0)
                      .length
                      .toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Main content
          Expanded(
            child: _buildMainContent(provider, screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ProductProvider provider, Size screenSize) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    } else if (provider.filteredProducts.isEmpty && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first product to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: provider.filteredProducts.isNotEmpty
              ? ProductsList(prodcuts: provider.filteredProducts)
              : (provider.products.isNotEmpty
                  ? const ProductsList(prodcuts: [])
                  : const SizedBox()),
        ),
      );
    }
  }

  Widget _buildFilterDropdown(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductFilter>(
          hint: const Text('Filter Products'),
          icon: const Icon(Icons.filter_list, color: Colors.blue),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(
              value: ProductFilter.all,
              child: Text('All Products'),
            ),
            DropdownMenuItem(
              value: ProductFilter.inStock,
              child: Text('In Stock'),
            ),
            DropdownMenuItem(
              value: ProductFilter.outOfStock,
              child: Text('Out of Stock'),
            ),
            DropdownMenuItem(
              value: ProductFilter.fromUser,
              child: Text('From User'),
            ),
          ],
          onChanged: (value) => provider.searchProducts(value?.name ?? ''),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
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
}
