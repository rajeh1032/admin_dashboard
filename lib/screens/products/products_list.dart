import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/screens/categories/category_provier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppCollections.categories)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<CategoryModel> categories = [];
        if (snapshot.hasData) {
          categories = snapshot.data!.docs
              .map((doc) =>
                  CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        }

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: Image.network(
                category.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(category.name),
              subtitle: Text(category.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        context.read<CategoryProvider>().showCategoryDialog(
                              context: context,
                              isAdding: false,
                              categoryModel: category,
                            ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => context
                        .read<CategoryProvider>()
                        .showDeleteDialog(context, category.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
