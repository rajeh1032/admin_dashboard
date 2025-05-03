import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/firebase_service.dart';

class CategoryForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? categoryId;
  final Function(bool)? onSubmitting;
  final VoidCallback? onSuccess;

  const CategoryForm({
    super.key,
    this.initialData,
    this.categoryId,
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
  final _firebaseService = FirebaseService();
  Uint8List? _imageBytes;
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'];
      _descriptionController.text = widget.initialData!['description'];
    }
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      if (widget.onSubmitting != null) {
        widget.onSubmitting!(true);
      }

      try {
        if (widget.categoryId != null) {
          await _firebaseService.updateCategory(
            id: widget.categoryId!,
            name: _nameController.text,
            description: _descriptionController.text,
            imageBytes: _imageBytes,
          );
        } else {
          await _firebaseService.addCategory(
            name: _nameController.text,
            description: _descriptionController.text,
            imageBytes: _imageBytes,
          );
        }

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
                  widget.categoryId != null
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
            onPressed: _isSubmitting ? null : _pickImage,
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
                : Text(widget.categoryId != null
                    ? 'Update Category'
                    : 'Add Category'),
          ),
        ],
      ),
    );
  }
}
