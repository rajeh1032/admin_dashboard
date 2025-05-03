import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/widgets/category_form.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestoreService firebaseService = FirebaseFirestoreService();
  bool isLoading = false;

  void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: SizedBox(
          width: 400,
          child: CategoryForm(
            onSubmitting: (isSubmitting) {
              isLoading = isSubmitting;
              notifyListeners();
            },
            onSuccess: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Category added successfully!'),
                backgroundColor: Colors.green,
              ));
            },
          ),
        ),
      ),
    );
  }

  void setState(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }
}
