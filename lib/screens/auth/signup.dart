import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/screens/auth/login.dart';
import 'package:sighttrack_app/navigation_bar.dart';
import 'package:sighttrack_app/util/error_message.dart';

import '../../components/text_field.dart';
import '../../components/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Input controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  // Sign up
  void onSignUpPressed() async {
    // Check if the widget is still mounted before doing anything async
    if (!mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Check both passwords match
      // Attempt to sign in with email and password
      if (passwordController.text == passwordConfirmController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // Passwords don't match
        Navigator.pop(context);
        showErrorMessage(context, 'Passwords don\'t match');
      }

      // Wait for the auth state to settle (this ensures we're logged in)
      await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user != null);

      // Check if the widget is still mounted before navigating
      if (!mounted) return;

      // Pop the loading dialog once the login is successful
      Navigator.pop(context);

      // Remove all routes and push the HomeScreen as the only route
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomNavigationBar()),
        (route) => false, // This ensures all previous routes are removed
      );
    } catch (e) {
      // Check if the widget is still mounted before doing anything with context
      if (!mounted) return;

      // Pop the loading dialog if login fails
      Navigator.pop(context);

      // Show error message using a Snackbar only if there was an error
      String errorMessage = 'Sign up failed. Please try again.';
      if (e is FirebaseAuthException) {
        // Handle specific error cases
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password provided.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'Something went wrong. Please try again.';
        }
      }

      // Show the error message using a Snackbar only if there was an error
      showErrorMessage(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to StartPage
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.lock, size: 100),
                  const SizedBox(height: 50),
                  Text(
                    'Sign up for an account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 25),
                  CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),
                  const SizedBox(height: 15),
                  CustomTextField(
                      controller: passwordConfirmController,
                      hintText: 'Confirm Password',
                      obscureText: true),
                  const SizedBox(height: 25),
                  CustomButton(onTap: onSignUpPressed, label: 'Sign Up'),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already a member?',
                          style: TextStyle(
                            color: Colors.grey[700],
                          )),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: const Text('Login instead',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
