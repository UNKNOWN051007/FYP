import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/salary_prediction.dart';
import '../models/col_evaluation.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;
  static String? get _userId => _client.auth.currentUser?.id;

  static Future<void> savePrediction(SalaryPrediction p) async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('salary_predictions').insert({
      'user_id': uid,
      'job_title': p.jobTitle,
      'industry': p.industry,
      'education_level': p.educationLevel,
      'years_experience': p.yearsExperience,
      'location': p.location,
      'predicted_p25': p.predictedP25,
      'predicted_p50': p.predictedP50,
      'predicted_p75': p.predictedP75,
      'confidence_label': p.confidenceLabel ?? 'medium',
    });
  }

  static Future<List<SalaryPrediction>> getPredictions({int limit = 20}) async {
    final uid = _userId;
    if (uid == null) return [];
    final data = await _client
        .from('salary_predictions')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List<dynamic>)
        .map((m) => SalaryPrediction.fromDbMap(m as Map<String, dynamic>))
        .toList();
  }

  static Future<String> createChatSession(String moduleType) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not signed in');
    final data = await _client.from('chat_sessions').insert({
      'user_id': uid,
      'module_type': moduleType,
    }).select().single();
    return data['session_id'] as String;
  }

  static Future<void> saveChatMessage({
    required String sessionId,
    required String role,
    required String content,
    List<Map<String, dynamic>> sources = const [],
  }) async {
    await _client.from('chat_messages').insert({
      'session_id': sessionId,
      'role': role,
      'content': content,
      'sources': sources,
    });
  }

  static Future<void> saveColEvaluation(ColEvaluation e) async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('col_evaluations').insert({
      'user_id': uid,
      'gross_salary': e.grossSalary,
      'city': e.city,
      'epf_deduction': e.epfDeduction,
      'socso_deduction': e.socsoDeduction,
      'tax_deduction': e.taxDeduction,
      'net_salary': e.netSalary,
      'rent': e.rent,
      'food': e.food,
      'transport': e.transport,
      'utilities': e.utilities,
      'healthcare': e.healthcare,
      'total_expenses': e.totalExpenses,
      'disposable_income': e.disposableIncome,
      'meets_living_wage': e.meetsLivingWage,
    });
  }
}
