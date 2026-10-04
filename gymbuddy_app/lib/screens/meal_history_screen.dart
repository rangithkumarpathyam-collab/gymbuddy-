import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../providers/app_state.dart';
import '../models/meal.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  String _activeFilter = 'All meals';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final query = _searchController.text.trim().toLowerCase();

    List<MealEntry> filtered = state.meals.where((meal) {
      if (query.isNotEmpty) {
        final nameMatch = meal.mealName.toLowerCase().contains(query);
        final ingMatch = meal.nutrition.ingredients
            .any((i) => i.name.toLowerCase().contains(query));
        if (!nameMatch && !ingMatch) return false;
      }

      if (_activeFilter == 'High protein') {
        return meal.nutrition.proteinG >= 25;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Your nutrition diary.',
              overline: 'Meal history',
              showBack: false,
              trailingAction: Icon(Icons.calendar_today_rounded,
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
                    // Search bar
                    Text(
                      'Search your diary',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgInput,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AppTheme.textDim, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search meals or ingredients',
                                hintStyle: GoogleFonts.inter(
                                    color: AppTheme.textDim, fontSize: 14),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              child: const Icon(Icons.clear_rounded,
                                  color: AppTheme.textDim, size: 18),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter chips
                    Row(
                      children: [
                        _buildFilterChip('All meals'),
                        const SizedBox(width: 8),
                        _buildFilterChip('High protein'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Entries Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Logged Meals',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${filtered.length} entries',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (filtered.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.divider.withValues(alpha: 0.4)),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.history_rounded,
                                  color: AppTheme.textDim, size: 40),
                              const SizedBox(height: 10),
                              Text(
                                'No matching meals found',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Scan or log a meal to add it to your history.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filtered.reversed.map((meal) {
                        final hour =
                            meal.timestamp.hour.toString().padLeft(2, '0');
                        final min =
                            meal.timestamp.minute.toString().padLeft(2, '0');
                        final day =
                            '${meal.timestamp.day}/${meal.timestamp.month}';

                        return Dismissible(
                          key: Key(meal.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white, size: 24),
                          ),
                          onDismissed: (_) {
                            state.deleteMeal(meal.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${meal.mealName} deleted'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildMealHistoryItem(
                              title: meal.mealName,
                              nutrition:
                                  '${meal.nutrition.calories} kcal  ·  ${meal.nutrition.proteinG}g P · ${meal.nutrition.carbsG}g C · ${meal.nutrition.fatG}g F',
                              timestamp:
                                  '${meal.mealType.label.toUpperCase()} · $day $hour:$min',
                              icon: _iconForMealType(meal.mealType),
                            ),
                          ),
                        );
                      }),

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

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.chipActive : AppTheme.chipInactive,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent
                : AppTheme.divider.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppTheme.accent : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildMealHistoryItem({
    required String title,
    required String nutrition,
    required String timestamp,
    required IconData icon,
  }) {
    return Container(
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
    );
  }
}
