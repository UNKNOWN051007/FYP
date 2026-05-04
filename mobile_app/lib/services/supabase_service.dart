import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/salary_prediction.dart';
import '../models/col_evaluation.dart';
import '../models/chat_message.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  String get _userId => _client.auth.currentUser!.id;

  // ── Salary Predictions ───────────────────────────────────────

  Future<void> savePrediction(SalaryPrediction pred) async {
    await _client.from('salary_predictions').insert({
      'user_id': _userId,
      'job_title': pred.jobTitle,
      'industry': pred.industry,
      'education_level': pred.educationLevel,
      'years_experience': pred.yearsExperience,
      'location': pred.location,
      'predicted_p25': pred.predictedP25,
      'predicted_p50': pred.predictedP50,
      'predicted_p75': pred.predictedP75,
      'confidence_label': pred.confidenceLabel,
      if (pred.offerAmount != null) 'offer_amount': pred.offerAmount,
      if (pred.offerStatus != null) 'offer_status': pred.offerStatus,
    });
  }

  Future<List<SalaryPrediction>> getPredictions({int limit = 20}) async {
    final data = await _client
        .from('salary_predictions')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List)
        .map((r) => SalaryPrediction.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Chat Sessions & Messages ─────────────────────────────────

  Future<String> createChatSession(String moduleType) async {
    final data = await _client
        .from('chat_sessions')
        .insert({'user_id': _userId, 'module_type': moduleType})
        .select('session_id')
        .single();
    return (data as Map<String, dynamic>)['session_id'] as String;
  }

  Future<void> saveChatMessage({
    required String sessionId,
    required String role,
    required String content,
    List<Map<String, dynamic>>? sources,
  }) async {
    await _client.from('chat_messages').insert({
      'session_id': sessionId,
      'role': role,
      'content': content,
      if (sources != null) 'sources': sources,
    });
  }

  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at');
    return (data as List)
        .map((r) => ChatMessage.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── COL Evaluations ──────────────────────────────────────────

  Future<void> saveColEvaluation(ColEvaluation eval) async {
    await _client.from('col_evaluations').insert({
      'user_id': _userId,
      'gross_salary': eval.grossSalary,
      'epf_deduction': eval.epfDeduction,
      'socso_deduction': eval.socsoDeduction,
      'tax_deduction': eval.taxDeduction,
      'net_salary': eval.netSalary,
      'city': eval.city,
      'rent': eval.rent,
      'food': eval.food,
      'transport': eval.transport,
      'utilities': eval.utilities,
      'healthcare': eval.healthcare,
      'total_expenses': eval.totalExpenses,
      'disposable_income': eval.disposableIncome,
      'meets_living_wage': eval.meetsLivingWage,
    });
  }

  Future<List<ColEvaluation>> getColEvaluations({int limit = 10}) async {
    final data = await _client
        .from('col_evaluations')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List)
        .map((r) => ColEvaluation.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
