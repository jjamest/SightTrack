import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sighttrack/amplifyconfiguration.dart';
import 'package:sighttrack/logging.dart';
import 'package:sighttrack/models/ModelProvider.dart';
import 'package:sighttrack/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.init();
  MapboxOptions.setAccessToken(
    'pk.eyJ1IjoiamFtZXN0dCIsImEiOiJjbThjOGZ3ZDYxNzdxMm1vbDRma3ZjczN0In0.AN_WIYTiODrQPCNaGtrucA',
  );

  try {
    await Amplify.addPlugins([
      AmplifyDataStore(modelProvider: ModelProvider.instance),
      AmplifyAPI(),
      AmplifyAuthCognito(),
      AmplifyStorageS3(),
    ]);

    await Amplify.configure(amplifyconfig);
    await Amplify.DataStore.clear();
    await Amplify.DataStore.start();

    // Add a global DataStore subscription to debug sync events
    Amplify.DataStore.observe(User.classType).listen((event) {
      Log.i('Global DataStore sync event: ${event.item.toJson()}');
    });

    Amplify.Hub.listen(HubChannel.Auth, (hubEvent) async {
      if (hubEvent.eventName == 'SIGNED_IN') {
        Log.i('User signed in, waiting for DataStore sync...');

        // Wait for the initial sync to complete
        bool isSynced = false;
        final syncSubscription = Amplify.DataStore.observe(
          User.classType,
        ).listen((event) {
          Log.i('Sync received for user: ${event.item.id}');
          isSynced = true;
        });

        // Wait up to 10 seconds for sync to occur
        for (int i = 0; i < 20; i++) {
          if (isSynced) break;
          await Future.delayed(const Duration(milliseconds: 500));
        }
        syncSubscription.cancel();

        final currentUser = await Amplify.Auth.getCurrentUser();
        final userId = currentUser.userId;
        Log.i('Cognito userId: $userId');

        final existingUsers = await Amplify.DataStore.query(
          User.classType,
          where: User.ID.eq(userId),
        );

        if (existingUsers.isEmpty) {
          final attributes = await Amplify.Auth.fetchUserAttributes();
          String email = '';
          for (var attribute in attributes) {
            if (attribute.userAttributeKey.toString().toLowerCase() ==
                'email') {
              email = attribute.value;
              break;
            }
          }

          final newUser = User(
            id: userId,
            display_username: currentUser.username,
            email: email,
            profilePicture: null,
            bio: '',
            country: '',
          );

          await Amplify.DataStore.save(newUser);
          Log.i('New user record created for ${currentUser.username}');
        } else {
          Log.i('User record exists: ${existingUsers.first.toJson()}');
        }
      } else if (hubEvent.eventName == 'SIGNED_OUT') {
        Log.i('User signed out. Clearing DataStore.');
        await Amplify.DataStore.clear();
      }
    });
  } catch (e) {
    Log.e('Error in main(): $e');
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
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.jpg',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to SightTrack',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SignInForm.custom(
                      fields: [
                        SignInFormField.username(),
                        SignInFormField.password(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              () => state.changeStep(AuthenticatorStep.signUp),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () => state.changeStep(
                                AuthenticatorStep.resetPassword,
                              ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state.currentStep == AuthenticatorStep.signUp) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.jpg',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Join SightTrack',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SignUpForm.custom(
                      fields: [
                        SignUpFormField.username(),
                        SignUpFormField.email(required: true),
                        SignUpFormField.password(),
                        SignUpFormField.passwordConfirmation(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          () => state.changeStep(AuthenticatorStep.signIn),
                      child: const Text(
                        'Already have an account? Sign In',
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const Navigation(),
      ),
    );
  }
}
