import 'package:admin_dashboard/enums/user_role.dart';
import 'package:admin_dashboard/enums/user_status.dart';
import 'package:admin_dashboard/screens/users/users_provider.dart';
import 'package:admin_dashboard/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDialog extends StatelessWidget {
  const UserDialog({super.key, required this.onSubmitting});
  final VoidCallback onSubmitting;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsersProvider>(context);
    return AlertDialog(
      title: Row(
        children: [
          const Text('User Form'),
          const Spacer(),
          IconButton(
            onPressed: () {
              provider.resetForm();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Form(
        key: provider.formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              controller: provider.phoneNumberController,
              labelText: 'Phone Number',
              hintText: 'Enter user Phone Number',
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
