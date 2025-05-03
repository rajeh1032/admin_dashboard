import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/core/utils/services/firebase_storage_service.dart';
import 'package:admin_dashboard/core/utils/services/image_picker_service.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    this.productModel,
  });
  final ProductModel? productModel;
  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _firebaseService = FirebaseFirestoreService();
  final _firebaseStorage = FirebaseStorageService();
  File? image;
  final _imagePicker = ImagePickerService();
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // if (widget.initialData != null) {
    //   _nameController.text = widget.;
    //   _descriptionController.text = widget.initialData!['description'];
    //   _priceController.text = widget.initialData!['price'].toString();
    //   _selectedCategoryId = widget.initialData!['categoryId'];
    // }
  }

  Future<void> _loadCategories() async {
    _firebaseService.listenToCollection(
      onChange: (doc) {
        setState(() {
          _categories = doc
              .map((e) =>
                  CategoryModel.fromJson(e.data() as Map<String, dynamic>))
              .toList();
        });
      },
      collectionId: AppCollections.categories,
      orderByField: 'createdAt',
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImageFromGallery();
    setState(() {
      image = pickedFile;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }
      String? imageUrl;
      if (image != null) {
        imageUrl = await _firebaseStorage.uploadFile(
          file: image!,
        );
      }
      final productID = FirebaseFirestore.instance
          .collection(AppCollections.products)
          .doc()
          .id;
      final ProductModel productModel = ProductModel(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        id: productID,
        createdAt: DateTime.now(),
        image: imageUrl ?? "",
        categoryID: _categories
            .firstWhere((category) => category.id == _selectedCategoryId!)
            .id,
      );
      await _firebaseService.addDocumentUsingId(
        collectionId: AppCollections.products,
        data: productModel.toJson(),
        documentId: productID,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Form')),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name';
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
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            if (image != null)
              Image.file(
                image!,
                height: 100,
              )
            else if (widget.productModel != null)
              Image.network(
                widget.productModel!.image,
                height: 100,
              )
            else
              const Text('No image selected'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.productModel != null
                  ? 'Update Product'
                  : 'Add Product'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Button works!')),
                );
              },
              child: const Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }
}
