import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:sighttrack/models/User.dart';
import 'package:sighttrack/models/UserSettings.dart';

import 'logging.dart';

class Util {
  Util._();

  static Future<UserSettings?> getUserSettings() async {
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;

      final users = await Amplify.DataStore.query(
        User.classType,
        where: User.ID.eq(userId),
      );

      if (users.isEmpty) {
        return null; // No user found
      }

      final user = users.first;
      final settings = await Amplify.DataStore.query(
        UserSettings.classType,
        where: UserSettings.USERID.eq(user.id),
      );

      return settings.isNotEmpty ? settings.first : null;
    } catch (e) {
      Log.e('Util.getUserSettings(): $e');
      return null;
    }
  }

  static Future<bool> isAdmin() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session is CognitoAuthSession) {
        final idToken = session.userPoolTokensResult.value.idToken.raw;
        final tokenParts = idToken.toString().split('.');
        if (tokenParts.length != 3) {
          Log.e('isAdmin(): Invalid JWT format');
          return false;
        }
        final payload = base64Url.decode(base64Url.normalize(tokenParts[1]));
        final claims = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
        final groups = claims['cognito:groups'] as List<dynamic>?;
        return groups?.contains('Admin') ?? false;
      } else {
        Log.e('Session is not a CognitoAuthSession');
      }
      return false;
    } catch (e) {
      Log.e('Error checking admin status: $e');
      return false;
    }
  }
}
