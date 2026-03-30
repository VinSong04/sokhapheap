class DailyStats {
  final DateTime date;
  final int steps;
  final double distanceMeters;
  final double caloriesBurned;
  final int activitiesCount;
  final Duration totalDuration;

  DailyStats({
    required this.date,
    this.steps = 0,
    this.distanceMeters = 0,
    this.caloriesBurned = 0,
    this.activitiesCount = 0,
    this.totalDuration = Duration.zero,
  });

  double get distanceKm => distanceMeters / 1000;

  DailyStats copyWith({
    DateTime? date,
    int? steps,
    double? distanceMeters,
    double? caloriesBurned,
    int? activitiesCount,
    Duration? totalDuration,
  }) {
    return DailyStats(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activitiesCount: activitiesCount ?? this.activitiesCount,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'distanceMeters': distanceMeters,
      'caloriesBurned': caloriesBurned,
      'activitiesCount': activitiesCount,
      'totalDuration': totalDuration.inSeconds,
    };
  }

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      activitiesCount: json['activitiesCount'] as int,
      totalDuration: Duration(seconds: json['totalDuration'] as int),
    );
  }
}
