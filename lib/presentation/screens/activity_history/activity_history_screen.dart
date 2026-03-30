import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/activity_history_provider.dart';
import '../../widgets/activity_list_tile.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ActivityHistoryProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<ActivityHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildFilterChips(context, provider),
              _buildSummaryBar(provider),
              Expanded(
                child: provider.activities.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: provider.refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: provider.activities.length,
                          itemBuilder: (context, index) {
                            return ActivityListTile(
                              activity: provider.activities[index],
                              onTap: () {
                                _showActivityDetail(
                                  context,
                                  provider.activities[index],
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    ActivityHistoryProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ActivityFilter.values.map((filter) {
            final isSelected = provider.currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_filterLabel(filter)),
                selected: isSelected,
                onSelected: (_) => provider.setFilter(filter),
                selectedColor: AppTheme.primaryColor.withAlpha(50),
                checkmarkColor: AppTheme.primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(ActivityHistoryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            '${provider.totalActivities}',
            'Runs',
          ),
          _buildSummaryItem(
            Formatters.formatDistance(provider.totalDistance),
            'Distance',
          ),
          _buildSummaryItem(
            Formatters.formatCalories(provider.totalCalories),
            'Calories',
          ),
          _buildSummaryItem(
            Formatters.formatDuration(provider.totalDuration),
            'Duration',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_run,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No activities yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a run to see your activity history here',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetail(
    BuildContext context,
    dynamic activity,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Run Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Date',
                  Formatters.formatDate(activity.startTime),
                ),
                _buildDetailRow(
                  'Start Time',
                  Formatters.formatTime(activity.startTime),
                ),
                if (activity.endTime != null)
                  _buildDetailRow(
                    'End Time',
                    Formatters.formatTime(activity.endTime!),
                  ),
                _buildDetailRow(
                  'Distance',
                  Formatters.formatDistance(activity.distanceMeters),
                ),
                _buildDetailRow(
                  'Duration',
                  Formatters.formatDuration(activity.duration),
                ),
                _buildDetailRow(
                  'Calories',
                  Formatters.formatCalories(activity.caloriesBurned),
                ),
                _buildDetailRow(
                  'Steps',
                  Formatters.formatSteps(activity.steps),
                ),
                _buildDetailRow(
                  'Avg Pace',
                  activity.averagePace > 0
                      ? Formatters.formatPace(activity.averagePace)
                      : '--:--',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(ActivityFilter filter) {
    switch (filter) {
      case ActivityFilter.all:
        return 'All';
      case ActivityFilter.today:
        return 'Today';
      case ActivityFilter.thisWeek:
        return 'This Week';
      case ActivityFilter.thisMonth:
        return 'This Month';
    }
  }
}
