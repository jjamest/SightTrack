import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Amplify.Auth.signOut();
        },
        child: Text("hi"));
  }
}
