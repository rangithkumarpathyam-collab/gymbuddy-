import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/macro_card.dart';
import '../widgets/calorie_ring.dart';
import '../providers/app_state.dart';
import '../models/meal.dart';

class DailyNutritionScreen extends StatelessWidget {
  const DailyNutritionScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final todayMeals = state.todayMeals;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Your daily balance.',
              overline: _formatDate(DateTime.now()),
              showBack: true,
              trailingAction: const Icon(Icons.calendar_today_rounded,
                  color: AppTheme.textPrimary, size: 20),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calorie overview card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          CalorieRing(
                            progress: state.calorieProgress,
                            centerValue: '${state.todayCalories}',
                            centerUnit: 'kcal consumed',
                            size: 110,
                            strokeWidth: 9,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'REMAINING',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accent,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${state.remainingCalories}',
                                  style: GoogleFonts.inter(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'kcal of ${state.targetCalories} daily target',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
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
                    const SizedBox(height: 16),

                    // Water Balance Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.purple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.water_drop_rounded,
                                    color: AppTheme.purple, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Water intake',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      '${state.waterLiters.toStringAsFixed(2)} / 2.50 L (${state.waterGlasses} glasses)',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => state.addWaterGlass(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgElevated,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.divider),
                                  ),
                                  child: Text(
                                    '+ 250ml',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              height: 4,
                              width: double.infinity,
                              color: AppTheme.divider,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (state.waterLiters / 2.5).clamp(0.0, 1.0),
                                child: Container(color: AppTheme.purple),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meal Timeline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your meal timeline',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${todayMeals.length} logged',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                          child: Text(
                            'No meals logged yet today.\nScan or type your food to populate your daily timeline.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(todayMeals.length, (index) {
                        final meal = todayMeals[index];
                        final isLast = index == todayMeals.length - 1;
                        final hour = meal.timestamp.hour
                            .toString()
                            .padLeft(2, '0');
                        final min = meal.timestamp.minute
                            .toString()
                            .padLeft(2, '0');
                        return _buildTimelineItem(
                          type: meal.mealType.label,
                          time: '$hour:$min',
                          name: meal.mealName,
                          calories: '${meal.nutrition.calories} kcal',
                          macros:
                              'P ${meal.nutrition.proteinG}g  ·  C ${meal.nutrition.carbsG}g  ·  F ${meal.nutrition.fatG}g',
                          isCompleted: true,
                          isLast: isLast,
                        );
                      }),

                    const SizedBox(height: 24),

                    // Primary Button: WhatsApp Summary
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/whatsapp-summary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.accentText,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded,
                              color: AppTheme.accentText, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'View WhatsApp Summary',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentText,
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
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String type,
    required String time,
    required String name,
    required String calories,
    required String macros,
    required bool isCompleted,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? AppTheme.accent : AppTheme.divider,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.divider.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.divider.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppTheme.accent
                                : AppTheme.textDim,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          macros,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        Text(
                          calories,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
