import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../models/user_profile.dart';
import '../providers/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Arjun Mehta');
  final TextEditingController _ageController = TextEditingController(text: '28');
  final TextEditingController _weightController = TextEditingController(text: '78');
  final TextEditingController _heightController = TextEditingController(text: '180');
  final TextEditingController _phoneController = TextEditingController(text: '+91 98765 43210');

  String _gender = 'Male';
  String _fitnessGoal = 'Build muscle';
  String _activityLevel = 'Moderately active';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Make it personal.',
              overline: 'Your nutrition blueprint',
              showBack: true,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Setup progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '8 / 8 · Profile details',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                        Text(
                          'Ready to continue',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 4,
                        width: double.infinity,
                        color: AppTheme.divider,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0,
                          child: Container(color: AppTheme.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A few details. A smarter daily target. Built around your body and your goals.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    _buildLabel('Name'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _nameController,
                      hint: 'Your name',
                    ),
                    const SizedBox(height: 16),

                    // Age & Gender
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Age'),
                              const SizedBox(height: 6),
                              _buildInputField(
                                controller: _ageController,
                                hint: '28 years',
                                suffixText: 'yrs',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Gender'),
                              const SizedBox(height: 6),
                              _buildDropdownField(
                                value: _gender,
                                items: const ['Male', 'Female', 'Other'],
                                onChanged: (val) => setState(() => _gender = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weight & Height
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Weight'),
                              const SizedBox(height: 6),
                              _buildInputField(
                                controller: _weightController,
                                hint: '78 kg',
                                suffixText: 'kg',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Height'),
                              const SizedBox(height: 6),
                              _buildInputField(
                                controller: _heightController,
                                hint: '180 cm',
                                suffixText: 'cm',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Fitness goal chips
                    _buildLabel('Fitness goal'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildGoalChip('Build muscle'),
                        const SizedBox(width: 10),
                        _buildGoalChip('Lose fat'),
                        const SizedBox(width: 10),
                        _buildGoalChip('Maintain'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Daily activity level
                    _buildLabel('Daily activity level'),
                    const SizedBox(height: 6),
                    _buildDropdownField(
                      value: _activityLevel,
                      items: const [
                        'Sedentary (desk job)',
                        'Lightly active (1-2 days)',
                        'Moderately active',
                        'Very active (6-7 days)',
                      ],
                      onChanged: (val) => setState(() => _activityLevel = val!),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Training 3–5 days a week',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // WhatsApp Number
                    _buildLabel('WhatsApp number'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _phoneController,
                      hint: '+91 98765 43210',
                      suffixIcon: const Icon(Icons.phone_rounded, color: AppTheme.textMuted, size: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your daily report, only when you choose to send it.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Privacy reassurance
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppTheme.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your health data stays private. You’re always in control.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Continue button
                    ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text.trim().isEmpty ? 'Arjun Mehta' : _nameController.text.trim();
                        final age = int.tryParse(_ageController.text.trim()) ?? 28;
                        final weight = double.tryParse(_weightController.text.trim()) ?? 78.0;
                        final height = double.tryParse(_heightController.text.trim()) ?? 180.0;
                        final phone = _phoneController.text.trim().replaceAll(' ', '');

                        final profile = UserProfile.withCalculatedTargets(
                          name: name,
                          age: age,
                          gender: _gender,
                          weightKg: weight,
                          heightCm: height,
                          fitnessGoal: _fitnessGoal,
                          activityLevel: _activityLevel,
                          whatsappNumber: phone,
                        );

                        final navigator = Navigator.of(context);
                        await Provider.of<AppState>(context, listen: false).onboardUser(profile);

                        if (mounted) {
                          navigator.pushReplacementNamed('/home');
                        }
                      },
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
                          Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: AppTheme.accentText, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppTheme.textMuted,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: TextField(
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
            suffixText: suffixText,
            suffixStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: AppTheme.bgCard,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted, size: 20),
          isExpanded: true,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.textPrimary,
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGoalChip(String goal) {
    final isSelected = _fitnessGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _fitnessGoal = goal),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.chipActive : AppTheme.chipInactive,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.divider.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          goal,
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
