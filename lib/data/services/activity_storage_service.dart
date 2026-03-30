import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../models/daily_stats.dart';

class ActivityStorageService {
  static const String _activitiesKey = 'activities';
  static const String _dailyStatsKey = 'daily_stats';

  Future<void> saveActivity(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();
    activities.add(activity);
    final jsonList = activities.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_activitiesKey, jsonList);
  }

  Future<List<Activity>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_activitiesKey) ?? [];
    return jsonList
        .map((json) => Activity.fromJson(
              jsonDecode(json) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveDailyStats(DailyStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final allStats = await getDailyStatsList();
    final index = allStats.indexWhere(
      (s) =>
          s.date.year == stats.date.year &&
          s.date.month == stats.date.month &&
          s.date.day == stats.date.day,
    );
    if (index >= 0) {
      allStats[index] = stats;
    } else {
      allStats.add(stats);
    }
    final jsonList = allStats.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_dailyStatsKey, jsonList);
  }

  Future<DailyStats> getTodayStats() async {
    final allStats = await getDailyStatsList();
    final now = DateTime.now();
    return allStats.firstWhere(
      (s) =>
          s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day,
      orElse: () => DailyStats(date: DateTime(now.year, now.month, now.day)),
    );
  }

  Future<List<DailyStats>> getDailyStatsList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_dailyStatsKey) ?? [];
    return jsonList
        .map((json) => DailyStats.fromJson(
              jsonDecode(json) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
    await prefs.remove(_dailyStatsKey);
  }
}
