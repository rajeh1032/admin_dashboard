import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/enums/user_role.dart';
import 'package:admin_dashboard/models/user/user_model.dart';
import 'package:admin_dashboard/screens/home_screen.dart';
import 'package:admin_dashboard/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width > 1024 ? 300 : 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/top_logo.png'),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  controller: emailController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Password',
                  hintText: 'Enter your Password',
                  controller: passwordController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await login(context);
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    try {
      if (formKey.currentState!.validate()) {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final response = await FirebaseFirestoreService().getDocument(
          collectionId: AppCollections.users,
          documentId: credential.user!.email!,
        );
        final user =
            UserModel.fromJson(response.data() as Map<String, dynamic>);
        if (user.role != UserRole.admin) {
          throw Exception('You are not authorized to access this app');
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong, please try again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
