import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/firebase_service.dart';

class ProductForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? productId;

  const ProductForm({
    super.key,
    this.initialData,
    this.productId,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _firebaseService = FirebaseService();
  Uint8List? _imageBytes;
  final _imagePicker = ImagePicker();
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'];
      _descriptionController.text = widget.initialData!['description'];
      _priceController.text = widget.initialData!['price'].toString();
      _selectedCategoryId = widget.initialData!['categoryId'];
    }
  }

  Future<void> _loadCategories() async {
    _firebaseService.getCategories().listen((snapshot) {
      setState(() {
        _categories = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
          };
        }).toList();
      });
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }
      print('Submitting product: ${_nameController.text}');
      await _firebaseService.addProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId!,
        imageBytes: _imageBytes!,
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
                  value: category['id'] as String,
                  child: Text(category['name'] as String),
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
            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                height: 100,
              )
            else if (widget.initialData?['imageUrl'] != null)
              Image.network(
                widget.initialData!['imageUrl'],
                height: 100,
              )
            else
              const Text('No image selected'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                  widget.productId != null ? 'Update Product' : 'Add Product'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Button pressed!');
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
