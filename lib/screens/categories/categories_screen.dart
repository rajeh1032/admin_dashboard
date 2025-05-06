import 'package:admin_dashboard/screens/categories/all_catecories.dart';
import 'package:admin_dashboard/screens/categories/category_provier.dart';
import 'package:admin_dashboard/widgets/add_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProvider()..fetchCategories(),
      child: const CategoriesDashboard(),
    );
  }
}

class CategoriesDashboard extends StatelessWidget {
  const CategoriesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
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
                    'Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AddItemButton(
                    onPressed: () async => await provider.showCategoryDialog(
                      context: context,
                      isAdding: true,
                    ),
                    label: 'Add Category',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Categories...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => provider.searchCategory(value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton<String>(
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
                    onSelected: (value) => provider.searchCategory(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'All',
                        child: Text('All Categories'),
                      ),
                      ...provider.categories.map((category) {
                        return PopupMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (provider.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.filteredCategories.isEmpty &&
                  provider.categories.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No categories found. Add your first category!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else if (provider.filteredCategories.isNotEmpty)
                Expanded(
                  child: CatecoryList(
                    categoriess: provider.filteredCategories,
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
