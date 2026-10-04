import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _counterOrbitController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _counterOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: false);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Navigate after 2s based on onboarding state
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.isOnboarded) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _counterOrbitController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            children: [
              // Status bar placeholder
              const SizedBox(height: 8),

              // Brand stage — orbital animation
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOrbitalAnimation(),
                      const SizedBox(height: 40),
                      _buildBrandSignature(),
                    ],
                  ),
                ),
              ),

              // Startup indicator
              _buildStartupIndicator(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbitalAnimation() {
    return SizedBox(
      width: 288,
      height: 288,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer orbit — slow rotation
          RotationTransition(
            turns: _orbitController,
            child: Container(
              width: 288,
              height: 288,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4), width: 1),
              ),
            ),
          ),
          // Inner orbit — counter rotation
          RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(_counterOrbitController),
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider.withValues(alpha: 0.6), width: 1),
              ),
            ),
          ),
          // Core halo — breathing opacity
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.04 + _pulseController.value * 0.04),
                ),
              );
            },
          ),
          // Precision axes
          Container(width: 232, height: 1, color: AppTheme.divider.withValues(alpha: 0.3)),
          Container(width: 1, height: 232, color: AppTheme.divider.withValues(alpha: 0.3)),
          // Monogram
          Text(
            'GB.',
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          // Orbit particle — lime dot
          RotationTransition(
            turns: _orbitController,
            child: Transform.translate(
              offset: const Offset(0, -144),
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSignature() {
    return Column(
      children: [
        Text(
          'GYMBUDDY',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your AI Nutrition & Calorie Tracker',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStartupIndicator() {
    return Column(
      children: [
        Text(
          'Precision. Powered by you.',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.mutedDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Loading pulse dots
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.5 + _pulseController.value * 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(width: 6, height: 3, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(width: 6, height: 3, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
              ],
            );
          },
        ),
      ],
    );
  }
}
