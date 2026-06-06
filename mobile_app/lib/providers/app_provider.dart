import 'package:flutter/material.dart';
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

  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    _predictions = [];
    _latestPrediction = null;
    _messages = [];
    _colResults = [];
    _activeSessionId = null;
    notifyListeners();
  }

  Future<void> init() async {
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
    try {
      _activeSessionId = await SupabaseService.createChatSession(module.apiValue);
    } catch (_) {
      _activeSessionId = const Uuid().v4();
    }
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    _activeSessionId ??= const Uuid().v4();
    final userMsg = ChatMessage(
      messageId: const Uuid().v4(),
      role: 'user',
      content: content,
    );
    _messages = [..._messages, userMsg];
    _chatLoading = true;
    notifyListeners();

    try {
      await SupabaseService.saveChatMessage(
        sessionId: _activeSessionId!,
        role: 'user',
        content: content,
      );
      final history = _messages
          .where((m) => m != userMsg)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      ChatMessage botMsg;
      if (_chatModule == ChatModule.contractAnalysis) {
        botMsg = await ApiService.analyseContract(content);
      } else {
        botMsg = await ApiService.sendChat(
          query: content,
          module: _chatModule,
          sessionId: _activeSessionId!,
          history: history,
        );
      }
      _messages = [..._messages, botMsg];
      await SupabaseService.saveChatMessage(
        sessionId: _activeSessionId!,
        role: 'bot',
        content: botMsg.content,
        sources: botMsg.sources.map((s) => {'title': s.title, 'section': s.section}).toList(),
      );
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
