import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/salary_prediction.dart';
import '../models/chat_message.dart';
import '../models/col_evaluation.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static String get _base => Env.backendUrl;

  static Future<bool> isHealthy() async {
    try {
      final res = await http.get(Uri.parse('$_base/health')).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<SalaryPrediction> predictSalary({
    required String jobTitle,
    required String industry,
    required String educationLevel,
    required int yearsExperience,
    required String location,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'job_title': jobTitle,
        'industry': industry,
        'education_level': educationLevel,
        'years_experience': yearsExperience,
        'location': location,
      }),
    );
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'Prediction failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return SalaryPrediction.fromApiResponse({
      ...data,
      'job_title': jobTitle,
      'industry': industry,
      'education_level': educationLevel,
      'years_experience': yearsExperience,
      'location': location,
    });
  }

  static Future<Map<String, dynamic>> evaluateOffer({
    required String jobTitle,
    required String industry,
    required String educationLevel,
    required int yearsExperience,
    required String location,
    required double offer,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/predict/evaluate-offer?offer=${offer.toStringAsFixed(0)}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'job_title': jobTitle,
        'industry': industry,
        'education_level': educationLevel,
        'years_experience': yearsExperience,
        'location': location,
      }),
    );
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'Offer evaluation failed');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<ChatMessage> sendChat({
    required String query,
    required ChatModule module,
    required String sessionId,
    List<Map<String, String>> history = const [],
  }) async {
    final res = await http.post(
      Uri.parse('$_base/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'module': module.apiValue,
        'session_id': sessionId,
        'history': history,
      }),
    );
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'Chat failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ChatMessage.fromApiResponse(data, DateTime.now().millisecondsSinceEpoch.toString());
  }

  /// Send a chat message with an attached file (PDF, image, text, etc.).
  static Future<ChatMessage> sendChatWithFile({
    required String query,
    required ChatModule module,
    required String sessionId,
    List<Map<String, String>> history = const [],
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('$_base/chat/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['query'] = query
      ..fields['module'] = module.apiValue
      ..fields['session_id'] = sessionId
      ..fields['history'] = jsonEncode(history)
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'Chat with file failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ChatMessage.fromApiResponse(data, DateTime.now().millisecondsSinceEpoch.toString());
  }

  static Future<ChatMessage> analyseContract(String clause) async {
    final res = await http.post(
      Uri.parse('$_base/chat/contract'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'clause': clause}),
    );
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'Contract analysis failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ChatMessage.fromApiResponse(data, DateTime.now().millisecondsSinceEpoch.toString());
  }

  static Future<List<ColEvaluation>> evaluateCOL({
    required double grossSalary,
    required List<String> cities,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/col'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'gross_salary': grossSalary, 'cities': cities}),
    );
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'COL evaluation failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final cityList = data['cities'] as List<dynamic>? ?? [];
    return cityList.map((c) => ColEvaluation.fromApiResponse({
      ...c as Map<String, dynamic>,
      'gross_salary': grossSalary,
    })).toList();
  }

  static Future<List<String>> getAvailableCities() async {
    final res = await http.get(Uri.parse('$_base/col/cities'));
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'Failed to get cities');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<String>.from(data['cities'] as List<dynamic>? ?? []);
  }
}
