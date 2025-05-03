import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/core/utils/services/firebase_storage_service.dart';
import 'package:admin_dashboard/core/utils/services/image_picker_service.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

class CategoryForm extends StatefulWidget {
  final CategoryModel? categoryModel;
  final Function(bool)? onSubmitting;
  final VoidCallback? onSuccess;

  const CategoryForm({
    super.key,
    this.categoryModel,
    this.onSubmitting,
    this.onSuccess,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firebaseService = FirebaseFirestoreService();
  final _imagePicker = ImagePickerService();
  final _firebaseStorage = FirebaseStorageService();
  File? image;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryModel != null) {
      _nameController.text = widget.categoryModel?.name ?? '';
      _descriptionController.text = widget.categoryModel?.description ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      if (widget.onSubmitting != null) {
        widget.onSubmitting!(true);
      }

      try {
        final String imageUrl = await _firebaseStorage.uploadFile(
          file: image ?? File(''), // Use the selected image or an empty file
        );
        final categoryId = FirebaseFirestore.instance
            .collection(AppCollections.categories)
            .doc()
            .id;

        final CategoryModel categoryModel = CategoryModel(
          _nameController.text,
          _descriptionController.text,
          imageUrl,
          categoryId,
          DateTime.now(),
        );
        await _firebaseService.addDocument(
          collectionId: AppCollections.categories,
          data: categoryModel.toJson(),
        );
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (widget.onSubmitting != null) {
            widget.onSubmitting!(false);
          }

          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.categoryModel != null
                      ? 'Category updated successfully'
                      : 'Category added successfully',
                ),
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (widget.onSubmitting != null) {
            widget.onSubmitting!(false);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a category name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_isSubmitting) return;
              setState(() async {
                image = await _imagePicker.pickImageFromGallery();
              });
            },
            child: const Text('Pick Image'),
          ),
          if (image != null)
            Image.file(
              image!,
              height: 100,
            )
          else if (widget.categoryModel?.imageUrl != null)
            Image.network(
              widget.categoryModel!.imageUrl,
              height: 100,
            )
          else
            const Text('No image selected'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.categoryModel != null
                    ? 'Update Category'
                    : 'Add Category'),
          ),
        ],
      ),
    );
  }
}
