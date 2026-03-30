import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/services/location_service.dart';
import '../../core/constants/app_constants.dart';

class RunningProvider extends ChangeNotifier {
  final ActivityRepository _repository;
  final LocationService _locationService;

  Activity? _currentActivity;
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  Timer? _durationTimer;
  StreamSubscription<LatLng>? _locationSubscription;
  Duration _elapsed = Duration.zero;
  bool _isLocationReady = false;

  RunningProvider({
    ActivityRepository? repository,
    LocationService? locationService,
  })  : _repository = repository ?? ActivityRepository(),
        _locationService = locationService ?? LocationService();

  Activity? get currentActivity => _currentActivity;
  LatLng? get currentLocation => _currentLocation;
  List<LatLng> get routePoints => _routePoints;
  Duration get elapsed => _elapsed;
  bool get isLocationReady => _isLocationReady;

  bool get isRunning =>
      _currentActivity?.status == ActivityStatus.running;
  bool get isPaused =>
      _currentActivity?.status == ActivityStatus.paused;
  bool get isIdle =>
      _currentActivity == null ||
      _currentActivity?.status == ActivityStatus.idle;

  double get currentDistanceMeters {
    double total = 0;
    for (int i = 1; i < _routePoints.length; i++) {
      total += _locationService.calculateDistance(
        _routePoints[i - 1],
        _routePoints[i],
      );
    }
    return total;
  }

  double get currentCalories =>
      (currentDistanceMeters / AppConstants.metersPerStep) *
      AppConstants.caloriesPerStep;

  String get currentPace {
    if (_elapsed.inSeconds == 0 || currentDistanceMeters == 0) return '--:--';
    final paceSecondsPerKm = _elapsed.inSeconds / (currentDistanceMeters / 1000);
    final minutes = (paceSecondsPerKm / 60).floor();
    final seconds = (paceSecondsPerKm % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  Future<void> initializeLocation() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      _currentLocation = await _locationService.getCurrentLocation();
      _isLocationReady = true;
    }
    notifyListeners();
  }

  Future<void> startRun() async {
    _currentActivity = _repository.createNewActivity().copyWith(
      status: ActivityStatus.running,
    );
    _routePoints = [];
    _elapsed = Duration.zero;

    _startLocationTracking();
    _startTimer();

    notifyListeners();
  }

  void pauseRun() {
    if (_currentActivity == null) return;
    _currentActivity = _currentActivity!.copyWith(
      status: ActivityStatus.paused,
    );
    _durationTimer?.cancel();
    _locationSubscription?.pause();
    notifyListeners();
  }

  void resumeRun() {
    if (_currentActivity == null) return;
    _currentActivity = _currentActivity!.copyWith(
      status: ActivityStatus.running,
    );
    _startTimer();
    _locationSubscription?.resume();
    notifyListeners();
  }

  Future<Activity?> stopRun() async {
    if (_currentActivity == null) return null;

    _durationTimer?.cancel();
    _locationSubscription?.cancel();

    final steps = (currentDistanceMeters / AppConstants.metersPerStep).round();

    final completedActivity = _currentActivity!.copyWith(
      endTime: DateTime.now(),
      distanceMeters: currentDistanceMeters,
      duration: _elapsed,
      caloriesBurned: currentCalories,
      steps: steps,
      averagePace:
          _elapsed.inSeconds > 0 ? currentDistanceMeters / _elapsed.inSeconds : 0,
      routePoints: List<LatLng>.from(_routePoints),
      status: ActivityStatus.completed,
    );

    await _repository.saveActivity(completedActivity);

    _currentActivity = null;
    _routePoints = [];
    _elapsed = Duration.zero;

    notifyListeners();
    return completedActivity;
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.getLocationStream().listen(
      (latLng) {
        _currentLocation = latLng;
        if (isRunning) {
          _routePoints.add(latLng);
        }
        notifyListeners();
      },
    );
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
