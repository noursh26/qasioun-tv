import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/app_update.dart';
import '../widgets/update_dialog.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  static const String currentAppVersion = '1.0.0';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Minimum duration for splash screen display
    final startTime = DateTime.now();

    AppUpdate? updateInfo;
    bool hasConnectionError = false;

    // Check for updates
    try {
      updateInfo = await _apiService.fetchAppUpdate();
    } catch (e) {
      print('Update check failed: $e');
      hasConnectionError = true;
    }

    // Determine if we need to show update dialog
    bool showUpdate = false;
    if (updateInfo != null && updateInfo.updateAvailable) {
      // Version comparison: Simple check (1.0.0 < 1.2.0)
      if (currentAppVersion != updateInfo.targetVersion) {
        showUpdate = true;
      }
    }

    // Pre-fetch other data while animating
    dynamic channels;
    dynamic series;
    dynamic slides;
    dynamic movies;

    if (!showUpdate || !updateInfo!.forceUpdate) {
      try {
        // Run parallel pre-fetching
        final results = await Future.wait([
          _apiService.fetchLiveChannels(),
          _apiService.fetchTvSeries(),
          _apiService.fetchContactSlides(),
          _apiService.fetchMovies(),
        ]);
        channels = results[0];
        series = results[1];
        slides = results[2];
        movies = results[3];
      } catch (e) {
        print('Pre-fetching failed: $e');
      }
    }

    // Wait until minimum time has elapsed
    final elapsed = DateTime.now().difference(startTime);
    final minDuration = const Duration(milliseconds: 2800);
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (!mounted) return;

    if (showUpdate && updateInfo != null) {
      // Show update dialog
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.forceUpdate,
        builder: (context) => UpdateDialog(updateInfo: updateInfo!),
      );

      // If force update is true, we stay on splash screen, user must update.
      // If it is not a force update and dialog is dismissed, we proceed to Home.
      if (updateInfo.forceUpdate) {
        return;
      }
    }

    // Navigate to Home with fade transition, passing pre-loaded data
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          initialChannels: channels ?? [],
          initialSeries: series ?? [],
          initialSlides: slides ?? [],
          initialMovies: movies ?? [],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background back image
          Image.asset(
            'assets/images/back.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0F172A),
            ),
          ),
          
          // Dark glassmorphism overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Animating logo and title
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with styling
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Image.asset(
                        'assets/images/app.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.indigo,
                          child: const Icon(Icons.tv, size: 70, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Text Branding
                  const Text(
                    'قاسيون TV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Arabic descriptive text
                  Text(
                    'بوابة الترفيه اللامحدودة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Loader at the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
