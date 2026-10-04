import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../providers/app_state.dart';
import '../models/meal.dart';

class MealAnalysisScreen extends StatefulWidget {
  const MealAnalysisScreen({super.key});

  @override
  State<MealAnalysisScreen> createState() => _MealAnalysisScreenState();
}

class _MealAnalysisScreenState extends State<MealAnalysisScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final result = state.lastAnalysisResult;

    // Fallback estimate if opened directly
    final estimate = result?.estimate ??
        const NutritionEstimate(
          calories: 440,
          proteinG: 42,
          carbsG: 50,
          fatG: 8,
          confidencePercent: 94,
          servingSize: '1 bowl · estimated serving 355g',
          ingredients: [
            IngredientItem(
              name: 'Chicken',
              portionDescription: '110g · grilled breast',
              calories: 180,
              proteinG: 34,
              carbsG: 0,
              fatG: 4,
            ),
            IngredientItem(
              name: 'Rice',
              portionDescription: '125g · cooked white rice',
              calories: 160,
              proteinG: 3,
              carbsG: 36,
              fatG: 1,
            ),
            IngredientItem(
              name: 'Vegetables',
              portionDescription: '100g · broccoli & carrots',
              calories: 40,
              proteinG: 3,
              carbsG: 8,
              fatG: 0,
            ),
            IngredientItem(
              name: 'Sauce',
              portionDescription: '20g · sesame dressing',
              calories: 60,
              proteinG: 2,
              carbsG: 6,
              fatG: 3,
            ),
          ],
        );

    final mealName = result?.mealName ?? 'Grilled Chicken Rice Bowl';
    final imageBytes = state.lastAnalyzedImageBytes;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Your meal, decoded.',
              overline: 'Meal analysis',
              showBack: true,
              trailingAction: Icon(Icons.more_horiz_rounded,
                  color: AppTheme.textPrimary, size: 24),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal photograph
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C2419), Color(0xFF161412)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.6)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (imageBytes != null)
                              Image.memory(
                                imageBytes,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              )
                            else
                              Icon(
                                Icons.restaurant_rounded,
                                size: 64,
                                color: AppTheme.accent.withValues(alpha: 0.5),
                              ),
                            Positioned(
                              bottom: 12,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppTheme.green, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Confidence ${(estimate.confidencePercent).toInt()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Meal Identity
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppTheme.purple, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'AI-generated nutritional estimate',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.purple,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mealName,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estimate.servingSize,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Calories & Macros Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                estimate.calories.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'kcal',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textMuted,
                                ),
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
                              _buildMacroEstimate('${estimate.proteinG}g',
                                  'Protein', AppTheme.accent),
                              _buildMacroEstimate('${estimate.carbsG}g',
                                  'Carbs', AppTheme.textPrimary),
                              _buildMacroEstimate(
                                  '${estimate.fatG}g', 'Fat', AppTheme.purple),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ingredient breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'What’s inside',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${estimate.ingredients.length} ingredients',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    ...estimate.ingredients.map((ing) => _buildIngredientRow(
                          ing.name,
                          ing.portionDescription,
                          '${ing.calories} kcal',
                        )),

                    const SizedBox(height: 24),

                    // Actions
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              setState(() => _isSaving = true);
                              await state.confirmAndSaveMeal(
                                mealName: mealName,
                                nutrition: estimate,
                              );
                              if (mounted) {
                                setState(() => _isSaving = false);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$mealName added to today!',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.bg,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: AppTheme.accent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                );
                                navigator.pushReplacementNamed('/home');
                              }
                            },
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
                          const Icon(Icons.add_rounded,
                              color: AppTheme.accentText, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isSaving ? 'Adding...' : 'Add to Today',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Estimates may vary by recipe and portion. Review before adding to your totals.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDim,
                        height: 1.4,
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

  Widget _buildMacroEstimate(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(String name, String portion, String calories) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                portion,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textDim,
                ),
              ),
            ],
          ),
          Text(
            calories,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
