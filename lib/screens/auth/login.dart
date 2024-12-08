// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sighttrack_app/screens/auth/signup.dart';
// import 'package:sighttrack_app/util/error_message.dart';

// import '../../components/text_field.dart';
// import '../../components/button.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   // Input controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   // Login
//   void onLoginPressed() async {
//     // Check if the widget is still mounted before doing anything async
//     if (!mounted) return;

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Prevent dismissing the dialog by tapping outside
//       builder: (context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );

//     try {
//       // Attempt to sign in with email and password
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       // Wait for the auth state to settle (this ensures we're logged in)
//       await FirebaseAuth.instance
//           .authStateChanges()
//           .firstWhere((user) => user != null);

//       // Check if the widget is still mounted before navigating
//       if (!mounted) return;

//       // Pop the loading dialog once the login is successful
//       Navigator.pop(context);

//       // Instead of manually navigating, let the AuthPage's StreamBuilder handle navigation
//       // Pop back to the AuthPage which will automatically redirect to CustomNavigationBar
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     } catch (e) {
//       // Check if the widget is still mounted before doing anything with context
//       if (!mounted) return;

//       // Pop the loading dialog if login fails
//       Navigator.pop(context);

//       // Show error message using a Snackbar only if there was an error
//       String errorMessage = 'Login failed. Please try again.';
//       if (e is FirebaseAuthException) {
//         // Handle specific error cases
//         switch (e.code) {
//           case 'user-not-found':
//             errorMessage = 'No user found for that email.';
//             break;
//           case 'wrong-password':
//             errorMessage = 'Incorrect password provided.';
//             break;
//           case 'invalid-email':
//             errorMessage = 'The email address is not valid.';
//             break;
//           default:
//             errorMessage = 'Something went wrong. Please try again.';
//         }
//       }

//       // Show the error message using a Snackbar only if there was an error
//       showErrorMessage(context, errorMessage);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context); // Navigate back to StartPage
//             },
//           ),
//           backgroundColor: Colors.transparent,
//         ),
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 50),
//                   const Icon(Icons.lock, size: 100),
//                   const SizedBox(height: 50),
//                   Text(
//                     'Login to your account',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 25),
//                   CustomTextField(
//                       controller: emailController,
//                       hintText: 'Email',
//                       obscureText: false),
//                   const SizedBox(height: 25),
//                   CustomTextField(
//                       controller: passwordController,
//                       hintText: 'Password',
//                       obscureText: true),
//                   const SizedBox(height: 15),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 25),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Forgot Password?',
//                           style: TextStyle(color: Colors.teal[600]),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   CustomButton(
//                     onTap: onLoginPressed,
//                     label: 'Login',
//                   ),
//                   const SizedBox(height: 50),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('Not a member?',
//                           style: TextStyle(
//                             color: Colors.grey[700],
//                           )),
//                       const SizedBox(width: 4),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const SignUpScreen()));
//                         },
//                         child: const Text('Sign up now',
//                             style: TextStyle(
//                               color: Colors.blue,
//                               fontWeight: FontWeight.bold,
//                             )),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }
