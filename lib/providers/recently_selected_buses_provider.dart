import 'package:flutter/material.dart';

class RecentlySelectedBusesProvider with ChangeNotifier {
  final Map<String, int> _recentlySelectedBuses = {};

  Map<String, int> get recentlySelectedBuses => _recentlySelectedBuses;

  void addBus(String busId, int estimatedTime) {
    if (_recentlySelectedBuses.containsKey(busId)) {
      _recentlySelectedBuses.remove(busId);
    }
    _recentlySelectedBuses[busId] = estimatedTime;
    if (_recentlySelectedBuses.length > 3) {
      _recentlySelectedBuses.remove(_recentlySelectedBuses.keys.last);
    }
    notifyListeners();
  }
  int getEstimatedTime(String busId) {
    return _recentlySelectedBuses[busId] ?? 0;
  }
}
