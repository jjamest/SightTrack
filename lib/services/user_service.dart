import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/widgets.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/user_state.dart";

Future<void> updateAll(BuildContext context) async {
  final userState = Provider.of<UserState>(context, listen: false);

  try {
    final user = await Amplify.Auth.getCurrentUser();
    final attributes = await Amplify.Auth.fetchUserAttributes();
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

    final username = user.username;
    final email = attributes
        .firstWhere(
          (attr) => attr.userAttributeKey == CognitoUserAttributeKey.email,
          orElse: () => throw Exception("Email not found"),
        )
        .value;

    final idToken = session.userPoolTokensResult.value.idToken.raw;
    final claims = JwtDecoder.decode(idToken);
    final roles = List<String>.from(claims["cognito:groups"] ?? []);

    userState.updateState(username: username, email: email, roles: roles);
    Log.i(
      "UserState updated: Username: $username, Email: $email, Roles: ${roles.toString()}",
    );
  } catch (e) {
    Log.e("Error updating user state: $e");
  }
}
