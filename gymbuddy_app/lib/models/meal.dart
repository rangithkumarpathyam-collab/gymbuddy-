// Mirrors the AI-parsed response from Gemini
class NutritionEstimate {
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<IngredientItem> ingredients;
  final double confidencePercent;
  final String servingSize;

  const NutritionEstimate({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.ingredients,
    this.confidencePercent = 85,
    this.servingSize = '1 serving',
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'confidencePercent': confidencePercent,
        'servingSize': servingSize,
      };

  factory NutritionEstimate.fromJson(Map<String, dynamic> j) =>
      NutritionEstimate(
        calories: j['calories'],
        proteinG: j['proteinG'],
        carbsG: j['carbsG'],
        fatG: j['fatG'],
        ingredients: (j['ingredients'] as List)
            .map((i) => IngredientItem.fromJson(i))
            .toList(),
        confidencePercent: (j['confidencePercent'] as num?)?.toDouble() ?? 85,
        servingSize: j['servingSize'] ?? '1 serving',
      );
}

class IngredientItem {
  final String name;
  final String portionDescription;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  const IngredientItem({
    required this.name,
    required this.portionDescription,
    required this.calories,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'portionDescription': portionDescription,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };

  factory IngredientItem.fromJson(Map<String, dynamic> j) => IngredientItem(
        name: j['name'],
        portionDescription: j['portionDescription'] ?? '',
        calories: j['calories'],
        proteinG: j['proteinG'] ?? 0,
        carbsG: j['carbsG'] ?? 0,
        fatG: j['fatG'] ?? 0,
      );
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeLabel on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  static MealType fromHour(int hour) {
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 18) return MealType.snack;
    return MealType.dinner;
  }
}

class MealEntry {
  final String id;
  final String mealName;
  final NutritionEstimate nutrition;
  final DateTime timestamp;
  final MealType mealType;
  final String? imagePath; // local path after saving
  final String source; // 'camera' | 'gallery' | 'text'

  MealEntry({
    required this.id,
    required this.mealName,
    required this.nutrition,
    required this.timestamp,
    required this.mealType,
    this.imagePath,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealName': mealName,
        'nutrition': nutrition.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'mealType': mealType.name,
        'imagePath': imagePath,
        'source': source,
      };

  factory MealEntry.fromJson(Map<String, dynamic> j) => MealEntry(
        id: j['id'],
        mealName: j['mealName'],
        nutrition: NutritionEstimate.fromJson(j['nutrition']),
        timestamp: DateTime.parse(j['timestamp']),
        mealType: MealType.values.firstWhere((e) => e.name == j['mealType'],
            orElse: () => MealType.snack),
        imagePath: j['imagePath'],
        source: j['source'] ?? 'camera',
      );
}

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime timestamp;
  final String? highlightValue; // optional large number to display e.g. "64g protein today"

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.highlightValue,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'highlightValue': highlightValue,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        role: j['role'],
        text: j['text'],
        timestamp: DateTime.parse(j['timestamp']),
        highlightValue: j['highlightValue'],
      );
}

class WeightEntry {
  final DateTime date;
  final double weightKg;

  WeightEntry({required this.date, required this.weightKg});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
        date: DateTime.parse(j['date']),
        weightKg: (j['weightKg'] as num).toDouble(),
      );
}
