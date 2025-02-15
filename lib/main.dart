import "package:amplify_api/amplify_api.dart";
import "package:amplify_authenticator/amplify_authenticator.dart";
import "package:amplify_datastore/amplify_datastore.dart";
import "package:flutter/material.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/amplify_outputs.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/ModelProvider.dart";
import "package:sighttrack_app/models/settings_state.dart";
import "package:sighttrack_app/navigation_bar.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/services/user_service.dart";

void main() async {
  try {
    Log.init();

    WidgetsFlutterBinding.ensureInitialized();
    await configureAmplify();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserState()),
          ChangeNotifierProvider(create: (_) => SettingsState()),
        ],
        child: const App(),
      ),
    );
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> configureAmplify() async {
  try {
    final authPlugin = AmplifyAuthCognito();
    final apiPlugin = AmplifyAPI();
    final dataStorePlugin =
        AmplifyDataStore(modelProvider: ModelProvider.instance);

    Amplify.addPlugins([dataStorePlugin, authPlugin, apiPlugin]);
    await Amplify.configure(amplifyConfig);

    // Start DataStore to register the model provider for GraphQL operations.
    await Amplify.DataStore.start().then((_) {
      Log.i("DataStore started successfully");
    }).catchError((e) {
      Log.e("Error starting DataStore: $e");
    });
  } on Exception catch (e) {
    Log.e("Error configuring Amplify: $e");
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    setupAuthHubListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      signUpForm: SignUpForm.custom(
        fields: [
          SignUpFormField.username(),
          SignUpFormField.email(required: true),
          SignUpFormField.password(),
          SignUpFormField.passwordConfirmation(),
        ],
      ),
      child: MaterialApp(
        builder: Authenticator.builder(),
        title: "SightTrack",
        home: CustomNavigationBar(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void setupAuthHubListener(BuildContext context) {
  Amplify.Hub.listen(HubChannel.Auth, (HubEvent event) {
    switch (event.eventName) {
      case "SIGNED_IN":
        Log.i("User signed in.");
        updateAll(context);
        break;

      case "SIGNED_OUT":
        Log.i("User signed out. Clearing user state.");
        Provider.of<UserState>(context, listen: false).clear();
        break;

      case "SESSION_EXPIRED":
        Log.w("User session expired.");
        break;

      default:
        Log.d("Auth event: ${event.eventName}");
    }
  });
}
