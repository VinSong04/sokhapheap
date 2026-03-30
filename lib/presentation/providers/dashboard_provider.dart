import 'package:flutter/foundation.dart';
import '../../data/models/daily_stats.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/services/health_service.dart';
import '../../data/services/settings_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ActivityRepository _repository;
  final HealthService _healthService;
  final SettingsService _settingsService;

  DailyStats _todayStats = DailyStats(date: DateTime.now());
  List<DailyStats> _weeklyStats = [];
  bool _isLoading = false;
  double? _heartRate;
  bool _healthKitConnected = false;

  // Goals (loaded from settings)
  int _stepGoal = SettingsService.defaultStepGoal;
  double _distanceGoalKm = SettingsService.defaultDistanceGoalKm;
  double _calorieGoal = SettingsService.defaultCalorieGoal;

  DashboardProvider({
    ActivityRepository? repository,
    HealthService? healthService,
    SettingsService? settingsService,
  })  : _repository = repository ?? ActivityRepository(),
        _healthService = healthService ?? HealthService(),
        _settingsService = settingsService ?? SettingsService() {
    loadData();
  }

  DailyStats get todayStats => _todayStats;
  List<DailyStats> get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;
  double? get heartRate => _heartRate;
  bool get healthKitConnected => _healthKitConnected;
  int get stepGoal => _stepGoal;
  double get distanceGoalKm => _distanceGoalKm;
  double get calorieGoal => _calorieGoal;

  double get stepProgress => _todayStats.steps / _stepGoal;
  double get distanceProgress => _todayStats.distanceKm / _distanceGoalKm;
  double get calorieProgress => _todayStats.caloriesBurned / _calorieGoal;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Load goals from settings
    _stepGoal = await _settingsService.getStepGoal();
    _distanceGoalKm = await _settingsService.getDistanceGoalKm();
    _calorieGoal = await _settingsService.getCalorieGoal();

    // Load local data
    _todayStats = await _repository.getTodayStats();
    _weeklyStats = await _repository.getWeeklyStats();

    // Try to load HealthKit data
    _healthKitConnected = await _settingsService.isHealthKitEnabled();
    if (_healthKitConnected) {
      await _loadHealthKitData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadHealthKitData() async {
    try {
      final hasPerms = await _healthService.hasPermissions();
      if (!hasPerms) {
        _healthKitConnected = false;
        return;
      }

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Get steps from HealthKit
      final healthSteps = await _healthService.getSteps(midnight, now);
      if (healthSteps > _todayStats.steps) {
        _todayStats = _todayStats.copyWith(steps: healthSteps);
      }

      // Get distance from HealthKit
      final healthDistance = await _healthService.getDistance(midnight, now);
      if (healthDistance > _todayStats.distanceMeters) {
        _todayStats = _todayStats.copyWith(distanceMeters: healthDistance);
      }

      // Get calories from HealthKit
      final healthCalories =
          await _healthService.getActiveCalories(midnight, now);
      if (healthCalories > _todayStats.caloriesBurned) {
        _todayStats = _todayStats.copyWith(caloriesBurned: healthCalories);
      }

      // Get latest heart rate
      _heartRate = await _healthService.getLatestHeartRate();
    } catch (e) {
      // Silently fail - HealthKit data is supplementary
    }
  }

  Future<void> refresh() async {
    await loadData();
  }
}
