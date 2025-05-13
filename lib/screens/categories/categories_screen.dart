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
                      'Categories',
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
                        onPressed: () async =>
                            await provider.showCategoryDialog(
                          context: context,
                          isAdding: true,
                        ),
                        label: 'Add Category',
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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

          const SizedBox(height: 24),

          // Search and filter section
          isSmallScreen
              ? Column(
                  children: [
                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Categories...',
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
                      onChanged: (value) => provider.searchCategory(value),
                    ),
                    const SizedBox(height: 16),

                    // Filter dropdown
                    SizedBox(
                      width: double.infinity,
                      child: _buildFilterDropdown(provider),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Search field
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Categories...',
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
                        onChanged: (value) => provider.searchCategory(value),
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
          if (!isSmallScreen && !provider.isLoading) ...[
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Total Categories',
                  provider.categories.length.toString(),
                  Icons.category,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  'New This Month',
                  _getNewThisMonth(provider.categories),
                  Icons.new_releases,
                  Colors.green,
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

  Widget _buildMainContent(CategoryProvider provider, Size screenSize) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    } else if (provider.filteredCategories.isEmpty &&
        provider.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first category to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    } else if (provider.filteredCategories.isNotEmpty) {
      final isSmallScreen = screenSize.width < 600;
      final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
      final gridCrossAxisCount = isSmallScreen ? 1 : (isMediumScreen ? 2 : 3);

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
          child: CatecoryList(
            categoriess: provider.filteredCategories,
            crossAxisCount: gridCrossAxisCount,
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildFilterDropdown(CategoryProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('Filter Categories'),
          icon: const Icon(Icons.filter_list, color: Colors.blue),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: [
            const DropdownMenuItem(
              value: 'All',
              child: Text('All Categories'),
            ),
            ...provider.categories.map((category) {
              return DropdownMenuItem(
                value: category.name,
                child: Text(category.name),
              );
            }),
          ],
          onChanged: (value) => provider.searchCategory(value ?? 'All'),
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

  String _getNewThisMonth(List<dynamic> categories) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // This will need to be adjusted based on your actual model structure
    final newItems = categories
        .where((cat) =>
            cat.createdAt != null && cat.createdAt.isAfter(startOfMonth))
        .length;

    return newItems.toString();
  }
}
