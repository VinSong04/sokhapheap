import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/running_provider.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunningProvider>().initializeLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Run'),
      ),
      body: Consumer<RunningProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: provider.currentLocation ??
                      const LatLng(
                        AppConstants.defaultLatitude,
                        AppConstants.defaultLongitude,
                      ),
                  zoom: AppConstants.defaultMapZoom,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polylines: {
                  if (provider.routePoints.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: provider.routePoints,
                      color: AppTheme.primaryColor,
                      width: 5,
                    ),
                },
                markers: {
                  if (provider.routePoints.isNotEmpty)
                    Marker(
                      markerId: const MarkerId('start'),
                      position: provider.routePoints.first,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: const InfoWindow(title: 'Start'),
                    ),
                  if (provider.currentLocation != null && provider.isRunning)
                    Marker(
                      markerId: const MarkerId('current'),
                      position: provider.currentLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                    ),
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildControlPanel(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, RunningProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                'Distance',
                Formatters.formatDistance(provider.currentDistanceMeters),
                Icons.straighten,
              ),
              _buildMetric(
                'Time',
                Formatters.formatDuration(provider.elapsed),
                Icons.timer,
              ),
              _buildMetric(
                'Pace',
                provider.currentPace,
                Icons.speed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                'Calories',
                Formatters.formatCalories(provider.currentCalories),
                Icons.local_fire_department,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildControlButtons(context, provider),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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

  Widget _buildControlButtons(BuildContext context, RunningProvider provider) {
    if (provider.isIdle) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: provider.isLocationReady
              ? () => provider.startRun()
              : null,
          icon: const Icon(Icons.play_arrow, size: 28),
          label: Text(
            provider.isLocationReady ? 'Start Run' : 'Getting Location...',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (provider.isRunning)
          _buildCircleButton(
            icon: Icons.pause,
            color: Colors.orange,
            onPressed: provider.pauseRun,
            label: 'Pause',
          ),
        if (provider.isPaused)
          _buildCircleButton(
            icon: Icons.play_arrow,
            color: AppTheme.primaryColor,
            onPressed: provider.resumeRun,
            label: 'Resume',
          ),
        const SizedBox(width: 32),
        _buildCircleButton(
          icon: Icons.stop,
          color: Colors.red,
          onPressed: () async {
            final result = await _showStopConfirmation(context);
            if (result == true) {
              if (context.mounted) {
                final activity =
                    await context.read<RunningProvider>().stopRun();
                if (activity != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Run completed! ${Formatters.formatDistance(activity.distanceMeters)} in ${Formatters.formatDuration(activity.duration)}',
                      ),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                }
              }
            }
          },
          label: 'Stop',
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Icon(icon, size: 32),
          ),
        ),
        const SizedBox(height: 4),
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

  Future<bool?> _showStopConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Run?'),
        content: const Text(
          'Are you sure you want to stop your current run? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
