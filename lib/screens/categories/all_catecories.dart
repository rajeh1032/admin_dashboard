import 'dart:convert';

import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/screens/categories/category_provier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatecoryList extends StatelessWidget {
  const CatecoryList({super.key, required this.categoriess});
  final List<CategoryModel> categoriess;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    if (provider.filteredCategories.isEmpty) {
      return const Center(
        child: Text(
          'No categories found. Add your first category!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    final categories = provider.filteredCategories;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (categories[index].imageUrl.isNotEmpty)
                Image.memory(
                  base64Decode(categories[index].imageUrl),
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 60);
                  },
                )
              else
                const Icon(Icons.category, size: 60),
              const SizedBox(height: 8),
              Text(
                categories[index].name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                categories[index].description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await provider.showCategoryDialog(
                        context: context,
                        isAdding: false,
                        categoryModel: categories[index],
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await provider.showDeleteDialog(
                        context,
                        categories[index].id,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
