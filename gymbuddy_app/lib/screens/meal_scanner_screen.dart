import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../providers/app_state.dart';
import '../models/meal.dart';

class MealScannerScreen extends StatefulWidget {
  const MealScannerScreen({super.key});

  @override
  State<MealScannerScreen> createState() => _MealScannerScreenState();
}

class _MealScannerScreenState extends State<MealScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _flashOn = false;
  String _selectedMode = 'Photo';
  bool _isProcessing = false;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _handleImageCapture(ImageSource source) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) return;

      setState(() => _isProcessing = true);

      final bytes = await photo.readAsBytes();
      if (!mounted) return;

      final appState = Provider.of<AppState>(context, listen: false);

      // Determine meal type by time of day
      final mealType = MealTypeLabel.fromHour(DateTime.now().hour);

      await appState.analyzeMealPhoto(bytes, mealType: mealType);

      if (mounted) {
        setState(() => _isProcessing = false);
        navigator.pushNamed('/meal-analysis');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        messenger.showSnackBar(
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
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Scan your meal.',
              overline: 'AI meal scanner',
              showBack: Navigator.of(context).canPop(),
              trailingAction: IconButton(
                onPressed: () => setState(() => _flashOn = !_flashOn),
                icon: Icon(
                  _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _flashOn ? AppTheme.accent : AppTheme.textMuted,
                  size: 22,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Point. Capture. Know your nutrition. Keep your whole plate inside the frame for best results.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Camera Viewport
                    Container(
                      height: 340,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.divider, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Aesthetic background
                            Container(
                              decoration: const BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [Color(0xFF141416), Colors.black],
                                  radius: 0.8,
                                ),
                              ),
                            ),

                            // Camera framing corners
                            CustomPaint(
                              size: const Size(260, 240),
                              painter: _ReticlePainter(),
                            ),

                            // Animated scan beam
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: 340 * _scanAnimation.value,
                                  left: 40,
                                  right: 40,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accent
                                              .withValues(alpha: 0.8),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Top framing hint
                            Positioned(
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: Text(
                                  'One plate. Better accuracy.',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),

                            // Bottom camera live indicator
                            Positioned(
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppTheme.divider
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isProcessing
                                          ? 'ANALYZING...'
                                          : 'LIVE CAMERA',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _isProcessing
                                            ? AppTheme.accent
                                            : AppTheme.textPrimary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Loading overlay
                            if (_isProcessing)
                              Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Capture modes chips
                    Row(
                      children: [
                        _buildModeChip('Photo'),
                        const SizedBox(width: 10),
                        _buildModeChip('AI assisted'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Scanner explanation
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppTheme.purple, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'AI will estimate calories and macros',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Capture Actions
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleImageCapture(ImageSource.camera),
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
                          const Icon(Icons.camera_alt_rounded,
                              color: AppTheme.accentText, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isProcessing ? 'Analyzing...' : 'Take Photo',
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

                    OutlinedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleImageCapture(ImageSource.gallery),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppTheme.bgCard,
                        side: BorderSide(
                            color: AppTheme.divider.withValues(alpha: 0.8)),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_outlined,
                              color: AppTheme.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Upload From Gallery',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Good lighting helps. You can adjust ingredients and portions after scanning.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDim,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Text logging alternative action
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/text-logging'),
                      child: Text(
                        'Prefer typing? Log with words →',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accent,
                        ),
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

  Widget _buildModeChip(String label) {
    final isSelected = _selectedMode == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = label),
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
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
