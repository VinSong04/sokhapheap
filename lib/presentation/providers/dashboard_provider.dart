import 'package:flutter/foundation.dart';
import '../../data/models/daily_stats.dart';
import '../../data/repositories/activity_repository.dart';
import '../../core/constants/app_constants.dart';

class DashboardProvider extends ChangeNotifier {
  final ActivityRepository _repository;

  DailyStats _todayStats = DailyStats(date: DateTime.now());
  List<DailyStats> _weeklyStats = [];
  bool _isLoading = false;

  DashboardProvider({ActivityRepository? repository})
      : _repository = repository ?? ActivityRepository() {
    loadData();
  }

  DailyStats get todayStats => _todayStats;
  List<DailyStats> get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;

  double get stepProgress => _todayStats.steps / AppConstants.dailyStepGoal;
  double get distanceProgress =>
      _todayStats.distanceKm / AppConstants.dailyDistanceGoalKm;
  double get calorieProgress =>
      _todayStats.caloriesBurned / AppConstants.dailyCalorieGoal;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _todayStats = await _repository.getTodayStats();
    _weeklyStats = await _repository.getWeeklyStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadData();
  }
}
