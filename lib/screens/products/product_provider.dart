import 'dart:convert';

import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/core/utils/services/image_picker_service.dart';
import 'package:admin_dashboard/enums/product_status.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/screens/products/product_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestoreService firebaseService = FirebaseFirestoreService();
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final imagePicker = ImagePickerService();
  String? selectedCategoryId;
  List<CategoryModel> categories = [];
  XFile? image;
  Uint8List? bytes;
  List<ProductModel> filteredProducts = [];
  List<ProductModel> products = [];
  void searchProducts(String query) {
    if (query == "all") {
      filteredProducts = products;
      notifyListeners();
      return;
    }
    if (query.isNotEmpty) {
      filteredProducts = products
          .where((element) =>
              element.status.name.toLowerCase().contains(query.toLowerCase()) ||
              element.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredProducts = products; // Reset to original list if query is empty
    }
    notifyListeners();
  }

  Future<void> getCategories() async {
    try {
      final reposnse = await firebaseService.getCollection(
        collectionId: AppCollections.categories,
      );
      categories = reposnse
          .map(
            (doc) => CategoryModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> addProduct(BuildContext context) async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (formKey.currentState!.validate()) {
      try {
        setState(true);
        String? imageUrl;
        if (image != null) {
          imageUrl = base64Encode(bytes!);
        }
        final id = FirebaseFirestore.instance
            .collection(AppCollections.products)
            .doc()
            .id;
        final product = ProductModel(
          id: id,
          name: nameController.text,
          description: descriptionController.text,
          imageUrl: imageUrl ?? '',
          price: double.tryParse(priceController.text) ?? 0.0,
          quantity: int.tryParse(quantityController.text) ?? 0,
          status: ProductStatus.inStock,
          createdAt: DateTime.now(),
          categoryID: selectedCategoryId ?? '',
        );
        await firebaseService.addDocumentUsingId(
          collectionId: AppCollections.products,
          data: product.toJson(),
          documentId: id,
        );
        resetForm();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product Added Successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    selectedCategoryId = null;
    filteredProducts = [];
    image = null;
    bytes = null;
    setState(false);
  }

  Future<void> editProduct({
    required BuildContext context,
    required ProductModel oldProduct,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        setState(true);
        String? imageUrl;
        if (bytes != null) {
          imageUrl = base64Encode(bytes!);
        }
        final categoryModel = ProductModel(
          id: oldProduct.id,
          name: nameController.text,
          description: descriptionController.text,
          imageUrl: imageUrl ?? oldProduct.imageUrl,
          price: double.tryParse(priceController.text) ?? 0.0,
          quantity: int.tryParse(quantityController.text) ?? 0,
          status: oldProduct.status,
          createdAt: DateTime.now(),
          categoryID: oldProduct.categoryID,
        );
        await firebaseService.updateDocument(
          collectionId: AppCollections.products,
          documentId: oldProduct.id,
          data: categoryModel.toJson(),
        );
        resetForm();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category Updated Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> showProductDialog({
    required BuildContext context,
    required bool isAdding,
    ProductModel? productModel,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: this,
        child: AlertDialog(
          title: Row(
            children: [
              Text(isAdding ? 'Add New Product' : 'Edit Product'),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              )
            ],
          ),
          content: SizedBox(
            width: 400,
            child: ProductForm(
              productModel: productModel,
              onSubmitted: () {
                isAdding
                    ? addProduct(context)
                    : editProduct(
                        context: context,
                        oldProduct: productModel!,
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteProduct(
      {required BuildContext context, required CategoryModel category}) async {
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: this,
        child: AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(true);
                try {
                  await firebaseService.deleteDocument(
                      collectionId: AppCollections.products,
                      documentId: category.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void setState(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  Future<void> pickImage() async {
    image = await imagePicker.pickImageFromGallery();
    if (image != null) {
      bytes = await image!.readAsBytes();
    }
    notifyListeners();
  }

  void initState(ProductModel? categoryModel) {
    if (categoryModel != null) {
      nameController.text = categoryModel.name;
      descriptionController.text = categoryModel.description;
      priceController.text = categoryModel.price.toString();
      selectedCategoryId = categoryModel.categoryID;
      quantityController.text = categoryModel.quantity.toString();
      bytes = null;
    }
  }

  Future<void> showDeleteDialog(BuildContext context, String categoryId) async {
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: this,
        child: AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await firebaseService.deleteDocument(
                      collectionId: AppCollections.products,
                      documentId: categoryId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('product deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }
}
