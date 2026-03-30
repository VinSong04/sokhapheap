import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/daily_stats.dart';
import '../services/activity_storage_service.dart';
import '../../core/constants/app_constants.dart';

class ActivityRepository {
  final ActivityStorageService _storageService;
  final Uuid _uuid = const Uuid();

  ActivityRepository({ActivityStorageService? storageService})
      : _storageService = storageService ?? ActivityStorageService();

  Activity createNewActivity() {
    return Activity(
      id: _uuid.v4(),
      startTime: DateTime.now(),
    );
  }

  Future<void> saveActivity(Activity activity) async {
    await _storageService.saveActivity(activity);
    await _updateDailyStats(activity);
  }

  Future<List<Activity>> getActivityHistory() async {
    final activities = await _storageService.getActivities();
    activities.sort((a, b) => b.startTime.compareTo(a.startTime));
    return activities;
  }

  Future<DailyStats> getTodayStats() async {
    return _storageService.getTodayStats();
  }

  Future<List<DailyStats>> getWeeklyStats() async {
    final allStats = await _storageService.getDailyStatsList();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return allStats
        .where((s) => s.date.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _updateDailyStats(Activity activity) async {
    final todayStats = await _storageService.getTodayStats();
    final updated = todayStats.copyWith(
      steps: todayStats.steps + activity.steps,
      distanceMeters: todayStats.distanceMeters + activity.distanceMeters,
      caloriesBurned: todayStats.caloriesBurned + activity.caloriesBurned,
      activitiesCount: todayStats.activitiesCount + 1,
      totalDuration: todayStats.totalDuration + activity.duration,
    );
    await _storageService.saveDailyStats(updated);
  }

  double calculateCalories(int steps) {
    return steps * AppConstants.caloriesPerStep;
  }

  double calculateDistance(int steps) {
    return steps * AppConstants.metersPerStep;
  }
}
