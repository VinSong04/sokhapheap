import 'package:google_maps_flutter/google_maps_flutter.dart';

class Activity {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceMeters;
  final Duration duration;
  final double caloriesBurned;
  final int steps;
  final double averagePace;
  final List<LatLng> routePoints;
  final ActivityStatus status;

  Activity({
    required this.id,
    required this.startTime,
    this.endTime,
    this.distanceMeters = 0,
    this.duration = Duration.zero,
    this.caloriesBurned = 0,
    this.steps = 0,
    this.averagePace = 0,
    this.routePoints = const [],
    this.status = ActivityStatus.idle,
  });

  Activity copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceMeters,
    Duration? duration,
    double? caloriesBurned,
    int? steps,
    double? averagePace,
    List<LatLng>? routePoints,
    ActivityStatus? status,
  }) {
    return Activity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      steps: steps ?? this.steps,
      averagePace: averagePace ?? this.averagePace,
      routePoints: routePoints ?? this.routePoints,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distanceMeters': distanceMeters,
      'duration': duration.inSeconds,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'averagePace': averagePace,
      'routePoints': routePoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'status': status.name,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      duration: Duration(seconds: json['duration'] as int),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      steps: json['steps'] as int,
      averagePace: (json['averagePace'] as num).toDouble(),
      routePoints: (json['routePoints'] as List<dynamic>)
          .map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ))
          .toList(),
      status: ActivityStatus.values.byName(json['status'] as String),
    );
  }
}

enum ActivityStatus {
  idle,
  running,
  paused,
  completed,
}
