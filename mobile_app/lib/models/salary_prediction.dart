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

  factory SalaryPrediction.fromJson(Map<String, dynamic> json) =>
      SalaryPrediction(
        predictionId: json['prediction_id'] as String?,
        jobTitle: json['job_title'] as String,
        industry: json['industry'] as String,
        educationLevel: json['education_level'] as String,
        yearsExperience: json['years_experience'] as int,
        location: json['location'] as String,
        predictedP25: (json['predicted_p25'] as num?)?.toDouble(),
        predictedP50: (json['predicted_p50'] as num?)?.toDouble(),
        predictedP75: (json['predicted_p75'] as num?)?.toDouble(),
        confidenceLabel: json['confidence_label'] as String?,
        offerAmount: (json['offer_amount'] as num?)?.toDouble(),
        offerStatus: json['offer_status'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'job_title': jobTitle,
        'industry': industry,
        'education_level': educationLevel,
        'years_experience': yearsExperience,
        'location': location,
      };

  String get offerStatusLabel {
    switch (offerStatus) {
      case 'below_market':
        return 'Below Market';
      case 'above_market':
        return 'Above Market';
      default:
        return 'At Market';
    }
  }
}
