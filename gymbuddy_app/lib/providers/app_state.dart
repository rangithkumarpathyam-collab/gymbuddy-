import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../services/gemini_service.dart';
import '../services/twilio_service.dart';
import '../services/storage_service.dart';
import '../services/app_config.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  late final GeminiService _gemini;
  late final TwilioService _twilio;

  UserProfile? _userProfile;
  List<MealEntry> _meals = [];
  List<ChatMessage> _chatMessages = [];
  List<WeightEntry> _weightHistory = [];
  int _waterGlasses = 4; // default initial for today
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Staging for meal analysis screen
  GeminiResult? _lastAnalysisResult;
  Uint8List? _lastAnalyzedImageBytes;
  MealType _pendingMealType = MealType.lunch;

  AppState() {
    _gemini = GeminiService(AppConfig.geminiApiKey);
    _twilio = TwilioService(
      accountSid: AppConfig.twilioAccountSid,
      authToken: AppConfig.twilioAuthToken,
      fromNumber: AppConfig.twilioWhatsappFrom,
      contentSid: AppConfig.twilioContentSid,
    );
  }

  // ── GETTERS ─────────────────────────────────────────────────────────────
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  bool get isOnboarded => _userProfile != null;
  List<MealEntry> get meals => List.unmodifiable(_meals);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  List<WeightEntry> get weightHistory => List.unmodifiable(_weightHistory);
  int get waterGlasses => _waterGlasses;
  double get waterLiters => _waterGlasses * 0.25;

  GeminiResult? get lastAnalysisResult => _lastAnalysisResult;
  Uint8List? get lastAnalyzedImageBytes => _lastAnalyzedImageBytes;
  MealType get pendingMealType => _pendingMealType;

  // Today's meals
  List<MealEntry> get todayMeals {
    final now = DateTime.now();
    return _meals.where((m) {
      return m.timestamp.year == now.year &&
          m.timestamp.month == now.month &&
          m.timestamp.day == now.day;
    }).toList();
  }

  int get todayCalories =>
      todayMeals.fold(0, (sum, m) => sum + m.nutrition.calories);
  int get todayProtein =>
      todayMeals.fold(0, (sum, m) => sum + m.nutrition.proteinG);
  int get todayCarbs =>
      todayMeals.fold(0, (sum, m) => sum + m.nutrition.carbsG);
  int get todayFat =>
      todayMeals.fold(0, (sum, m) => sum + m.nutrition.fatG);

  int get targetCalories => _userProfile?.targetCalories ?? 2200;
  int get targetProtein => _userProfile?.targetProteinG ?? 150;
  int get targetCarbs => _userProfile?.targetCarbsG ?? 220;
  int get targetFat => _userProfile?.targetFatG ?? 65;

  int get remainingCalories =>
      (targetCalories - todayCalories).clamp(0, 99999);

  double get calorieProgress => targetCalories > 0
      ? (todayCalories / targetCalories).clamp(0.0, 1.0)
      : 0.0;
  double get proteinProgress => targetProtein > 0
      ? (todayProtein / targetProtein).clamp(0.0, 1.0)
      : 0.0;
  double get carbsProgress =>
      targetCarbs > 0 ? (todayCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;
  double get fatProgress =>
      targetFat > 0 ? (todayFat / targetFat).clamp(0.0, 1.0) : 0.0;

  // ── INITIALIZATION ───────────────────────────────────────────────────────
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _storage.loadProfile();
      _meals = await _storage.loadMeals();
      _chatMessages = await _storage.loadChat();
      _weightHistory = await _storage.loadWeights();

      // If weight history is empty but user profile exists, seed initial weight
      if (_weightHistory.isEmpty && _userProfile != null) {
        _weightHistory.add(
          WeightEntry(
            date: _userProfile!.memberSince,
            weightKg: _userProfile!.weightKg,
          ),
        );
        await _storage.saveWeights(_weightHistory);
      }

      // If chat messages are empty, seed welcoming message
      if (_chatMessages.isEmpty) {
        _chatMessages.add(
          ChatMessage(
            role: 'assistant',
            text:
                "Hey! I'm your GymBuddy nutrition copilot. Ask me anything about your meals, macros, or what to eat next!",
            timestamp: DateTime.now(),
          ),
        );
        await _storage.saveChat(_chatMessages);
      }
    } catch (e) {
      _errorMessage = 'Failed to load app data: $e';
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── ONBOARDING & PROFILE ─────────────────────────────────────────────────
  Future<void> onboardUser(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    _userProfile = profile;
    await _storage.saveProfile(profile);

    // Add initial weight log
    _weightHistory = [
      WeightEntry(date: DateTime.now(), weightKg: profile.weightKg)
    ];
    await _storage.saveWeights(_weightHistory);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storage.saveProfile(profile);
    notifyListeners();
  }

  // ── MEAL ANALYSIS ────────────────────────────────────────────────────────
  void setPendingMealType(MealType type) {
    _pendingMealType = type;
    notifyListeners();
  }

  Future<GeminiResult> analyzeMealPhoto(Uint8List imageBytes,
      {MealType? mealType}) async {
    _isLoading = true;
    _errorMessage = null;
    if (mealType != null) _pendingMealType = mealType;
    _lastAnalyzedImageBytes = imageBytes;
    notifyListeners();

    try {
      final result = await _gemini.analyzeMealFromBytes(imageBytes);
      _lastAnalysisResult = result;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Meal analysis failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<GeminiResult> analyzeMealText(String description,
      {MealType? mealType}) async {
    _isLoading = true;
    _errorMessage = null;
    if (mealType != null) _pendingMealType = mealType;
    _lastAnalyzedImageBytes = null;
    notifyListeners();

    try {
      final result = await _gemini.analyzeMealFromText(description);
      _lastAnalysisResult = result;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Text meal analysis failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> confirmAndSaveMeal({
    required String mealName,
    required NutritionEstimate nutrition,
    MealType? mealType,
    String source = 'camera',
  }) async {
    final entry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealName: mealName,
      nutrition: nutrition,
      timestamp: DateTime.now(),
      mealType: mealType ?? _pendingMealType,
      source: source,
    );

    _meals.add(entry);
    await _storage.saveMeals(_meals);

    // Clear staging
    _lastAnalysisResult = null;
    _lastAnalyzedImageBytes = null;
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((m) => m.id == id);
    await _storage.saveMeals(_meals);
    notifyListeners();
  }

  // ── WATER TRACKING ───────────────────────────────────────────────────────
  void addWaterGlass() {
    _waterGlasses = (_waterGlasses + 1).clamp(0, 20);
    notifyListeners();
  }

  void removeWaterGlass() {
    _waterGlasses = (_waterGlasses - 1).clamp(0, 20);
    notifyListeners();
  }

  // ── CHAT ─────────────────────────────────────────────────────────────────
  Future<String> sendChatMessage(String text) async {
    // Add user message
    final userMsg = ChatMessage(
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMsg);
    notifyListeners();

    try {
      final history = _chatMessages
          .map((m) => {'role': m.role, 'text': m.text})
          .toList();

      final responseText = await _gemini.chat(
        history,
        text,
        todayMeals: todayMeals,
      );

      final botMsg = ChatMessage(
        role: 'assistant',
        text: responseText,
        timestamp: DateTime.now(),
      );
      _chatMessages.add(botMsg);
      await _storage.saveChat(_chatMessages);
      notifyListeners();
      return responseText;
    } catch (e) {
      final errorMsg = ChatMessage(
        role: 'assistant',
        text: 'Sorry, I ran into an error connecting to AI: $e',
        timestamp: DateTime.now(),
      );
      _chatMessages.add(errorMsg);
      notifyListeners();
      return errorMsg.text;
    }
  }

  // ── WHATSAPP SUMMARY ─────────────────────────────────────────────────────
  Future<String> generateWhatsAppText() async {
    final name = _userProfile?.name ?? 'Champ';
    return await _gemini.generateDailySummary(todayMeals, name);
  }

  Future<TwilioResult> sendWhatsAppSummary({String? customPhone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final phone = customPhone ?? _userProfile?.whatsappNumber ?? '';
      if (phone.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return const TwilioResult(
            success: false, error: 'No WhatsApp phone number provided.');
      }

      final name = _userProfile?.name ?? 'Champ';
      final summaryText = await _gemini.generateDailySummary(todayMeals, name);

      final result = await _twilio.sendSummary(
        toNumber: phone,
        userName: name,
        summary: summaryText,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return TwilioResult(success: false, error: e.toString());
    }
  }

  // ── WEIGHT TRACKING ──────────────────────────────────────────────────────
  Future<void> logWeight(double weightKg) async {
    final entry = WeightEntry(date: DateTime.now(), weightKg: weightKg);
    _weightHistory.add(entry);
    await _storage.saveWeights(_weightHistory);

    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(weightKg: weightKg);
      await _storage.saveProfile(_userProfile!);
    }
    notifyListeners();
  }

  // ── RESET ────────────────────────────────────────────────────────────────
  Future<void> resetAllData() async {
    await _storage.resetAll();
    _userProfile = null;
    _meals = [];
    _chatMessages = [];
    _weightHistory = [];
    _waterGlasses = 4;
    notifyListeners();
  }
}
