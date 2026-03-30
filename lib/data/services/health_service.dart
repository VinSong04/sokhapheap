import 'package:health/health.dart';

/// Service class that wraps the [Health] plugin to request permissions
/// and read/write Steps, Heart Rate, and Workout data from Apple HealthKit.
class HealthService {
  final Health _health = Health();

  /// The HealthKit data types this service works with.
  static const List<HealthDataType> _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataType> _writeTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  /// Corresponding access permissions.
  static const List<HealthDataAccess> _readPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  static const List<HealthDataAccess> _writePermissions = [
    HealthDataAccess.WRITE,
    HealthDataAccess.WRITE,
    HealthDataAccess.WRITE,
    HealthDataAccess.WRITE,
  ];

  // ------------------------------------------------------------------
  // Permissions
  // ------------------------------------------------------------------

  /// Requests HealthKit authorization for reading health data.
  Future<bool> requestPermissions() async {
    try {
      final readGranted = await _health.requestAuthorization(
        _readTypes,
        permissions: _readPermissions,
      );
      return readGranted;
    } catch (e) {
      return false;
    }
  }

  /// Requests HealthKit authorization for writing health data.
  Future<bool> requestWritePermissions() async {
    try {
      final writeGranted = await _health.requestAuthorization(
        _writeTypes,
        permissions: _writePermissions,
      );
      return writeGranted;
    } catch (e) {
      return false;
    }
  }

  /// Requests both read and write permissions.
  Future<bool> requestAllPermissions() async {
    final allTypes = [..._readTypes, ..._writeTypes];
    final allPermissions = [..._readPermissions, ..._writePermissions];
    try {
      final granted = await _health.requestAuthorization(
        allTypes,
        permissions: allPermissions,
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
        _readTypes,
        permissions: _readPermissions,
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

  /// Returns today's total step count (midnight -> now).
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

  // ------------------------------------------------------------------
  // Distance & Calories
  // ------------------------------------------------------------------

  /// Returns total walking/running distance in meters for the given interval.
  Future<double> getDistance(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_WALKING_RUNNING],
        startTime: start,
        endTime: end,
      );
      final unique = _health.removeDuplicates(data);
      double total = 0;
      for (final point in unique) {
        final val = point.value;
        if (val is NumericHealthValue) {
          total += val.numericValue.toDouble();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Returns total active energy burned in kcal for the given interval.
  Future<double> getActiveCalories(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );
      final unique = _health.removeDuplicates(data);
      double total = 0;
      for (final point in unique) {
        final val = point.value;
        if (val is NumericHealthValue) {
          total += val.numericValue.toDouble();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // ------------------------------------------------------------------
  // Write Workout
  // ------------------------------------------------------------------

  /// Saves a running workout to HealthKit.
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    required double distanceMeters,
    required double caloriesBurned,
  }) async {
    try {
      final success = await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.RUNNING,
        start: start,
        end: end,
        totalDistance: distanceMeters.round(),
        totalEnergyBurned: caloriesBurned.round(),
      );
      return success;
    } catch (e) {
      return false;
    }
  }
}
