import 'dart:convert';

import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/core/utils/services/image_picker_service.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/screens/categories/category_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestoreService firebaseService = FirebaseFirestoreService();
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imagePicker = ImagePickerService();
  XFile? image;
  Uint8List? bytes;
  List<CategoryModel> filteredCategories = [];
  List<CategoryModel> categories = [];
  void searchCategory(String query) {
    if (query == "All") {
      filteredCategories = categories;
      notifyListeners();
      return;
    }
    if (query.isNotEmpty) {
      filteredCategories = categories
          .where((category) =>
              category.description
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredCategories =
          categories; // Reset to original list if query is empty
    }
    notifyListeners();
  }

  Future<void> addCategory(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        setState(true);
        String? imageUrl;
        if (image != null) {
          imageUrl = base64Encode(bytes!);
        }
        final id = FirebaseFirestore.instance
            .collection(AppCollections.categories)
            .doc()
            .id;
        final categoryModel = CategoryModel(
          id,
          nameController.text,
          descriptionController.text,
          imageUrl ?? '',
          DateTime.now(),
        );
        await firebaseService.addDocumentUsingId(
          collectionId: AppCollections.categories,
          data: categoryModel.toJson(),
          documentId: id,
        );
        resetForm();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Category Added Successfully!',
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
    image = null;
    bytes = null;
    filteredCategories = [];
    bytes = null;
    setState(false);
  }

  Future<void> editCategory({
    required BuildContext context,
    required CategoryModel oldCategory,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        setState(true);
        String? imageUrl;
        if (image != null) {
          imageUrl = base64Encode(bytes!);
        }
        final categoryModel = CategoryModel(
          oldCategory.id,
          nameController.text,
          descriptionController.text,
          imageUrl ?? oldCategory.imageUrl,
          DateTime.now(),
        );
        await firebaseService.updateDocument(
          collectionId: AppCollections.categories,
          documentId: oldCategory.id,
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

  Future<void> showCategoryDialog({
    required BuildContext context,
    required bool isAdding,
    CategoryModel? categoryModel,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: this,
        child: AlertDialog(
          title: Row(
            children: [
              Text(isAdding ? 'Add New Category' : 'Edit Category'),
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
            child: CategoryForm(
              categoryModel: categoryModel,
              onSubmitted: () {
                isAdding
                    ? addCategory(context)
                    : editCategory(
                        context: context,
                        oldCategory: categoryModel!,
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteCategory(
      {required BuildContext context, required CategoryModel category}) async {
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: this,
        child: AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this Category?'),
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
                      collectionId: AppCollections.categories,
                      documentId: category.id);
                  if (context.mounted) {
                    resetForm();
                    Navigator.pop(context);
                    setState(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category Deleted Successfully'),
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
      notifyListeners();
    }
  }

  void initState(CategoryModel? categoryModel) {
    if (categoryModel != null) {
      nameController.text = categoryModel.name;
      descriptionController.text = categoryModel.description;
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
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await firebaseService.deleteDocument(
                      collectionId: AppCollections.categories,
                      documentId: categoryId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Category deleted successfully')),
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
    super.dispose();
  }
}
