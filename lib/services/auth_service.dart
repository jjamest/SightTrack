import "package:amplify_flutter/amplify_flutter.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:sighttrack_app/logging.dart";

Future<String?> getAuthToken() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

    // Extract the token safely
    final token = session.userPoolTokensResult.valueOrNull?.idToken.raw;

    if (token == null || !token.contains(".")) {
      Log.e("Error: Invalid auth token format.");
      return null;
    }

    return token;
  } catch (e) {
    Log.e("Error fetching token: $e");
    return null;
  }
}
