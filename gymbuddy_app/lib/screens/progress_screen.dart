import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../providers/app_state.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedPeriod = 'Week';

  final List<double> _weeklyCalories = [
    2400,
    2550,
    2300,
    2650,
    2480,
    2600,
    2260
  ];
  final List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _showLogWeightDialog(BuildContext context, AppState state) {
    final currentWeight = state.userProfile?.weightKg ?? 78.0;
    final controller =
        TextEditingController(text: currentWeight.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Today’s Weight',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your current weight in kilograms.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                suffixText: 'kg',
                suffixStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.accent,
                ),
                filled: true,
                fillColor: AppTheme.bgInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppTheme.divider.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 20 && val < 300) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await state.logWeight(val);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Weight logged: ${val.toStringAsFixed(1)} kg'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.accentText,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.userProfile;
    final currentWeight = profile?.weightKg ?? 78.0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Built on consistency.',
              overline: 'Your performance',
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
                    // Period selection chips
                    Row(
                      children: [
                        _buildPeriodChip('Week'),
                        const SizedBox(width: 8),
                        _buildPeriodChip('Month'),
                        const SizedBox(width: 8),
                        _buildPeriodChip('Year'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last 7 days performance',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weekly Summary 3 Cards
                    Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard(
                                'Target Cal', '${state.targetCalories}', 'kcal / day')),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildSummaryCard(
                                'Target Prot', '${state.targetProtein}', 'g / day')),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildSummaryCard(
                                'Goal', profile?.fitnessGoal ?? 'Muscle', 'focus')),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Weekly Calories Bar Chart Card
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weekly calories',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Target ${state.targetCalories} kcal',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textDim,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                7,
                                (index) {
                                  final val = _weeklyCalories[index];
                                  final ratio = (val / 3000).clamp(0.0, 1.0);
                                  final isHigh = val >= state.targetCalories;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 110 * ratio,
                                        decoration: BoxDecoration(
                                          color: isHigh
                                              ? AppTheme.accent
                                              : AppTheme.bgElevated,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isHigh
                                                ? AppTheme.accent
                                                : AppTheme.divider
                                                    .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _weekdays[index],
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isHigh
                                              ? AppTheme.textPrimary
                                              : AppTheme.textDim,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weight Trend Card
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weight trend',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Current: ${currentWeight.toStringAsFixed(1)} kg',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _TrendChartPainter(
                                values: state.weightHistory.isNotEmpty
                                    ? state.weightHistory
                                        .map((w) => w.weightKg)
                                        .toList()
                                    : [79.8, 79.4, 79.0, 78.5, currentWeight],
                                lineColor: AppTheme.purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tracking since ${profile?.memberSince.day ?? 1}/${profile?.memberSince.month ?? 10}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Primary Button: Log Today's Weight
                    ElevatedButton(
                      onPressed: () => _showLogWeightDialog(context, state),
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
                            'Log Today’s Weight',
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

  Widget _buildPeriodChip(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
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

  Widget _buildSummaryCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDim,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _TrendChartPainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce((a, b) => a < b ? a : b) - 0.5;
    final maxVal = values.reduce((a, b) => a > b ? a : b) + 0.5;
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()..color = lineColor;
    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
