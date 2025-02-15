import "package:flutter/foundation.dart";

class UserState with ChangeNotifier {
  String _username = "";
  String _email = "";
  List<String> _roles = [];

  // Getters for existing fields
  String get username => _username;
  String get email => _email;
  List<String> get roles => _roles;

  // Update state for multiple fields at once (including the new setting)
  void updateState({
    String? username,
    String? email,
    List<String>? roles,
  }) {
    bool hasChanged = false;

    if (username != null && _username != username) {
      _username = username;
      hasChanged = true;
    }

    if (email != null && _email != email) {
      _email = email;
      hasChanged = true;
    }

    if (roles != null && _roles.toString() != roles.toString()) {
      _roles = roles;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
    }
  }

  // Clear all state values (including the new setting)
  void clear() {
    _username = "";
    _email = "";
    _roles = [];
    notifyListeners();
  }
}
