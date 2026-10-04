import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../providers/app_state.dart';
import '../models/meal.dart';

class TextLoggingScreen extends StatefulWidget {
  const TextLoggingScreen({super.key});

  @override
  State<TextLoggingScreen> createState() => _TextLoggingScreenState();
}

class _TextLoggingScreenState extends State<TextLoggingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnalyzing = false;

  final List<String> _suggestions = [
    'Oats with milk & honey',
    'Grilled chicken with brown rice',
    '2 boiled eggs & whole wheat toast',
    'Whey protein shake with banana',
    'Paneer bhurji with 2 rotis',
    'Greek yogurt with almonds',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSuggestion(String text) {
    setState(() {
      if (_controller.text.isEmpty) {
        _controller.text = text;
      } else {
        _controller.text = '${_controller.text}, $text';
      }
    });
  }

  Future<void> _handleAnalyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please describe what you ate first.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final mealType = MealTypeLabel.fromHour(DateTime.now().hour);

      await appState.analyzeMealText(text, mealType: mealType);

      if (mounted) {
        setState(() => _isAnalyzing = false);
        Navigator.of(context).pushNamed('/meal-analysis');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Analysis error: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recentMeals = state.meals.reversed.take(4).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'What did you eat?',
              overline: 'Log with words',
              showBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us naturally. GymBuddy will turn your meal into calories and macros.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Meal description input area
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgInput,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.divider.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              expands: true,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Example: 2 eggs, 2 chapatis and a glass of milk',
                                hintStyle: GoogleFonts.inter(
                                  color: AppTheme.textDim,
                                  fontSize: 14,
                                ),
                              ),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_controller.text.length} / 500',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textDim,
                                ),
                              ),
                              if (_controller.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _controller.clear()),
                                  child: const Icon(Icons.clear_rounded,
                                      color: AppTheme.textMuted, size: 18),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary Button: AI Analyze
                    ElevatedButton(
                      onPressed: _isAnalyzing ? null : _handleAnalyze,
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
                          if (_isAnalyzing) ...[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accentText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Analyzing with AI...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentText,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.auto_awesome_rounded,
                                color: AppTheme.accentText, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'AI Analyze',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Try a quick suggestion
                    Text(
                      'Try a quick suggestion',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions
                          .map(
                            (s) => GestureDetector(
                              onTap: () => _addSuggestion(s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.chipInactive,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: AppTheme.divider
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      s,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.add,
                                        color: AppTheme.accent, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Recent foods
                    if (recentMeals.isNotEmpty) ...[
                      Text(
                        'Recent meals',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recentMeals.map((m) => _buildRecentFoodRow(
                            m.mealName,
                            '${m.nutrition.calories} kcal · ${m.nutrition.proteinG}g protein',
                            onTap: () => _addSuggestion(m.mealName),
                          )),
                    ],
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

  Widget _buildRecentFoodRow(String name, String meta,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: AppTheme.divider.withValues(alpha: 0.3))),
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
                  meta,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const Icon(Icons.add_circle_outline_rounded,
                color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
