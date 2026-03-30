import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/activity.dart';

class ActivityListTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const ActivityListTile({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.directions_run,
            color: AppTheme.primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          Formatters.formatDate(activity.startTime),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${Formatters.formatTime(activity.startTime)} - ${activity.endTime != null ? Formatters.formatTime(activity.endTime!) : 'In progress'}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMetric(
                  Icons.straighten,
                  Formatters.formatDistance(activity.distanceMeters),
                ),
                const SizedBox(width: 16),
                _buildMetric(
                  Icons.timer,
                  Formatters.formatDuration(activity.duration),
                ),
                const SizedBox(width: 16),
                _buildMetric(
                  Icons.local_fire_department,
                  Formatters.formatCalories(activity.caloriesBurned),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
