import "package:flutter/foundation.dart";

class UserState with ChangeNotifier {
  String _username = "";
  String _email = "";
  List<String> _roles = [];

  String get username => _username;
  String get email => _email;
  List<String> get roles => _roles;

  void updateState({String? username, String? email, List<String>? roles}) {
    bool hasChanged = false;

    if (username != null && _username != username) {
      _username = username;
      hasChanged = true;
    }

    if (email != null && _email != email) {
      _email = email;
      hasChanged = true;
    }

    if (roles != null && _roles != roles) {
      _roles = roles;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
    }
  }

  void clear() {
    _username = "";
    _email = "";
    _roles = [];
    notifyListeners();
  }
}
