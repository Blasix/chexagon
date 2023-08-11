import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../consts/colors.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

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
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                              ),
                              validator: ValidationBuilder().build(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final isValid = formKey.currentState!.validate();
                          FocusScope.of(context).unfocus();
                          if (isValid) {
                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email:
                                    emailController.text.toLowerCase().trim(),
                                password: passwordController.text.trim(),
                              );
                              context.go('/');
                            } on FirebaseException catch (error) {
                              print(error.message);
                              return;
                            } catch (error) {
                              print(error);
                              return;
                            }
                          }
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
                    'Don\'t have an account?',
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
