import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            children: [
              _buildSectionHeader('DAILY GOALS'),
              const SizedBox(height: 8),
              _buildGoalTile(
                context,
                icon: Icons.directions_walk_rounded,
                color: AppTheme.primaryColor,
                title: 'Step Goal',
                value: '${provider.stepGoal} steps',
                onTap: () => _showStepGoalDialog(context, provider),
              ),
              _buildGoalTile(
                context,
                icon: Icons.straighten_rounded,
                color: const Color(0xFF00BFA5),
                title: 'Distance Goal',
                value: '${provider.distanceGoalKm.toStringAsFixed(1)} km',
                onTap: () => _showDistanceGoalDialog(context, provider),
              ),
              _buildGoalTile(
                context,
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFF6D00),
                title: 'Calorie Goal',
                value: '${provider.calorieGoal.toStringAsFixed(0)} kcal',
                onTap: () => _showCalorieGoalDialog(context, provider),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('PROFILE'),
              const SizedBox(height: 8),
              _buildGoalTile(
                context,
                icon: Icons.monitor_weight_rounded,
                color: const Color(0xFF448AFF),
                title: 'Weight',
                value: '${provider.weight.toStringAsFixed(1)} kg',
                onTap: () => _showWeightDialog(context, provider),
              ),
              _buildGoalTile(
                context,
                icon: Icons.height_rounded,
                color: const Color(0xFFE040FB),
                title: 'Height',
                value: '${provider.height.toStringAsFixed(0)} cm',
                onTap: () => _showHeightDialog(context, provider),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('INTEGRATIONS'),
              const SizedBox(height: 8),
              _buildToggleTile(
                icon: Icons.favorite_rounded,
                color: Colors.redAccent,
                title: 'Apple Health',
                subtitle: 'Sync steps, heart rate & workouts',
                value: provider.healthKitEnabled,
                onChanged: (val) => provider.toggleHealthKit(val),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('PREFERENCES'),
              const SizedBox(height: 8),
              _buildToggleTile(
                icon: Icons.straighten_rounded,
                color: AppTheme.textSecondary,
                title: 'Metric Units',
                subtitle: 'Use km instead of miles',
                value: provider.useMetric,
                onChanged: (val) => provider.toggleUseMetric(val),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('DATA'),
              const SizedBox(height: 8),
              _buildGoalTile(
                context,
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                title: 'Clear All Data',
                value: '',
                onTap: () => _showClearDataDialog(context),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('ABOUT'),
              const SizedBox(height: 8),
              _buildInfoTile(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                value: '1.0.0',
              ),
              _buildInfoTile(
                icon: Icons.code_rounded,
                title: 'Architecture',
                value: 'MVVM + Provider',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textTertiary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildGoalTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primaryColor.withAlpha(150),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryColor;
          }
          return AppTheme.textTertiary;
        }),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showStepGoalDialog(BuildContext context, SettingsProvider provider) {
    final controller =
        TextEditingController(text: provider.stepGoal.toString());
    _showInputDialog(
      context,
      title: 'Daily Step Goal',
      controller: controller,
      suffix: 'steps',
      onSave: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) {
          provider.updateStepGoal(parsed);
        }
      },
    );
  }

  void _showDistanceGoalDialog(
      BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(
        text: provider.distanceGoalKm.toStringAsFixed(1));
    _showInputDialog(
      context,
      title: 'Daily Distance Goal',
      controller: controller,
      suffix: 'km',
      isDecimal: true,
      onSave: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null && parsed > 0) {
          provider.updateDistanceGoalKm(parsed);
        }
      },
    );
  }

  void _showCalorieGoalDialog(
      BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(
        text: provider.calorieGoal.toStringAsFixed(0));
    _showInputDialog(
      context,
      title: 'Daily Calorie Goal',
      controller: controller,
      suffix: 'kcal',
      onSave: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null && parsed > 0) {
          provider.updateCalorieGoal(parsed);
        }
      },
    );
  }

  void _showWeightDialog(BuildContext context, SettingsProvider provider) {
    final controller =
        TextEditingController(text: provider.weight.toStringAsFixed(1));
    _showInputDialog(
      context,
      title: 'Weight',
      controller: controller,
      suffix: 'kg',
      isDecimal: true,
      onSave: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null && parsed > 0) {
          provider.updateWeight(parsed);
        }
      },
    );
  }

  void _showHeightDialog(BuildContext context, SettingsProvider provider) {
    final controller =
        TextEditingController(text: provider.height.toStringAsFixed(0));
    _showInputDialog(
      context,
      title: 'Height',
      controller: controller,
      suffix: 'cm',
      onSave: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null && parsed > 0) {
          provider.updateHeight(parsed);
        }
      },
    );
  }

  void _showInputDialog(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String suffix,
    bool isDecimal = false,
    required ValueChanged<String> onSave,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: const TextStyle(color: AppTheme.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear All Data?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will permanently delete all your activity history and daily stats. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('activities');
              await prefs.remove('daily_stats');
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
