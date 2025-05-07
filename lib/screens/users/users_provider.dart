import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/enums/user_role.dart';
import 'package:admin_dashboard/enums/user_status.dart';
import 'package:admin_dashboard/models/user/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
  final _firebaseService = FirebaseFirestoreService();
  final formkey = GlobalKey<FormState>();
  final defaultPassword = '123456';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final List<UserModel> _users = [];
  UserRole _userRole = UserRole.user;
  UserStatus _userStatus = UserStatus.active;
  UserRole get userRole => _userRole;
  UserStatus get userStatus => _userStatus;
  set userRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  set userStatus(UserStatus status) {
    _userStatus = status;
    notifyListeners();
  }

  void updateUserData(UserModel user) {
    nameController.text = user.name;
    emailController.text = user.email;
    addressController.text = user.address;
    _userRole = user.role;
    _userStatus = user.status;
    phoneNumberController.text = user.phoneNumber;
    notifyListeners();
  }

  void resetForm() {
    nameController.clear();
    emailController.clear();
    addressController.clear();
    phoneNumberController.clear();
    _userRole = UserRole.user;
    _userStatus = UserStatus.active;
    notifyListeners();
  }

  List<UserModel> get users => _users;
  Future<void> addUser(BuildContext context) async {
    if (formkey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: defaultPassword,
        );
        credential.user?.updateDisplayName(nameController.text);
        credential.user?.sendEmailVerification();
        final user = UserModel(
          credential.user?.uid ?? '',
          nameController.text,
          emailController.text,
          address: addressController.text,
          phoneNumber: phoneNumberController.text,
          role: _userRole,
          status: _userStatus,
        );
        await _firebaseService.addDocumentUsingId(
          collectionId: AppCollections.users,
          documentId: user.email,
          data: user.toJson(),
        );
        resetForm();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> editUser(
      {required BuildContext context, required UserModel oldUser}) async {
    if (formkey.currentState!.validate()) {
      final user = UserModel(
        oldUser.id,
        nameController.text,
        emailController.text,
        address: addressController.text,
        phoneNumber: oldUser.phoneNumber,
        role: _userRole,
        status: _userStatus,
      );
      try {
        await _firebaseService.updateDocument(
          collectionId: AppCollections.users,
          documentId: oldUser.email,
          data: user.toJson(),
        );
        resetForm();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User Updated Successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> deleteUser(
      {required BuildContext context, required UserModel user}) async {
    try {
      user.status = UserStatus.blocked;
      await _firebaseService.updateDocument(
        collectionId: AppCollections.users,
        documentId: user.id,
        data: user.toJson(),
      );
      // await _firebaseService.deleteDocument(
      //   collectionId: AppCollections.users,
      //   documentId: user.id,
      // );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }
}
