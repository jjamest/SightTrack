import "package:amplify_flutter/amplify_flutter.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/UserSettings.dart";

Future<void> updateUserSettings({
  required String userId,
  required bool randomPhotoOffset,
}) async {
  try {
    // Query for an existing settings record for this user.
    final settingsList = await Amplify.DataStore.query(
      UserSettings.classType,
      where: UserSettings.USERID.eq(userId),
    );

    if (settingsList.isNotEmpty) {
      // Update the existing record.
      final existingSettings = settingsList.first;
      final updatedSettings = existingSettings.copyWith(
        randomPhotoOffset: randomPhotoOffset,
      );
      await Amplify.DataStore.save(updatedSettings);
      Log.i("User settings updated successfully (updated record)");
    } else {
      // Create a new record if none exists.
      final newSettings = UserSettings(
        userId: userId,
        randomPhotoOffset: randomPhotoOffset,
      );
      await Amplify.DataStore.save(newSettings);
      Log.i("User settings created successfully");
    }
  } catch (e) {
    Log.e("Error saving settings: $e");
  }
}
