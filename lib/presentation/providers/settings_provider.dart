import 'package:flutter/foundation.dart';
import '../../data/services/settings_service.dart';
import '../../data/services/health_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  final HealthService _healthService;

  int _stepGoal = SettingsService.defaultStepGoal;
  double _distanceGoalKm = SettingsService.defaultDistanceGoalKm;
  double _calorieGoal = SettingsService.defaultCalorieGoal;
  double _weight = SettingsService.defaultWeight;
  double _height = SettingsService.defaultHeight;
  bool _healthKitEnabled = false;
  bool _useMetric = true;
  bool _isLoading = false;

  SettingsProvider({
    SettingsService? settingsService,
    HealthService? healthService,
  })  : _settingsService = settingsService ?? SettingsService(),
        _healthService = healthService ?? HealthService() {
    loadSettings();
  }

  int get stepGoal => _stepGoal;
  double get distanceGoalKm => _distanceGoalKm;
  double get calorieGoal => _calorieGoal;
  double get weight => _weight;
  double get height => _height;
  bool get healthKitEnabled => _healthKitEnabled;
  bool get useMetric => _useMetric;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _stepGoal = await _settingsService.getStepGoal();
    _distanceGoalKm = await _settingsService.getDistanceGoalKm();
    _calorieGoal = await _settingsService.getCalorieGoal();
    _weight = await _settingsService.getWeight();
    _height = await _settingsService.getHeight();
    _healthKitEnabled = await _settingsService.isHealthKitEnabled();
    _useMetric = await _settingsService.useMetric();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStepGoal(int goal) async {
    _stepGoal = goal;
    await _settingsService.setStepGoal(goal);
    notifyListeners();
  }

  Future<void> updateDistanceGoalKm(double goal) async {
    _distanceGoalKm = goal;
    await _settingsService.setDistanceGoalKm(goal);
    notifyListeners();
  }

  Future<void> updateCalorieGoal(double goal) async {
    _calorieGoal = goal;
    await _settingsService.setCalorieGoal(goal);
    notifyListeners();
  }

  Future<void> updateWeight(double weight) async {
    _weight = weight;
    await _settingsService.setWeight(weight);
    notifyListeners();
  }

  Future<void> updateHeight(double height) async {
    _height = height;
    await _settingsService.setHeight(height);
    notifyListeners();
  }

  Future<void> toggleHealthKit(bool enabled) async {
    if (enabled) {
      final granted = await _healthService.requestAllPermissions();
      if (!granted) return;
    }
    _healthKitEnabled = enabled;
    await _settingsService.setHealthKitEnabled(enabled);
    notifyListeners();
  }

  Future<void> toggleUseMetric(bool metric) async {
    _useMetric = metric;
    await _settingsService.setUseMetric(metric);
    notifyListeners();
  }
}
