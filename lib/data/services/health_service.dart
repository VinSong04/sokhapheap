import 'package:health/health.dart';

/// Service class that wraps the [Health] plugin to request permissions
/// and read Steps / Heart Rate data from Apple HealthKit.
class HealthService {
  final Health _health = Health();

  /// The HealthKit data types this service works with.
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
  ];

  /// Corresponding access permissions (read-only by default).
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  // ------------------------------------------------------------------
  // Permissions
  // ------------------------------------------------------------------

  /// Requests HealthKit authorization for Steps and Heart Rate.
  ///
  /// Returns `true` when the user grants access, `false` otherwise.
  Future<bool> requestPermissions() async {
    try {
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      return granted;
    } catch (e) {
      return false;
    }
  }

  /// Checks whether the app already has HealthKit authorization.
  Future<bool> hasPermissions() async {
    try {
      final granted = await _health.hasPermissions(
        _types,
        permissions: _permissions,
      );
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Steps
  // ------------------------------------------------------------------

  /// Returns the total step count between [start] and [end].
  Future<int> getSteps(DateTime start, DateTime end) async {
    try {
      final stepsCount = await _health.getTotalStepsInInterval(start, end);
      return stepsCount ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Returns today's total step count (midnight → now).
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    return getSteps(midnight, now);
  }

  // ------------------------------------------------------------------
  // Heart Rate
  // ------------------------------------------------------------------

  /// Returns a list of heart-rate data points between [start] and [end].
  Future<List<HealthDataPoint>> getHeartRateData(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );
      return _health.removeDuplicates(data);
    } catch (e) {
      return [];
    }
  }

  /// Returns the latest heart-rate reading recorded in the last hour,
  /// or `null` if none is available.
  Future<double?> getLatestHeartRate() async {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final data = await getHeartRateData(oneHourAgo, now);
    if (data.isEmpty) return null;

    final latest = data.last;
    final numValue = latest.value;
    if (numValue is NumericHealthValue) {
      return numValue.numericValue.toDouble();
    }
    return null;
  }
}
