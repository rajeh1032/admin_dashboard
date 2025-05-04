import 'dart:convert';

import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/screens/products/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key, required this.prodcuts});
  final List<ProductModel> prodcuts;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    if (prodcuts.isEmpty) {
      return const Center(
        child: Text(
          'No products found. Add your first product!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: prodcuts.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prodcuts[index].imageUrl.isNotEmpty)
                  Image.memory(
                    base64Decode(prodcuts[index].imageUrl),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.1,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 60);
                    },
                  )
                else
                  const Icon(Icons.category, size: 60),
                const SizedBox(height: 16),
                Text(
                  prodcuts[index].name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  prodcuts[index].description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await provider.showProductDialog(
                          context: context,
                          isAdding: false,
                          productModel: prodcuts[index],
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await provider.showDeleteDialog(
                          context,
                          prodcuts[index].id,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
