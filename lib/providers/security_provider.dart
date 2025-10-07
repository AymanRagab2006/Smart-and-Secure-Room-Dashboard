import 'package:flutter/material.dart';
import '../models/unauthorized_person.dart';

class SecurityProvider extends ChangeNotifier {
  //bool _securityEnabled = true;
  UnauthorizedPerson? _pendingPerson;
  List<UnauthorizedPerson> _unauthorizedHistory = [];

  //bool get securityEnabled => _securityEnabled;
  UnauthorizedPerson? get pendingPerson => _pendingPerson;
  List<UnauthorizedPerson> get unauthorizedHistory => _unauthorizedHistory;

  /*void toggleSecurity() {
    _securityEnabled = !_securityEnabled;
    notifyListeners();
  }*/

  void addUnauthorizedPerson(UnauthorizedPerson person) {
    _pendingPerson = person;
    _unauthorizedHistory.add(person);
    notifyListeners();
  }

  void clearPendingPerson() {
    _pendingPerson = null;
    notifyListeners();
  }

  List<AccessLog> _accessLogs = [];

  List<AccessLog> get accessLogs => _accessLogs;

  void addAccessLog(String personId, bool allowed) {
    _accessLogs.add(AccessLog(
      personId: personId,
      allowed: allowed,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}

class AccessLog {
  final String personId;
  final bool allowed;
  final DateTime timestamp;

  AccessLog({
    required this.personId,
    required this.allowed,
    required this.timestamp,
  });

}