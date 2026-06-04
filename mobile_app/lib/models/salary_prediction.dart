class SalaryPrediction {
  final String? predictionId;
  final String jobTitle;
  final String industry;
  final String educationLevel;
  final int yearsExperience;
  final String location;
  final double? predictedP25;
  final double? predictedP50;
  final double? predictedP75;
  final String? confidenceLabel;
  final double? offerAmount;
  final String? offerStatus;
  final DateTime? createdAt;

  const SalaryPrediction({
    this.predictionId,
    required this.jobTitle,
    required this.industry,
    required this.educationLevel,
    required this.yearsExperience,
    required this.location,
    this.predictedP25,
    this.predictedP50,
    this.predictedP75,
    this.confidenceLabel,
    this.offerAmount,
    this.offerStatus,
    this.createdAt,
  });

  factory SalaryPrediction.fromApiResponse(Map<String, dynamic> json) {
    final range = json['salary_range'] as Map<String, dynamic>? ?? {};
    return SalaryPrediction(
      jobTitle: json['job_title'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      educationLevel: json['education_level'] as String? ?? '',
      yearsExperience: (json['years_experience'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? '',
      predictedP25: (range['p25'] as num?)?.toDouble(),
      predictedP50: (range['p50'] as num?)?.toDouble(),
      predictedP75: (range['p75'] as num?)?.toDouble(),
      confidenceLabel: range['confidence'] as String?,
    );
  }

  factory SalaryPrediction.fromDbMap(Map<String, dynamic> map) => SalaryPrediction(
    predictionId: map['prediction_id'] as String?,
    jobTitle: map['job_title'] as String? ?? '',
    industry: map['industry'] as String? ?? '',
    educationLevel: map['education_level'] as String? ?? '',
    yearsExperience: (map['years_experience'] as num?)?.toInt() ?? 0,
    location: map['location'] as String? ?? '',
    predictedP25: (map['predicted_p25'] as num?)?.toDouble(),
    predictedP50: (map['predicted_p50'] as num?)?.toDouble(),
    predictedP75: (map['predicted_p75'] as num?)?.toDouble(),
    confidenceLabel: map['confidence_label'] as String?,
    offerAmount: (map['offer_amount'] as num?)?.toDouble(),
    offerStatus: map['offer_status'] as String?,
    createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
  );
}
