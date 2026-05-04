import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/salary_prediction.dart';
import '../models/col_evaluation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService authService;
  final ApiService apiService;
  final SupabaseService supabaseService;

  AppProvider({
    required this.authService,
    required this.apiService,
    required this.supabaseService,
  });

  // ── Auth state ───────────────────────────────────────────────
  UserModel? _user;
  UserModel? get user => _user;
  bool get isSignedIn => _user != null;

  String _language = 'en';
  String get language => _language;

  void setUser(UserModel? user) {
    _user = user;
    if (user != null) _language = user.languagePref;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    if (_user != null) {
      _user = _user!.copyWith(languagePref: lang);
      await authService.updateProfile(_user!);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await authService.signOut();
    _user = null;
    _predictions.clear();
    _messages.clear();
    notifyListeners();
  }

  // ── Salary Intelligence ──────────────────────────────────────
  List<SalaryPrediction> _predictions = [];
  List<SalaryPrediction> get predictions => _predictions;

  SalaryPrediction? _latestPrediction;
  SalaryPrediction? get latestPrediction => _latestPrediction;

  bool _predictingsalary = false;
  bool get predictingSalary => _predictingsalary;

  String? _salaryError;
  String? get salaryError => _salaryError;

  Future<SalaryPrediction?> predictSalary({
    required String jobTitle,
    required String industry,
    required String educationLevel,
    required int yearsExperience,
    required String location,
  }) async {
    _predictingsalary = true;
    _salaryError = null;
    notifyListeners();
    try {
      final pred = await apiService.predictSalary(
        jobTitle: jobTitle,
        industry: industry,
        educationLevel: educationLevel,
        yearsExperience: yearsExperience,
        location: location,
      );
      _latestPrediction = pred;
      _predictions.insert(0, pred);
      if (isSignedIn) await supabaseService.savePrediction(pred);
      return pred;
    } catch (e) {
      _salaryError = e.toString();
      return null;
    } finally {
      _predictingsalary = false;
      notifyListeners();
    }
  }

  // ── Chat ─────────────────────────────────────────────────────
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  String _chatModule = 'labour_rights';
  String get chatModule => _chatModule;

  bool _chatLoading = false;
  bool get chatLoading => _chatLoading;

  String? _activeSessionId;

  void switchChatModule(String module) {
    _chatModule = module;
    _messages = _defaultMessages(module);
    _activeSessionId = null;
    notifyListeners();
  }

  List<ChatMessage> _defaultMessages(String module) {
    if (module == 'labour_rights') {
      return [
        ChatMessage.bot(
          "Hello! I'm your WageWise AI assistant, trained on Malaysian employment law. How can I help you today?",
        ),
      ];
    }
    if (module == 'negotiation_coach') {
      return [
        ChatMessage.bot(
          "Hi! I'm your WageWise negotiation coach. Choose a scenario to practice, or just ask me anything about salary negotiation.",
        ),
      ];
    }
    return [
      ChatMessage.bot(
        "Paste a section of your employment contract and I'll analyse it for compliance with Malaysian law.",
      ),
    ];
  }

  Future<void> sendMessage(String content) async {
    _messages.add(ChatMessage.user(content));
    _chatLoading = true;
    notifyListeners();

    try {
      if (_activeSessionId == null && isSignedIn) {
        _activeSessionId =
            await supabaseService.createChatSession(_chatModule);
      }

      final history = _messages
          .where((m) => !m.isBot)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final reply = await apiService.sendChat(
        query: content,
        module: _chatModule,
        sessionId: _activeSessionId,
        history: history,
      );

      _messages.add(reply);

      if (isSignedIn && _activeSessionId != null) {
        await supabaseService.saveChatMessage(
          sessionId: _activeSessionId!,
          role: 'user',
          content: content,
        );
        await supabaseService.saveChatMessage(
          sessionId: _activeSessionId!,
          role: 'bot',
          content: reply.content,
        );
      }
    } catch (e) {
      _messages.add(
        ChatMessage.bot('Sorry, I could not get a response. Please try again.'),
      );
    } finally {
      _chatLoading = false;
      notifyListeners();
    }
  }

  // ── COL ──────────────────────────────────────────────────────
  List<ColEvaluation> _colResults = [];
  List<ColEvaluation> get colResults => _colResults;

  bool _colLoading = false;
  bool get colLoading => _colLoading;

  Future<void> evaluateCOL({
    required double grossSalary,
    required List<String> cities,
  }) async {
    _colLoading = true;
    notifyListeners();
    try {
      _colResults = await apiService.evaluateCOL(
        grossSalary: grossSalary,
        cities: cities,
      );
      if (isSignedIn && _colResults.isNotEmpty) {
        await supabaseService.saveColEvaluation(_colResults.first);
      }
    } catch (_) {
      _colResults = [];
    } finally {
      _colLoading = false;
      notifyListeners();
    }
  }

  // ── Init ─────────────────────────────────────────────────────
  Future<void> init() async {
    final profile = await authService.getProfile();
    setUser(profile);
    if (isSignedIn) {
      _predictions = await supabaseService.getPredictions();
    }
    _messages = _defaultMessages(_chatModule);
    notifyListeners();
  }
}
