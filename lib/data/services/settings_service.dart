import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _stepGoalKey = 'step_goal';
  static const String _distanceGoalKey = 'distance_goal_km';
  static const String _calorieGoalKey = 'calorie_goal';
  static const String _weightKey = 'user_weight_kg';
  static const String _heightKey = 'user_height_cm';
  static const String _healthKitEnabledKey = 'healthkit_enabled';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _useMetricKey = 'use_metric';

  // Defaults
  static const int defaultStepGoal = 10000;
  static const double defaultDistanceGoalKm = 8.0;
  static const double defaultCalorieGoal = 500.0;
  static const double defaultWeight = 70.0;
  static const double defaultHeight = 170.0;

  Future<int> getStepGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_stepGoalKey) ?? defaultStepGoal;
  }

  Future<void> setStepGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepGoalKey, goal);
  }

  Future<double> getDistanceGoalKm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_distanceGoalKey) ?? defaultDistanceGoalKm;
  }

  Future<void> setDistanceGoalKm(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_distanceGoalKey, goal);
  }

  Future<double> getCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_calorieGoalKey) ?? defaultCalorieGoal;
  }

  Future<void> setCalorieGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_calorieGoalKey, goal);
  }

  Future<double> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_weightKey) ?? defaultWeight;
  }

  Future<void> setWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_weightKey, weight);
  }

  Future<double> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_heightKey) ?? defaultHeight;
  }

  Future<void> setHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_heightKey, height);
  }

  Future<bool> isHealthKitEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_healthKitEnabledKey) ?? false;
  }

  Future<void> setHealthKitEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_healthKitEnabledKey, enabled);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> useMetric() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useMetricKey) ?? true;
  }

  Future<void> setUseMetric(bool metric) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useMetricKey, metric);
  }
}
