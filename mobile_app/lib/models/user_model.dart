class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String languagePref;
  final double? salaryGoal;
  final String? education;
  final String? fieldOfStudy;

  const UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.languagePref = 'en',
    this.salaryGoal,
    this.education,
    this.fieldOfStudy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['user_id'] as String,
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        languagePref: json['language_pref'] as String? ?? 'en',
        salaryGoal: (json['salary_goal'] as num?)?.toDouble(),
        education: json['education'] as String?,
        fieldOfStudy: json['field_of_study'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'full_name': fullName,
        'language_pref': languagePref,
        if (salaryGoal != null) 'salary_goal': salaryGoal,
        if (education != null) 'education': education,
        if (fieldOfStudy != null) 'field_of_study': fieldOfStudy,
      };

  UserModel copyWith({
    String? fullName,
    String? languagePref,
    double? salaryGoal,
    String? education,
    String? fieldOfStudy,
  }) =>
      UserModel(
        userId: userId,
        email: email,
        fullName: fullName ?? this.fullName,
        languagePref: languagePref ?? this.languagePref,
        salaryGoal: salaryGoal ?? this.salaryGoal,
        education: education ?? this.education,
        fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      );
}
