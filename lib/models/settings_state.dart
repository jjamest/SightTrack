import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/foundation.dart";
import "package:sighttrack_app/models/UserSettings.dart";

class SettingsState with ChangeNotifier {
  bool _randomPhotoOffset = false;
  bool get randomPhotoOffset => _randomPhotoOffset;

  SettingsState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final settingsList = await Amplify.DataStore.query(
        UserSettings.classType,
        where: UserSettings.USERID.eq(authUser.userId),
      );
      if (settingsList.isNotEmpty) {
        _randomPhotoOffset = settingsList.first.randomPhotoOffset ?? false;
        notifyListeners();
      }
    } catch (e) {
      // Optionally log or handle errors here.
    }
  }

  void setRandomPhotoOffset(bool value) {
    if (_randomPhotoOffset != value) {
      _randomPhotoOffset = value;
      notifyListeners();
    }
  }
}
