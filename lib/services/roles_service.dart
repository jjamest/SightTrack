// import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
// import "package:amplify_flutter/amplify_flutter.dart";
// import "package:jwt_decoder/jwt_decoder.dart";
// import "package:sighttrack_app/logging.dart";

// Future<List<String>> getUserRoles() async {
//   try {
//     Log.i("-1");
//     AuthSession session = await Amplify.Auth.fetchAuthSession();
//     Log.i("0");
//     final cognitoSession = session as CognitoAuthSession;
//     final userPoolTokens = cognitoSession.userPoolTokensResult.value;
//     final idToken = userPoolTokens.idToken.raw;
//     Log.i("1");
//     final claims = JwtDecoder.decode(idToken);
//     Log.i("2");
//     final roles =
//         Future.value(List<String>.from(claims["cognito:groups"] ?? []));

//     final rolesList = await roles;

//     return rolesList;
//   } catch (e) {
//     Log.e("Error fetching user roles: $e");
//   }
//   return [];
// }
