import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/widgets.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/user_state.dart";

Future<void> updateUsername(BuildContext context) async {
  try {
    final usernameFuture = Amplify.Auth.getCurrentUser();
    usernameFuture.then((user) {
      if (!context.mounted) return;

      final username = user.username;
      Provider.of<UserState>(context, listen: false).setUsername(username);
      Log.i("Username updated: $username");
    }).catchError((e) {
      Log.e("Error fetching username: $e");
    });
  } catch (e) {
    Log.e("Error updating username: $e");
  }
}

Future<void> updateEmail(BuildContext context) async {
  try {
    final attributesFuture = Amplify.Auth.fetchUserAttributes();
    attributesFuture.then((attributes) {
      if (!context.mounted) return;

      final emailAttribute = attributes.firstWhere(
        (attr) => attr.userAttributeKey == CognitoUserAttributeKey.email,
        orElse: () => throw Exception("Email not found"),
      );

      final email = emailAttribute.value;
      Provider.of<UserState>(context, listen: false).setEmail(email);
      Log.i("Email updated: $email");
    }).catchError((e) {
      Log.e("Error fetching email: $e");
    });
  } catch (e) {
    Log.e("Error updating email: $e");
  }
}

Future<void> updateRoles(BuildContext context) async {
  try {
    AuthSession session = await Amplify.Auth.fetchAuthSession();

    final cognitoSession = session as CognitoAuthSession;
    final userPoolTokens = cognitoSession.userPoolTokensResult.value;
    final idToken = userPoolTokens.idToken.raw;

    final claims = JwtDecoder.decode(idToken);
    final roles = claims["cognito:groups"] ?? [];

    if (!context.mounted) return;
    Provider.of<UserState>(context, listen: false).setRoles(roles);
    Log.i("User roles updated: $roles");
  } catch (e) {
    Log.e("Error fetching user roles: $e");
  }
}
