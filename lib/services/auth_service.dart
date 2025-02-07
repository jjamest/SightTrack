import "package:amplify_flutter/amplify_flutter.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";

Future<String?> getAuthToken() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

    // Extract the token safely
    final token = session.userPoolTokensResult.valueOrNull?.idToken.raw;

    if (token == null || !token.contains(".")) {
      print("Error: Invalid auth token format.");
      return null;
    }

    print("Auth Token: $token"); // Debugging to confirm token format
    return token;
  } catch (e) {
    print("Error fetching token: $e");
    return null;
  }
}
