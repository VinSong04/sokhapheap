import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/activity.dart';

class RunSummaryScreen extends StatelessWidget {
  final Activity activity;

  const RunSummaryScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (activity.routePoints.isNotEmpty) ...[
                _buildRouteMap(),
                const SizedBox(height: 24),
              ],
              _buildMainStat(),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildDetailsList(),
              const SizedBox(height: 32),
              _buildDoneButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RUN COMPLETE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Great Job!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.neonGreenGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(60),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: AppTheme.backgroundColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteMap() {
    final bounds = _getLatLngBounds(activity.routePoints);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
            (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
          ),
          zoom: 14,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: activity.routePoints,
            color: AppTheme.primaryColor,
            width: 4,
          ),
        },
        markers: {
          Marker(
            markerId: const MarkerId('start'),
            position: activity.routePoints.first,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
          Marker(
            markerId: const MarkerId('end'),
            position: activity.routePoints.last,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'Finish'),
          ),
        },
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
      ),
    );
  }

  Widget _buildMainStat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
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
          Text(
            Formatters.formatDistance(activity.distanceMeters),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'TOTAL DISTANCE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            Icons.timer_rounded,
            const Color(0xFF448AFF),
            'Duration',
            Formatters.formatDuration(activity.duration),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            Icons.speed_rounded,
            const Color(0xFFE040FB),
            'Avg Pace',
            activity.averagePace > 0
                ? Formatters.formatPace(activity.averagePace)
                : '--:--',
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(
      IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Calories Burned',
            Formatters.formatCalories(activity.caloriesBurned),
            Icons.local_fire_department_rounded,
            const Color(0xFFFF6D00),
          ),
          const Divider(color: AppTheme.dividerColor, height: 24),
          _buildDetailRow(
            'Steps',
            Formatters.formatSteps(activity.steps),
            Icons.directions_walk_rounded,
            AppTheme.primaryColor,
          ),
          const Divider(color: AppTheme.dividerColor, height: 24),
          _buildDetailRow(
            'Start Time',
            Formatters.formatTime(activity.startTime),
            Icons.play_circle_rounded,
            const Color(0xFF00BFA5),
          ),
          if (activity.endTime != null) ...[
            const Divider(color: AppTheme.dividerColor, height: 24),
            _buildDetailRow(
              'End Time',
              Formatters.formatTime(activity.endTime!),
              Icons.stop_circle_rounded,
              Colors.redAccent,
            ),
          ],
          const Divider(color: AppTheme.dividerColor, height: 24),
          _buildDetailRow(
            'Date',
            Formatters.formatDate(activity.startTime),
            Icons.calendar_today_rounded,
            const Color(0xFF448AFF),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Done'),
      ),
    );
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
