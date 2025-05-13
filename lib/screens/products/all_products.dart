import 'dart:convert';

import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/screens/products/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key, required this.prodcuts});
  final List<ProductModel> prodcuts;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;

    if (prodcuts.isEmpty) {
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
    }

    final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 4 : 5);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: prodcuts.length,
      itemBuilder: (context, index) {
        final product = prodcuts[index];
        final category = provider.categories.firstWhere(
          (category) => category.id == product.categoryID,
          orElse: () => CategoryModel(
            '-1',
            'Category not found',
            '',
            '',
            DateTime.now(),
          ),
        );

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image and status badge
                Expanded(
                  flex: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image container
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Container(
                          color: Colors.grey[100],
                          child: product.imageUrl.isNotEmpty
                              ? Image.memory(
                                  base64Decode(product.imageUrl),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 40,
                                    color: Colors.blue[300],
                                  ),
                                ),
                        ),
                      ),

                      // Status indicator - smaller badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: product.quantity > 0
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.quantity > 0 ? 'In Stock' : 'Out',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product details section - more compact
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product name
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Price
                        // Category
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Quantity
                            Icon(
                              Icons.inventory_2,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Qty: ${product.quantity}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Description
                        Expanded(
                          child: Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionButton(
                              icon: Icons.edit_outlined,
                              color: Colors.blue,
                              onPressed: () async {
                                await provider.showProductDialog(
                                  context: context,
                                  isAdding: false,
                                  productModel: product,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              color: Colors.red,
                              onPressed: () async {
                                await provider.showDeleteDialog(
                                  context,
                                  product.id,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
        tooltip: icon == Icons.edit_outlined ? 'Edit' : 'Delete',
        constraints: const BoxConstraints(
          minHeight: 32,
          minWidth: 32,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
