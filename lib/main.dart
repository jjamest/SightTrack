import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:sighttrack/amplifyconfiguration.dart';
import 'package:sighttrack/logging.dart';
import 'package:sighttrack/models/ModelProvider.dart';
import 'package:sighttrack/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.init();

  try {
    Amplify.addPlugins([
      AmplifyDataStore(modelProvider: ModelProvider.instance),
      AmplifyAPI(),
      AmplifyAuthCognito(),
      AmplifyStorageS3()
    ]).then((_) {
      return Amplify.configure(amplifyconfig);
    });
  } on AmplifyException catch (e) {
    Log.e("Error in main(). Did not configure Amplify: $e");
  } catch (e) {
    Log.e("Error in main(). An unknown error occured: $e");
  }

  runApp(const SightTrackApp());
}

class SightTrackApp extends StatefulWidget {
  const SightTrackApp({super.key});

  @override
  State<SightTrackApp> createState() => _SightTrackAppState();
}

class _SightTrackAppState extends State<SightTrackApp> {
  @override
  Widget build(BuildContext context) {
    return Authenticator(
      authenticatorBuilder: (context, state) {
        if (state.currentStep == AuthenticatorStep.signIn) {
          return Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/icon.jpg',
                    height: 150, width: 150, fit: BoxFit.contain),
                const SizedBox(height: 20),
                const Text("Welcome to SightTrack",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)),
                const SizedBox(height: 24),
                SignInForm.custom(fields: [
                  SignInFormField.username(),
                  SignInFormField.password(),
                ]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          state.changeStep(AuthenticatorStep.signUp),
                      child: const Text("Create Account",
                          style: TextStyle(color: Colors.indigo)),
                    ),
                    TextButton(
                      onPressed: () =>
                          state.changeStep(AuthenticatorStep.resetPassword),
                      child: const Text("Forgot Password?",
                          style: TextStyle(color: Colors.indigo)),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state.currentStep == AuthenticatorStep.signUp) {
          return Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/icon.jpg',
                    height: 150, width: 150, fit: BoxFit.contain),
                const SizedBox(height: 20),
                const Text("Join SightTrack",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)),
                const SizedBox(height: 24),
                SignUpForm.custom(fields: [
                  SignUpFormField.email(required: true),
                  SignUpFormField.preferredUsername(required: true),
                  SignUpFormField.password(),
                  SignUpFormField.passwordConfirmation(),
                ]),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => state.changeStep(AuthenticatorStep.signIn),
                  child: const Text("Already have an account? Sign In",
                      style: TextStyle(color: Colors.indigo)),
                ),
              ],
            ),
          );
        }
        return null;
      },
      child: MaterialApp(
          builder: Authenticator.builder(),
          title: 'SightTrack',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: Colors.grey[100],
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          home: const Navigation()),
    );
  }
}
