import 'dart:convert';

import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/screens/products/product_provider.dart';
import 'package:admin_dashboard/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    this.productModel,
    required this.onSubmitted,
  });
  final ProductModel? productModel;
  final VoidCallback onSubmitted;
  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().initState(widget.productModel);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  icon: Row(
                    children: [
                      Text(
                        provider.selectedCategoryId == null
                            ? 'Select Category'
                            : provider.categories
                                .firstWhere(
                                  (element) =>
                                      element.id == provider.selectedCategoryId,
                                  orElse: () => CategoryModel(
                                    '-1',
                                    '',
                                    '',
                                    '',
                                    DateTime.now(),
                                  ),
                                )
                                .name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  itemBuilder: (context) => provider.categories.map((category) {
                    return PopupMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onSelected: (value) {
                    provider.selectedCategoryId = value;
                    provider.setState(false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: provider.nameController,
            labelText: 'Product Name',
            hintText: 'Enter Product Name',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: provider.descriptionController,
            hintText: 'Enter Description',
            labelText: 'Description',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: provider.priceController,
            hintText: 'Enter Price',
            labelText: 'Price',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: provider.quantityController,
            hintText: 'Enter Quantity',
            labelText: 'Quantity',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.pickImage,
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: 16),
          if (context.watch<ProductProvider>().bytes != null ||
              widget.productModel?.imageUrl != null)
            Image.memory(
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Text('No image selected');
              },
              context.watch<ProductProvider>().bytes ??
                  base64Decode(widget.productModel?.imageUrl ?? ''),
            )
          else
            const Text('No image selected'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.isLoading ? null : widget.onSubmitted,
            child: Text(
              widget.productModel != null ? 'Update Product' : 'Add Product',
            ),
          ),
        ],
      ),
    );
  }
}
