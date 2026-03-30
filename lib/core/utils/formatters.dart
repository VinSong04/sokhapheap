import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static String formatPace(double metersPerSecond) {
    if (metersPerSecond <= 0) return '--:--';
    final paceSecondsPerKm = 1000 / metersPerSecond;
    final paceMinutes = (paceSecondsPerKm / 60).floor();
    final paceSeconds = (paceSecondsPerKm % 60).floor();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} /km';
  }

  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} kcal';
  }

  static String formatSteps(int steps) {
    return NumberFormat('#,###').format(steps);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }
}
