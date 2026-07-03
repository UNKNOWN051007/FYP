import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/salary_prediction.dart';
import '../models/col_evaluation.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _user;
  String _language = 'en';
  int _tabIndex = 0;
  int _themeIndex = 1; // Light Day — user can switch via Profile > Appearance
  List<SalaryPrediction> _predictions = [];
  SalaryPrediction? _latestPrediction;
  bool _predictingSalary = false;
  String? _salaryError;
  List<ChatMessage> _messages = [];
  ChatModule _chatModule = ChatModule.labourRights;
  bool _chatLoading = false;
  String? _activeSessionId;
  List<ColEvaluation> _colResults = [];
  bool _colLoading = false;
  String? _colError;

  UserModel? get user => _user;
  String get language => _language;
  int get tabIndex => _tabIndex;
  int get themeIndex => _themeIndex;
  List<SalaryPrediction> get predictions => _predictions;
  SalaryPrediction? get latestPrediction => _latestPrediction;
  bool get predictingSalary => _predictingSalary;
  String? get salaryError => _salaryError;
  List<ChatMessage> get messages => _messages;
  ChatModule get chatModule => _chatModule;
  bool get chatLoading => _chatLoading;
  List<ColEvaluation> get colResults => _colResults;
  bool get colLoading => _colLoading;
  String? get colError => _colError;

  void setTab(int i) {
    _tabIndex = i;
    notifyListeners();
  }

  // ── Salary → COL cross-module linkage ─────────────────────────
  // Set when the salary screen wants to open the COL tab with a
  // pre-filled amount. Consumed (one-shot) by ColScreen.build.
  double? _colPrefill;
  String? _colPrefillCity;

  /// Jump to the Cost of Living tab with [gross] pre-filled (and
  /// optionally the predicted [city] pre-selected).
  void openColWithSalary(double gross, {String? city}) {
    _colPrefill = gross;
    _colPrefillCity = city;
    _tabIndex = 3; // COL tab
    notifyListeners();
  }

  /// One-shot getters — safe to call during build (no notify).
  double? takeColPrefill() {
    final v = _colPrefill;
    _colPrefill = null;
    return v;
  }

  String? takeColPrefillCity() {
    final v = _colPrefillCity;
    _colPrefillCity = null;
    return v;
  }

  Future<void> setTheme(int index) async {
    _themeIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
  }

  void setUser(UserModel? user) {
    _user = user;
    if (user != null) _language = user.languagePref;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    if (_user != null) {
      final updated = _user!.copyWith(languagePref: lang);
      _user = updated;
      try {
        await AuthService.updateProfile(updated);
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Wipes local state without calling AuthService.signOut().
  /// Used by the auth-stream listener so we don't double-call Supabase signOut.
  void clearUser() {
    _user = null;
    _predictions = [];
    _latestPrediction = null;
    _messages = [];
    _colResults = [];
    _activeSessionId = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await AuthService.signOut(); // fires signedOut event → stream listener clears state
    clearUser();
  }

  Future<void> init() async {
    // Load persisted theme before notifying so first frame uses correct theme.
    final prefs = await SharedPreferences.getInstance();
    _themeIndex = prefs.getInt('theme_index') ?? 1;

    try {
      final profile = await AuthService.getProfile();
      if (profile != null) {
        _user = profile;
        _language = profile.languagePref;
        _predictions = await SupabaseService.getPredictions();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> predictSalary({
    required String jobTitle,
    required String industry,
    required String educationLevel,
    required int yearsExperience,
    required String location,
  }) async {
    _predictingSalary = true;
    _salaryError = null;
    notifyListeners();
    try {
      final result = await ApiService.predictSalary(
        jobTitle: jobTitle,
        industry: industry,
        educationLevel: educationLevel,
        yearsExperience: yearsExperience,
        location: location,
      );
      _latestPrediction = result;
      _predictions = [result, ..._predictions];
      await SupabaseService.savePrediction(result);
    } catch (e) {
      _salaryError = e.toString();
    } finally {
      _predictingSalary = false;
      notifyListeners();
    }
  }

  Future<void> switchChatModule(ChatModule module) async {
    _chatModule = module;
    _messages = [];
    _activeSessionId = null;
    notifyListeners();
    // Session will be lazily created on first sendMessage to avoid
    // failures when user just browses tabs without sending anything.
    notifyListeners();
  }

  Future<String> _ensureSession() async {
    if (_activeSessionId != null) return _activeSessionId!;
    try {
      _activeSessionId = await SupabaseService.createChatSession(_chatModule.apiValue);
    } catch (_) {
      _activeSessionId = const Uuid().v4();
    }
    return _activeSessionId!;
  }

  /// Send a message, optionally with an attached file.
  Future<void> sendMessage(
    String content, {
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    await _ensureSession();
    final userMsg = ChatMessage(
      messageId: const Uuid().v4(),
      role: 'user',
      content: content,
      attachmentName: fileName,
    );
    _messages = [..._messages, userMsg];
    _chatLoading = true;
    notifyListeners();

    // Persist user message — non-blocking; RLS/auth failures must not break the chat.
    try {
      await SupabaseService.saveChatMessage(
        sessionId: _activeSessionId!,
        moduleType: _chatModule.apiValue,
        role: 'user',
        content: content,
      );
    } catch (_) {}

    try {
      final history = _messages
          .where((m) => m != userMsg)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      ChatMessage botMsg;
      if (fileBytes != null && fileName != null) {
        botMsg = await ApiService.sendChatWithFile(
          query: content,
          module: _chatModule,
          sessionId: _activeSessionId!,
          history: history,
          fileBytes: fileBytes,
          fileName: fileName,
          language: _language,
        );
      } else if (_chatModule == ChatModule.contractAnalysis) {
        botMsg = await ApiService.analyseContract(content, language: _language);
      } else {
        botMsg = await ApiService.sendChat(
          query: content,
          module: _chatModule,
          sessionId: _activeSessionId!,
          history: history,
          language: _language,
        );
      }
      _messages = [..._messages, botMsg];

      // Persist bot message — non-blocking.
      try {
        await SupabaseService.saveChatMessage(
          sessionId: _activeSessionId!,
          moduleType: _chatModule.apiValue,
          role: 'bot',
          content: botMsg.content,
          sources: botMsg.sources.map((s) => {'title': s.title, 'section': s.section}).toList(),
        );
      } catch (_) {}
    } catch (e) {
      final errMsg = ChatMessage(
        messageId: const Uuid().v4(),
        role: 'bot',
        content: 'Sorry, an error occurred. Please try again.',
      );
      _messages = [..._messages, errMsg];
    } finally {
      _chatLoading = false;
      notifyListeners();
    }
  }

  Future<void> evaluateCOL({
    required double grossSalary,
    required List<String> cities,
  }) async {
    _colLoading = true;
    _colError = null;
    notifyListeners();
    try {
      _colResults = await ApiService.evaluateCOL(grossSalary: grossSalary, cities: cities);
      if (_colResults.isNotEmpty) {
        await SupabaseService.saveColEvaluation(_colResults.first);
      }
    } catch (e) {
      _colError = e.toString();
    } finally {
      _colLoading = false;
      notifyListeners();
    }
  }
}
