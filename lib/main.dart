import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'package:sighttrack_app/amplify_outputs.dart';
import 'package:sighttrack_app/navigation_bar.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await configureAmplify();
    runApp(const App());
  } on AmplifyException catch (e) {
    runApp(Text('Error configuring Amplify: ${e.message}'));
  }
}

Future<void> configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      signUpForm: SignUpForm.custom(
        fields: [
          SignUpFormField.username(), // Username field
          SignUpFormField.email(required: true), // Email field
          SignUpFormField.password(),
          SignUpFormField.passwordConfirmation(),
        ],
      ),
      child: MaterialApp(
        builder: Authenticator.builder(),
        title: 'SightTrack',
        home: CustomNavigationBar(),
      ),
    );
  }
}
