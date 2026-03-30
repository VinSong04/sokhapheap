import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/weekly_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Steps',
                          value: Formatters.formatSteps(
                            provider.todayStats.steps,
                          ),
                          icon: Icons.directions_walk,
                          iconColor: AppTheme.primaryColor,
                          progress: provider.stepProgress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Calories',
                          value: Formatters.formatCalories(
                            provider.todayStats.caloriesBurned,
                          ),
                          icon: Icons.local_fire_department,
                          iconColor: AppTheme.accentColor,
                          progress: provider.calorieProgress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          title: 'Distance',
                          value: Formatters.formatDistance(
                            provider.todayStats.distanceMeters,
                          ),
                          icon: Icons.straighten,
                          iconColor: AppTheme.secondaryColor,
                          progress: provider.distanceProgress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGoalSummary(provider),
                  const SizedBox(height: 16),
                  WeeklyChart(weeklyStats: provider.weeklyStats),
                  const SizedBox(height: 16),
                  _buildQuickStats(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalSummary(DashboardProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildGoalRow(
              'Steps',
              provider.todayStats.steps,
              AppConstants.dailyStepGoal,
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            _buildGoalRow(
              'Distance (km)',
              (provider.todayStats.distanceMeters / 1000 * 100).round(),
              (AppConstants.dailyDistanceGoalKm * 100).round(),
              AppTheme.secondaryColor,
            ),
            const SizedBox(height: 8),
            _buildGoalRow(
              'Calories',
              provider.todayStats.caloriesBurned.round(),
              AppConstants.dailyCalorieGoal.round(),
              AppTheme.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String label, int current, int goal, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '$current / $goal',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(DashboardProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat(
                  'Activities',
                  '${provider.todayStats.activitiesCount}',
                  Icons.fitness_center,
                ),
                _buildQuickStat(
                  'Duration',
                  Formatters.formatDuration(provider.todayStats.totalDuration),
                  Icons.timer,
                ),
                _buildQuickStat(
                  'Avg Pace',
                  provider.todayStats.totalDuration.inSeconds > 0 &&
                          provider.todayStats.distanceMeters > 0
                      ? Formatters.formatPace(
                          provider.todayStats.distanceMeters /
                              provider.todayStats.totalDuration.inSeconds,
                        )
                      : '--:--',
                  Icons.speed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
