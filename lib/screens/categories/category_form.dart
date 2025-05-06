import 'dart:convert';

import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/screens/categories/category_provier.dart';
import 'package:admin_dashboard/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryForm extends StatefulWidget {
  final CategoryModel? categoryModel;
  final Function() onSubmitted;

  const CategoryForm({
    super.key,
    this.categoryModel,
    required this.onSubmitted,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().initState(widget.categoryModel);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: provider.nameController,
            labelText: 'Category Name',
            hintText: 'Enter category name',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: provider.descriptionController,
            labelText: 'Description',
            hintText: 'Enter Category Description',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await provider.pickImage();
            },
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: 16),
          if (provider.bytes != null || widget.categoryModel?.imageUrl != null)
            Image(
                height: 100,
                image: MemoryImage(
                  provider.bytes ??
                      base64Decode(widget.categoryModel?.imageUrl ?? ''),
                ),
                errorBuilder: (context, error, stackTrace) =>
                    const Text('No image selected'))
          else
            const Text('No image selected'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.isLoading ? null : widget.onSubmitted,
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.categoryModel != null
                        ? 'Update Category'
                        : 'Add Category',
                  ),
          ),
        ],
      ),
    );
  }
}
