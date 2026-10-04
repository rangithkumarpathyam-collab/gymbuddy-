// ============================================================
// lib/models/user_profile.dart
// ============================================================

class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double weightKg;
  final double heightCm;
  final String fitnessGoal; // 'Build muscle' | 'Lose fat' | 'Maintain'
  final String activityLevel;
  final String whatsappNumber;
  final int targetCalories;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;
  final DateTime memberSince;

  const UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.whatsappNumber,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
    required this.memberSince,
  });

  /// Mifflin-St Jeor BMR → TDEE → goal-adjusted targets
  factory UserProfile.withCalculatedTargets({
    required String name,
    required int age,
    required String gender,
    required double weightKg,
    required double heightCm,
    required String fitnessGoal,
    required String activityLevel,
    required String whatsappNumber,
  }) {
    // BMR
    double bmr = gender.toLowerCase() == 'male'
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    // Activity multiplier
    const multipliers = {
      'Sedentary (desk job)': 1.2,
      'Lightly active (1-2 days)': 1.375,
      'Moderately active': 1.55,
      'Very active (6-7 days)': 1.725,
    };
    final tdee = bmr * (multipliers[activityLevel] ?? 1.55);

    // Goal adjustment
    int calories;
    if (fitnessGoal == 'Build muscle') {
      calories = (tdee + 250).round();
    } else if (fitnessGoal == 'Lose fat') {
      calories = (tdee - 500).round();
    } else {
      calories = tdee.round();
    }

    // Macro splits
    final proteinG = (weightKg * 2.0).round(); // 2g / kg
    final fatG = ((calories * 0.25) / 9).round(); // 25% kcal from fat
    final carbsG = ((calories - proteinG * 4 - fatG * 9) / 4).round();

    return UserProfile(
      name: name,
      age: age,
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      fitnessGoal: fitnessGoal,
      activityLevel: activityLevel,
      whatsappNumber: whatsappNumber,
      targetCalories: calories,
      targetProteinG: proteinG,
      targetCarbsG: carbsG,
      targetFatG: fatG,
      memberSince: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'fitnessGoal': fitnessGoal,
        'activityLevel': activityLevel,
        'whatsappNumber': whatsappNumber,
        'targetCalories': targetCalories,
        'targetProteinG': targetProteinG,
        'targetCarbsG': targetCarbsG,
        'targetFatG': targetFatG,
        'memberSince': memberSince.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'],
        age: j['age'],
        gender: j['gender'],
        weightKg: (j['weightKg'] as num).toDouble(),
        heightCm: (j['heightCm'] as num).toDouble(),
        fitnessGoal: j['fitnessGoal'],
        activityLevel: j['activityLevel'],
        whatsappNumber: j['whatsappNumber'],
        targetCalories: j['targetCalories'],
        targetProteinG: j['targetProteinG'],
        targetCarbsG: j['targetCarbsG'],
        targetFatG: j['targetFatG'],
        memberSince: DateTime.parse(j['memberSince']),
      );

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? fitnessGoal,
    String? activityLevel,
    String? whatsappNumber,
    int? targetCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
  }) =>
      UserProfile(
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        fitnessGoal: fitnessGoal ?? this.fitnessGoal,
        activityLevel: activityLevel ?? this.activityLevel,
        whatsappNumber: whatsappNumber ?? this.whatsappNumber,
        targetCalories: targetCalories ?? this.targetCalories,
        targetProteinG: targetProteinG ?? this.targetProteinG,
        targetCarbsG: targetCarbsG ?? this.targetCarbsG,
        targetFatG: targetFatG ?? this.targetFatG,
        memberSince: memberSince,
      );
}
