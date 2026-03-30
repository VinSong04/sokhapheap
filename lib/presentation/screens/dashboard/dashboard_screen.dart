import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/gradient_progress_ring.dart';
import '../../widgets/weekly_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.cardColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _buildProgressRings(context, provider),
                      const SizedBox(height: 24),
                      _buildMetricCards(provider),
                      const SizedBox(height: 24),
                      if (provider.healthKitConnected && provider.heartRate != null)
                        ...[
                          _buildHeartRateCard(provider),
                          const SizedBox(height: 24),
                        ],
                      _buildGoalSection(provider),
                      const SizedBox(height: 24),
                      WeeklyChart(weeklyStats: provider.weeklyStats),
                      const SizedBox(height: 24),
                      _buildQuickStats(provider),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RunTracker',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
          onPressed: () {
            context.read<DashboardProvider>().refresh();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressRings(BuildContext context, DashboardProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth - 80) / 3;
    final clampedRingSize = ringSize.clamp(90.0, 130.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'TODAY\'S PROGRESS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GradientProgressRing(
                progress: provider.stepProgress,
                size: clampedRingSize,
                strokeWidth: 8,
                value: Formatters.formatSteps(provider.todayStats.steps),
                label: 'STEPS',
                icon: Icons.directions_walk_rounded,
                gradientColors: const [
                  Color(0xFF39FF14),
                  Color(0xFF00E676),
                ],
              ),
              GradientProgressRing(
                progress: provider.calorieProgress,
                size: clampedRingSize,
                strokeWidth: 8,
                value: provider.todayStats.caloriesBurned.toStringAsFixed(0),
                label: 'KCAL',
                icon: Icons.local_fire_department_rounded,
                gradientColors: const [
                  Color(0xFFFF6D00),
                  Color(0xFFFF9100),
                ],
              ),
              GradientProgressRing(
                progress: provider.distanceProgress,
                size: clampedRingSize,
                strokeWidth: 8,
                value: (provider.todayStats.distanceMeters / 1000)
                    .toStringAsFixed(1),
                label: 'KM',
                icon: Icons.straighten_rounded,
                gradientColors: const [
                  Color(0xFF00BFA5),
                  Color(0xFF64FFDA),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards(DashboardProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            icon: Icons.timer_rounded,
            iconColor: const Color(0xFF448AFF),
            label: 'Duration',
            value: Formatters.formatDuration(provider.todayStats.totalDuration),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassCard(
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFFE040FB),
            label: 'Avg Pace',
            value: provider.todayStats.totalDuration.inSeconds > 0 &&
                    provider.todayStats.distanceMeters > 0
                ? Formatters.formatPace(
                    provider.todayStats.distanceMeters /
                        provider.todayStats.totalDuration.inSeconds,
                  )
                : '--:--',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassCard(
            icon: Icons.fitness_center_rounded,
            iconColor: AppTheme.primaryColor,
            label: 'Runs',
            value: '${provider.todayStats.activitiesCount}',
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A1A), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withAlpha(40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HEART RATE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      provider.heartRate!.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.redAccent,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        'BPM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.monitor_heart_rounded,
            color: Colors.redAccent,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'DAILY GOALS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGoalRow(
            'Steps',
            provider.todayStats.steps,
            provider.stepGoal,
            const [Color(0xFF39FF14), Color(0xFF00E676)],
          ),
          const SizedBox(height: 16),
          _buildGoalRow(
            'Distance',
            (provider.todayStats.distanceMeters / 10).round(),
            (provider.distanceGoalKm * 100).round(),
            const [Color(0xFF00BFA5), Color(0xFF64FFDA)],
          ),
          const SizedBox(height: 16),
          _buildGoalRow(
            'Calories',
            provider.todayStats.caloriesBurned.round(),
            provider.calorieGoal.round(),
            const [Color(0xFFFF6D00), Color(0xFFFF9100)],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow(
      String label, int current, int goal, List<Color> colors) {
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
                fontWeight: FontWeight.w500,
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
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.cardColorLight,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withAlpha(80),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2A1A), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(40),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'QUICK STATS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                'Activities',
                '${provider.todayStats.activitiesCount}',
                Icons.fitness_center_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.dividerColor,
              ),
              _buildQuickStat(
                'Duration',
                Formatters.formatDuration(provider.todayStats.totalDuration),
                Icons.timer_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.dividerColor,
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
                Icons.speed_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
