import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/macro_card.dart';
import '../widgets/calorie_ring.dart';
import '../providers/app_state.dart';
import '../models/meal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime now) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    final dayNum = now.day.toString().padLeft(2, '0');
    return '$dayName, $dayNum $monthName';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'GB';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.userProfile;
    final userName = profile?.name.split(' ').first ?? 'Champion';
    final initials = profile != null ? _getInitials(profile.name) : 'GB';
    final percentConsumed = (state.calorieProgress * 100).toInt();
    final todayMeals = state.todayMeals;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Greeting Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A2A30), Color(0xFF19191C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: AppTheme.divider, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, $userName',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fuel your potential.',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // WhatsApp summary action shortcut
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/whatsapp-summary'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date & Daily overview link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/daily-nutrition'),
                    child: Row(
                      children: [
                        Text(
                          'Daily overview',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.accent, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Calorie Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.divider.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CALORIES REMAINING',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  state.remainingCalories.toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'kcal',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        CalorieRing(
                          progress: state.calorieProgress,
                          centerValue: '$percentConsumed%',
                          centerUnit: 'consumed',
                          size: 96,
                          strokeWidth: 8,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                        height: 1,
                        color: AppTheme.divider.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consumed',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.todayCalories} kcal',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Daily target',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.targetCalories} kcal',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Daily Macros Row (3 Cards)
              Row(
                children: [
                  Expanded(
                    child: MacroCard(
                      label: 'Protein',
                      consumed: '${state.todayProtein}g',
                      target: 'of ${state.targetProtein}g',
                      progress: state.proteinProgress,
                      fillColor: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MacroCard(
                      label: 'Carbs',
                      consumed: '${state.todayCarbs}g',
                      target: 'of ${state.targetCarbs}g',
                      progress: state.carbsProgress,
                      fillColor: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MacroCard(
                      label: 'Fats',
                      consumed: '${state.todayFat}g',
                      target: 'of ${state.targetFat}g',
                      progress: state.fatProgress,
                      fillColor: AppTheme.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Quick Actions
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/scanner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.accentText,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded,
                        color: AppTheme.accentText, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Scan Meal',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/text-logging'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppTheme.bgCard,
                        side: BorderSide(
                            color: AppTheme.divider.withValues(alpha: 0.8)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: AppTheme.textPrimary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Log Food',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/ai-chat'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppTheme.bgCard,
                        side: BorderSide(
                            color: AppTheme.divider.withValues(alpha: 0.8)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: AppTheme.purple, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Ask AI',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Nutrition Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today’s Meals',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/history'),
                    child: Text(
                      'View all',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Meal entries list
              if (todayMeals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.divider.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_outlined,
                            color: AppTheme.textDim, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'No meals logged today yet',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Scan a photo or type what you ate to start tracking.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...todayMeals.map((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildMealItem(
                      context: context,
                      title: meal.mealName,
                      nutrition:
                          '${meal.nutrition.calories} kcal  ·  ${meal.nutrition.proteinG}g protein  ·  ${meal.nutrition.carbsG}g carbs',
                      timestamp:
                          '${meal.mealType.label.toUpperCase()}  ·  ${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}',
                      icon: _iconForMealType(meal.mealType),
                    ),
                  );
                }),

              const SizedBox(height: 18),

              // AI Insight Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgAI,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.purple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: AppTheme.purple, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        todayMeals.isEmpty
                            ? 'Start your day strong. Scan your first meal to stay on top of your daily nutrition targets.'
                            : state.proteinProgress >= 0.8
                                ? 'Outstanding job! You’ve reached ${state.todayProtein}g of your ${state.targetProtein}g protein goal.'
                                : 'You’ve consumed ${state.todayCalories} kcal so far ($percentConsumed% of goal). ${state.remainingCalories} kcal remaining for today.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.egg_alt_outlined;
      case MealType.lunch:
        return Icons.restaurant_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
      case MealType.snack:
        return Icons.coffee_rounded;
    }
  }

  Widget _buildMealItem({
    required BuildContext context,
    required String title,
    required String nutrition,
    required String timestamp,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4)),
        ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nutrition,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textDim,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
