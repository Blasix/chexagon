import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../consts/colors.dart';
import '../../helper/message_helper.dart';

final _obscureProvider = StateProvider((ref) => true);

Future<void> register(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController) async {
  final isValid = formKey.currentState!.validate();
  FocusScope.of(context).unfocus();
  if (isValid) {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.toLowerCase().trim(),
              password: passwordController.text.trim());
      final user = userCredential.user;
      final uid = user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'id': uid,
        'username': nameController.text,
        'email': emailController.text,
        'pfpUrl': '',
        'createdAt': Timestamp.now(),
      });
      showSuccesSnackbar(context, 'Succesfully registered!');
      context.go('/');
    } on FirebaseException catch (error) {
      showErrorSnackbar(context, error.message);
      return;
    } catch (error) {
      showErrorSnackbar(context, error.toString());
      return;
    }
  }
}

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    StateController<bool> obscure = ref.watch(_obscureProvider.notifier);
    final isObscure = ref.watch(_obscureProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                width: 400,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/chexagon_logo.png'),
                      const Text(
                        'Chexagon',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              onEditingComplete: () =>
                                  emailFocusNode.requestFocus(),
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                hintText: 'Name',
                              ),
                              validator: ValidationBuilder().build(),
                            ),
                            TextFormField(
                              controller: emailController,
                              focusNode: emailFocusNode,
                              onEditingComplete: () =>
                                  passwordFocusNode.requestFocus(),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                              ),
                              validator: ValidationBuilder()
                                  .email()
                                  .maxLength(50)
                                  .build(),
                            ),
                            TextFormField(
                              controller: passwordController,
                              focusNode: passwordFocusNode,
                              onEditingComplete: () =>
                                  confirmPasswordFocusNode.requestFocus(),
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    obscure.state = !obscure.state;
                                  },
                                  icon: isObscure
                                      ? const Icon(Icons.visibility,
                                          color: Colors.grey)
                                      : const Icon(Icons.visibility_off,
                                          color: Colors.grey),
                                ),
                              ),
                              validator: ValidationBuilder()
                                  .minLength(6)
                                  .maxLength(20)
                                  .regExp(RegExp('(?=.*?[A-Z])'),
                                      'Must contain at least one uppercase letter')
                                  .regExp(RegExp('(?=.*?[0-9])'),
                                      'Must contain at least one number')
                                  .build(),
                            ),
                            TextFormField(
                              controller: confirmPasswordController,
                              focusNode: confirmPasswordFocusNode,
                              onEditingComplete: () async {
                                await register(
                                    context,
                                    formKey,
                                    nameController,
                                    emailController,
                                    passwordController,
                                    confirmPasswordController);
                              },
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    obscure.state = !obscure.state;
                                  },
                                  icon: isObscure
                                      ? const Icon(Icons.visibility,
                                          color: Colors.grey)
                                      : const Icon(Icons.visibility_off,
                                          color: Colors.grey),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'The field is required';
                                }
                                if (confirmPasswordController.text !=
                                    passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await register(
                              context,
                              formKey,
                              nameController,
                              emailController,
                              passwordController,
                              confirmPasswordController);
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.4),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        'Login',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.blue[800]!.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
