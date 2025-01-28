import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:sighttrack_app/logging.dart";

Future<List<String>> getUserRoles() async {
  try {
    AuthSession session = await Amplify.Auth.fetchAuthSession();

    final cognitoSession = session as CognitoAuthSession;
    final userPoolTokens = cognitoSession.userPoolTokensResult.value;
    final idToken = userPoolTokens.idToken.raw;

    final claims = JwtDecoder.decode(idToken);
    final roles = claims["cognito:groups"] ?? [];
    return roles;
  } catch (e) {
    Log.e("Error fetching user roles: $e");
  }
  return [];
}
