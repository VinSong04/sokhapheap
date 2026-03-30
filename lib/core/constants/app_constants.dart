class AppConstants {
  AppConstants._();

  static const String appName = 'RunTracker';

  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const double defaultMapZoom = 15.0;
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;

  // Calories calculation constants
  static const double caloriesPerStep = 0.04;
  static const double metersPerStep = 0.762;

  // Activity defaults
  static const int dailyStepGoal = 10000;
  static const double dailyDistanceGoalKm = 8.0;
  static const double dailyCalorieGoal = 500.0;
}
