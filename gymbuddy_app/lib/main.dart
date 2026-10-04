import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meal_scanner_screen.dart';
import 'screens/meal_analysis_screen.dart';
import 'screens/daily_nutrition_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/meal_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/text_logging_screen.dart';
import 'screens/whatsapp_summary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const GymBuddyApp(),
    ),
  );
}

class GymBuddyApp extends StatelessWidget {
  const GymBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const MainNavScreen(),
        '/scanner': (context) => const MealScannerScreen(),
        '/meal-analysis': (context) => const MealAnalysisScreen(),
        '/daily-nutrition': (context) => const DailyNutritionScreen(),
        '/ai-chat': (context) => const AiChatScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/history': (context) => const MealHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/text-logging': (context) => const TextLoggingScreen(),
        '/whatsapp-summary': (context) => const WhatsappSummaryScreen(),
      },
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MealScannerScreen(),
    ProgressScreen(),
    MealHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 88,
      color: AppTheme.navBar,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navTab(0, 'Home', Icons.home_rounded),
              _navTab(1, 'Log Meal', Icons.qr_code_scanner_rounded),
              _navTab(2, 'Progress', Icons.show_chart_rounded),
              _navTab(3, 'History', Icons.schedule_rounded),
              _navTab(4, 'Profile', Icons.person_rounded),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 108,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTab(int index, String label, IconData icon) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 76,
        height: 68,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppTheme.accent : AppTheme.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.accent : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
