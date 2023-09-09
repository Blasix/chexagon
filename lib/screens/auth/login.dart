import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../consts/colors.dart';
import '../../helper/message_helper.dart';

final _obscureProvider = StateProvider((ref) => true);

Future<void> login(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController) async {
  final isValid = formKey.currentState!.validate();
  FocusScope.of(context).unfocus();
  if (isValid) {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.toLowerCase().trim(),
        password: passwordController.text.trim(),
      )
          .then((value) {
        showSuccesSnackbar(context, 'Login successful!');
        context.go('/');
      });
    } on FirebaseException catch (error) {
      if (context.mounted) showErrorSnackbar(context, error.message);
      return;
    } catch (error) {
      if (context.mounted) showErrorSnackbar(context, error.toString());
      return;
    }
  }
}

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final StateController<bool> obscure = ref.watch(_obscureProvider.notifier);
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
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              onEditingComplete: () =>
                                  passwordFocusNode.requestFocus(),
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
                              onEditingComplete: () async {
                                await login(context, formKey, emailController,
                                    passwordController);
                              },
                              obscureText: isObscure,
                              validator: ValidationBuilder().build(),
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await login(context, formKey, emailController,
                              passwordController);
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.4),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: Text(
                        'Register',
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
