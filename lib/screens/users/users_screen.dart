import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/enums/user_role.dart';
import 'package:admin_dashboard/models/user/user_model.dart';
import 'package:admin_dashboard/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UsersProvider(),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                AddUserButton()
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(AppCollections.users)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null ||
                      snapshot.data?.docs.isEmpty == true) {
                    return const Center(child: Text('No users found'));
                  }
                  List<UserModel> users = [];
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final user = UserModel.fromJson(data);
                    users.add(user);
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: users[index].photoURL != null
                                ? NetworkImage(users[index].photoURL!)
                                : null,
                            child: users[index].photoURL == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    users[index].name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(),
                                  Text(users[index].email)
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      users[index].status == UserStatus.active
                                          ? Colors.green
                                          : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  users[index].status.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: users[index].role == UserRole.admin
                                      ? Colors.blue
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  users[index].role.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              EditUserButton(user: users[index]),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: Provider.of<UsersProvider>(
                                        context,
                                      ),
                                      child: AlertDialog(
                                        title: const Text('Delete User'),
                                        content: const Text(
                                            'Are you sure you want to delete this user?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final provider =
                                                  context.read<UsersProvider>();
                                              await provider.deleteUser(
                                                context: context,
                                                user: users[index],
                                              );
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDialog extends StatelessWidget {
  const UserDialog({super.key, required this.onSubmitting});
  final VoidCallback onSubmitting;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsersProvider>(context);
    return AlertDialog(
      title: const Text('User Form'),
      content: Form(
        key: provider.formkey,
        child: Column(
          children: [
            CustomTextField(
              controller: provider.nameController,
              labelText: 'Name',
              hintText: 'Enter user name',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: provider.emailController,
              labelText: 'email',
              hintText: 'Enter user email',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: provider.addressController,
              labelText: 'address',
              hintText: 'Enter user address',
            ),
            const SizedBox(height: 8),
            PopupMenuButton<UserRole>(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(provider.userRole.name),
                  trailing: const Icon(Icons.arrow_drop_down),
                ),
              ),
              itemBuilder: (context) => UserRole.values
                  .map(
                    (role) => PopupMenuItem(
                      value: role,
                      child: Text(role.name),
                    ),
                  )
                  .toList(),
              onSelected: (value) => provider.userRole = value,
            ),
            const SizedBox(height: 8),
            PopupMenuButton<UserStatus>(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(provider.userStatus.name),
                  trailing: const Icon(Icons.arrow_drop_down),
                ),
              ),
              itemBuilder: (context) => UserStatus.values
                  .map((role) => PopupMenuItem(
                        value: role,
                        child: Text(role.name),
                      ))
                  .toList(),
              onSelected: (value) => provider.userStatus = value,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onSubmitting,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserButton extends StatelessWidget {
  const AddUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsersProvider>(context, listen: false);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: Provider.of<UsersProvider>(context),
            child: UserDialog(
              onSubmitting: () async {
                await provider.addUser(
                  context,
                );
              },
            ),
          ),
        );
      },
      child: const Text(
        'Add User',
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}

class EditUserButton extends StatelessWidget {
  const EditUserButton({super.key, required this.user});
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () async {
        final provider = Provider.of<UsersProvider>(context, listen: false);
        provider.updateUserData(user);
        await showDialog(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: Provider.of<UsersProvider>(context),
            child: UserDialog(
              onSubmitting: () async {
                await provider.editUser(
                  context: context,
                  oldUser: user,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class UsersProvider extends ChangeNotifier {
  final _firebaseService = FirebaseFirestoreService();
  final formkey = GlobalKey<FormState>();
  final defaultPassword = '123456';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
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
        final id = FirebaseFirestore.instance
            .collection(AppCollections.users)
            .doc()
            .id;
        final user = UserModel(
          id,
          nameController.text,
          emailController.text,
          address: addressController.text,
          role: _userRole,
          status: _userStatus,
        );
        await _firebaseService.addDocumentUsingId(
          collectionId: AppCollections.users,
          documentId: id,
          data: user.toJson(),
        );
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
        role: _userRole,
        status: _userStatus,
      );
      try {
        _firebaseService.updateDocument(
          collectionId: AppCollections.users,
          documentId: oldUser.id,
          data: user.toJson(),
        );
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
