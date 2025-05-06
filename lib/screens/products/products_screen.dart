import 'package:admin_dashboard/enums/product_status.dart';
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
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => provider.searchProducts(value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton<ProductFilter>(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                    onSelected: (value) => provider.searchProducts(value.name),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ProductFilter.all,
                        child: Text('All Products'),
                      ),
                      const PopupMenuItem(
                        value: ProductFilter.inStock,
                        child: Text('in Stock'),
                      ),
                      const PopupMenuItem(
                        value: ProductFilter.outOfStock,
                        child: Text('Out of Stock'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (provider.isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.filteredProducts.isNotEmpty)
                Expanded(
                  child: ProductsList(
                    prodcuts: provider.filteredProducts,
                  ),
                )
              else if (provider.filteredProducts.isEmpty &&
                  provider.products.isNotEmpty)
                const Expanded(
                  child: ProductsList(
                    prodcuts: [],
                  ),
                )
              // else
              //   Expanded(
              //     child: StreamBuilder<QuerySnapshot>(
              //       stream: FirebaseFirestore.instance
              //           .collection(AppCollections.products)
              //           .snapshots(),
              //       builder: (context, snapshot) {
              //         if (snapshot.hasError) {
              //           return Center(child: Text('Error: ${snapshot.error}'));
              //         }
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return const Center(child: CircularProgressIndicator());
              //         }

              //         List<ProductModel> products = [];
              //         for (var doc in snapshot.data!.docs) {
              //           final data = doc.data() as Map<String, dynamic>;
              //           final product = ProductModel.fromJson(data);
              //           products.add(product);
              //         }
              //         provider.products = products;
              //         return ProductsList(
              //           prodcuts: products,
              //         );
              //       },
              //     ),
              //   ),
            ],
          ),
        ),
      ],
    );
  }
}
