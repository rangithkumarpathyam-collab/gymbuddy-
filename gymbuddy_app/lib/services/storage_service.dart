import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';

/// Persists all app data locally using SharedPreferences.
/// Keys are namespaced with 'gb_' prefix.
class StorageService {
  static const _kProfile = 'gb_profile';
  static const _kMeals = 'gb_meals';
  static const _kChat = 'gb_chat';
  static const _kWeights = 'gb_weights';

  // ── USER PROFILE ──────────────────────────────────────────────────────────
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw));
  }

  Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfile);
  }

  // ── MEAL ENTRIES ──────────────────────────────────────────────────────────
  Future<void> saveMeals(List<MealEntry> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(meals.map((m) => m.toJson()).toList());
    await prefs.setString(_kMeals, encoded);
  }

  Future<List<MealEntry>> loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMeals);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((j) => MealEntry.fromJson(j)).toList();
  }

  Future<void> addMeal(MealEntry meal, List<MealEntry> existing) async {
    final updated = [...existing, meal];
    await saveMeals(updated);
  }

  Future<void> deleteMeal(String id, List<MealEntry> existing) async {
    final updated = existing.where((m) => m.id != id).toList();
    await saveMeals(updated);
  }

  // ── CHAT HISTORY ──────────────────────────────────────────────────────────
  Future<void> saveChat(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_kChat, encoded);
  }

  Future<List<ChatMessage>> loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kChat);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((j) => ChatMessage.fromJson(j)).toList();
  }

  Future<void> clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kChat);
  }

  // ── WEIGHT LOG ────────────────────────────────────────────────────────────
  Future<void> saveWeights(List<WeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kWeights, encoded);
  }

  Future<List<WeightEntry>> loadWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kWeights);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((j) => WeightEntry.fromJson(j)).toList();
  }

  Future<void> addWeight(WeightEntry entry, List<WeightEntry> existing) async {
    final updated = [...existing, entry];
    await saveWeights(updated);
  }

  // ── RESET ALL ─────────────────────────────────────────────────────────────
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
