import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

/// Calls Gemini 3.8 Flash to analyse a meal from bytes or text description
/// Returns a structured NutritionEstimate parsed from the model's JSON reply.
class GeminiService {
  static const String _model = 'gemini-3.8-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final String apiKey;

  GeminiService(this.apiKey);

  // ── System prompt (same spirit as prompts.py) ────────────────────────────
  static const String _systemPrompt = '''
You are GymBuddy, a precise AI nutrition analyst.
Your ONLY job is to estimate the nutritional content of meals from photos or text descriptions.
When analysing a meal, always respond with a VALID JSON object in this exact schema:
{
  "mealName": "string – short descriptive meal name",
  "servingSize": "string – e.g. '1 bowl · ~355g'",
  "calories": integer,
  "proteinG": integer,
  "carbsG": integer,
  "fatG": integer,
  "confidencePercent": integer (60-98),
  "ingredients": [
    {
      "name": "string",
      "portionDescription": "string – e.g. '110g grilled breast'",
      "calories": integer,
      "proteinG": integer,
      "carbsG": integer,
      "fatG": integer
    }
  ]
}
Do NOT include any text before or after the JSON. Only return the raw JSON object.
If asked something unrelated to food, respond with:
{"error": "I can only analyse meals and nutrition."}
''';

  // ── MEAL PHOTO ANALYSIS ───────────────────────────────────────────────────
  Future<GeminiResult> analyzeMealFromBytes(Uint8List imageBytes,
      {String mimeType = 'image/jpeg'}) async {
    final b64 = base64Encode(imageBytes);
    const prompt = 'Analyse this meal photo and return nutrition JSON.';

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'inline_data': {'mime_type': mimeType, 'data': b64}
            },
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 1024}
    });

    return _callGemini(body);
  }

  // ── MEAL TEXT ANALYSIS ────────────────────────────────────────────────────
  Future<GeminiResult> analyzeMealFromText(String description) async {
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  'Estimate nutrition for this meal: $description. Return JSON.'
            }
          ]
        }
      ],
      'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 1024}
    });

    return _callGemini(body);
  }

  // ── CHAT / Q&A ────────────────────────────────────────────────────────────
  Future<String> chat(List<Map<String, String>> history, String userMessage,
      {required List<MealEntry> todayMeals}) async {
    // Build context about today's meals for grounding
    String mealContext = '';
    if (todayMeals.isNotEmpty) {
      final lines = todayMeals
          .map((m) =>
              '${m.mealType.label}: ${m.mealName} — ${m.nutrition.calories} kcal, '
              '${m.nutrition.proteinG}g P, ${m.nutrition.carbsG}g C, ${m.nutrition.fatG}g F')
          .join('\n');
      mealContext =
          '\n\nToday\'s logged meals for context:\n$lines\n\nAnswer the user\'s question about their nutrition. Be concise and helpful.';
    }

    const chatSystem =
        'You are GymBuddy AI, a friendly nutrition copilot. Help users understand their diet and reach their fitness goals. Keep replies concise and supportive.';

    final contents = <Map<String, dynamic>>[];

    // Add conversation history (last 10 turns max)
    final recentHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;
    for (final msg in recentHistory) {
      contents.add({
        'role': msg['role'],
        'parts': [
          {'text': msg['text']!}
        ]
      });
    }

    // Add current user message with meal context
    contents.add({
      'role': 'user',
      'parts': [
        {'text': '$userMessage$mealContext'}
      ]
    });

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': chatSystem}
        ]
      },
      'contents': contents,
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512}
    });

    final result = await _callGemini(body, raw: true);
    return result.rawText ?? 'Sorry, I could not generate a response.';
  }

  // ── DAILY SUMMARY (for WhatsApp) ─────────────────────────────────────────
  Future<String> generateDailySummary(
      List<MealEntry> meals, String userName) async {
    if (meals.isEmpty) {
      return 'No meals logged today, $userName. Start by scanning a meal! 🏋️';
    }

    final mealLines = meals
        .map((m) =>
            '• ${m.mealType.label}: ${m.mealName} — ${m.nutrition.calories} kcal, '
            '${m.nutrition.proteinG}g P, ${m.nutrition.carbsG}g C, ${m.nutrition.fatG}g F')
        .join('\n');

    final totalCal = meals.fold(0, (s, m) => s + m.nutrition.calories);
    final totalP = meals.fold(0, (s, m) => s + m.nutrition.proteinG);
    final totalC = meals.fold(0, (s, m) => s + m.nutrition.carbsG);
    final totalF = meals.fold(0, (s, m) => s + m.nutrition.fatG);

    final prompt =
        'Generate a friendly WhatsApp-ready daily nutrition summary for $userName. '
        'Keep it short, plain text, 2-3 emojis, no markdown.\n\n'
        'Meals today:\n$mealLines\n\n'
        'Totals: $totalCal kcal | ${totalP}g protein | ${totalC}g carbs | ${totalF}g fat\n\n'
        'Include an encouraging message at the end.';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {'temperature': 0.6, 'maxOutputTokens': 512}
    });

    final result = await _callGemini(body, raw: true);
    return result.rawText ??
        'GymBuddy Summary for $userName:\n$mealLines\n\nTotal: $totalCal kcal 💪';
  }

  // ── INTERNAL HTTP CALL ────────────────────────────────────────────────────
  Future<GeminiResult> _callGemini(String body, {bool raw = false}) async {
    final uri = Uri.parse(
        '$_baseUrl/$_model:generateContent?key=$apiKey');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text =
        decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

    if (text == null) {
      throw Exception('No text in Gemini response');
    }

    if (raw) {
      return GeminiResult(rawText: text);
    }

    // Strip markdown fences if present
    final cleaned =
        text.replaceAll(RegExp(r'```json\s*'), '').replaceAll('```', '').trim();

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        return GeminiResult(error: json['error'] as String);
      }

      final estimate = NutritionEstimate(
        calories: (json['calories'] as num).toInt(),
        proteinG: (json['proteinG'] as num).toInt(),
        carbsG: (json['carbsG'] as num).toInt(),
        fatG: (json['fatG'] as num).toInt(),
        confidencePercent: (json['confidencePercent'] as num?)?.toDouble() ?? 85,
        servingSize: json['servingSize'] as String? ?? '1 serving',
        ingredients: (json['ingredients'] as List? ?? [])
            .map((i) => IngredientItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

      return GeminiResult(
        estimate: estimate,
        mealName: json['mealName'] as String? ?? 'Unknown Meal',
      );
    } catch (e) {
      throw Exception('Failed to parse Gemini JSON: $e\n\nRaw: $cleaned');
    }
  }
}

class GeminiResult {
  final NutritionEstimate? estimate;
  final String? mealName;
  final String? error;
  final String? rawText;

  GeminiResult({this.estimate, this.mealName, this.error, this.rawText});
}
