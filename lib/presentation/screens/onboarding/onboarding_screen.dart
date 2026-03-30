import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/health_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/settings_service.dart';
import '../home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final HealthService _healthService = HealthService();
  final LocationService _locationService = LocationService();
  final SettingsService _settingsService = SettingsService();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildHealthKitPage(),
                    _buildLocationPage(),
                    _buildReadyPage(),
                  ],
                ),
              ),
              _buildPageIndicator(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.neonGreenGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(80),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              size: 60,
              color: AppTheme.backgroundColor,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'RunTracker',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Track your runs, monitor your health,\nand achieve your fitness goals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton('Get Started', () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthKitPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withAlpha(30),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 50,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Apple Health',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect to Apple Health to sync your steps,\nheart rate, and save your workouts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildNextButton('Connect Health', () async {
            final granted = await _healthService.requestAllPermissions();
            if (granted) {
              await _settingsService.setHealthKitEnabled(true);
            }
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(30),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 50,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Location Access',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Allow location access to track your\nrunning route and calculate distance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildNextButton('Allow Location', () async {
            await _locationService.requestPermission();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.neonGreenGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(60),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 50,
              color: AppTheme.backgroundColor,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'You\'re All Set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start tracking your runs and\ncrush your fitness goals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton('Let\'s Go!', () async {
            await _settingsService.setOnboardingComplete(true);
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildNextButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: Text(text),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : AppTheme.cardColorLight,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
