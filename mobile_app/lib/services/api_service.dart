import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salary_prediction.dart';
import '../models/col_evaluation.dart';
import '../models/chat_message.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // ── Salary Intelligence ──────────────────────────────────────

  Future<SalaryPrediction> predictSalary({
    required String jobTitle,
    required String industry,
    required String educationLevel,
    required int yearsExperience,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'job_title': jobTitle,
        'industry': industry,
        'education_level': educationLevel,
        'years_experience': yearsExperience,
        'location': location,
      }),
    );
    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final range = data['salary_range'] as Map<String, dynamic>;
    return SalaryPrediction(
      jobTitle: jobTitle,
      industry: industry,
      educationLevel: educationLevel,
      yearsExperience: yearsExperience,
      location: location,
      predictedP25: (range['p25'] as num).toDouble(),
      predictedP50: (range['p50'] as num).toDouble(),
      predictedP75: (range['p75'] as num).toDouble(),
      confidenceLabel: range['confidence'] as String?,
    );
  }

  // ── AI Chatbot ───────────────────────────────────────────────

  Future<ChatMessage> sendChat({
    required String query,
    required String module,
    String? sessionId,
    List<Map<String, String>> history = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'module': module,
        if (sessionId != null) 'session_id': sessionId,
        'history': history,
      }),
    );
    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatMessage.bot(
      data['answer'] as String,
      sources: (data['sources'] as List<dynamic>? ?? [])
          .map((s) => ChatSource.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ChatMessage> analyseContract(String clause) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/contract'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'clause': clause}),
    );
    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatMessage.bot(data['answer'] as String);
  }

  // ── Cost of Living ───────────────────────────────────────────

  Future<List<ColEvaluation>> evaluateCOL({
    required double grossSalary,
    required List<String> cities,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/col'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'gross_salary': grossSalary,
        'cities': cities,
      }),
    );
    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final citiesData = data['cities'] as List<dynamic>;
    return citiesData
        .map((c) => ColEvaluation.fromJson({
              ...c as Map<String, dynamic>,
              'gross_salary': grossSalary,
            }))
        .toList();
  }

  Future<List<String>> getAvailableCities() async {
    final response = await http.get(Uri.parse('$baseUrl/col/cities'));
    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return List<String>.from(data['cities'] as List);
  }

  // ── Health ───────────────────────────────────────────────────

  Future<bool> isHealthy() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/health')).timeout(
                const Duration(seconds: 5),
              );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractMessage(response.body),
      );
    }
  }

  String _extractMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['detail'] as String? ?? 'Unknown error';
    } catch (_) {
      return body;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
