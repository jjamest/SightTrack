import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sighttrack_app/screens/auth/auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SightTrack',
      home: AuthPage(),
    );
  }
}
