import 'package:flutter/foundation.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';

class ActivityHistoryProvider extends ChangeNotifier {
  final ActivityRepository _repository;

  List<Activity> _activities = [];
  bool _isLoading = false;
  ActivityFilter _currentFilter = ActivityFilter.all;

  ActivityHistoryProvider({ActivityRepository? repository})
      : _repository = repository ?? ActivityRepository() {
    loadActivities();
  }

  List<Activity> get activities => _filteredActivities;
  bool get isLoading => _isLoading;
  ActivityFilter get currentFilter => _currentFilter;

  List<Activity> get _filteredActivities {
    final now = DateTime.now();
    switch (_currentFilter) {
      case ActivityFilter.all:
        return _activities;
      case ActivityFilter.today:
        return _activities
            .where((a) =>
                a.startTime.year == now.year &&
                a.startTime.month == now.month &&
                a.startTime.day == now.day)
            .toList();
      case ActivityFilter.thisWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        return _activities
            .where((a) => a.startTime.isAfter(weekAgo))
            .toList();
      case ActivityFilter.thisMonth:
        return _activities
            .where((a) =>
                a.startTime.year == now.year &&
                a.startTime.month == now.month)
            .toList();
    }
  }

  int get totalActivities => _filteredActivities.length;

  double get totalDistance =>
      _filteredActivities.fold(0, (sum, a) => sum + a.distanceMeters);

  double get totalCalories =>
      _filteredActivities.fold(0, (sum, a) => sum + a.caloriesBurned);

  Duration get totalDuration =>
      _filteredActivities.fold(Duration.zero, (sum, a) => sum + a.duration);

  void setFilter(ActivityFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    _activities = await _repository.getActivityHistory();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadActivities();
  }
}

enum ActivityFilter {
  all,
  today,
  thisWeek,
  thisMonth,
}
