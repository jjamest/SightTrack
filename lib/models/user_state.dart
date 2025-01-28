import "package:flutter/foundation.dart";

class UserState with ChangeNotifier {
  String _username = "";
  String _email = "";
  List<String> _roles = [];

  String get username => _username;
  String get email => _email;
  List<String> get roles => _roles;

  void setUsername(String newUsername) {
    if (_username != newUsername) {
      _username = newUsername;
      notifyListeners();
    }
  }

  void setEmail(String newEmail) {
    if (_email != newEmail) {
      _email = newEmail;
      notifyListeners();
    }
  }

  void setRoles(List<String> newRoles) {
    if (_roles != newRoles) {
      _roles = newRoles;
      notifyListeners();
    }
  }

  void clear() {
    _username = "";
    _email = "";
    _roles = [];
    notifyListeners(); // Notify widgets that the state has changed
  }
}
