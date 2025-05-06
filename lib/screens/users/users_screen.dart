import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/enums/user_role.dart';
import 'package:admin_dashboard/enums/user_status.dart';
import 'package:admin_dashboard/models/user/user_model.dart';
import 'package:admin_dashboard/screens/users/user_dialog.dart';
import 'package:admin_dashboard/screens/users/users_provider.dart';
import 'package:admin_dashboard/widgets/add_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class AddUserButton extends StatelessWidget {
  const AddUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsersProvider>(context, listen: false);
    return AddItemButton(
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
      label: 'Add User',
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
