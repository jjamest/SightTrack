// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sighttrack_app/screens/home_start.dart';

// import '../../navigation_bar.dart';

// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           // Logged in
//           if (snapshot.hasData) {
//             return const CustomNavigationBar();
//           } else {
//             return const HomeStart();
//           }
//         },
//       ),
//     );
//   }
// }
