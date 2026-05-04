class ColEvaluation {
  final String? evaluationId;
  final double grossSalary;
  final double epfDeduction;
  final double socsoDeduction;
  final double taxDeduction;
  final double netSalary;
  final String city;
  final double rent;
  final double food;
  final double transport;
  final double utilities;
  final double healthcare;
  final double totalExpenses;
  final double disposableIncome;
  final bool meetsLivingWage;
  final double livingWageBenchmark;
  final String sustainability;
  final DateTime? createdAt;

  const ColEvaluation({
    this.evaluationId,
    required this.grossSalary,
    required this.epfDeduction,
    required this.socsoDeduction,
    required this.taxDeduction,
    required this.netSalary,
    required this.city,
    required this.rent,
    required this.food,
    required this.transport,
    required this.utilities,
    required this.healthcare,
    required this.totalExpenses,
    required this.disposableIncome,
    required this.meetsLivingWage,
    required this.livingWageBenchmark,
    required this.sustainability,
    this.createdAt,
  });

  factory ColEvaluation.fromJson(Map<String, dynamic> json) {
    final ded = json['deductions'] as Map<String, dynamic>? ?? json;
    final exp = json['expenses'] as Map<String, dynamic>? ?? json;
    return ColEvaluation(
      evaluationId: json['evaluation_id'] as String?,
      grossSalary: (json['gross_salary'] as num).toDouble(),
      epfDeduction: (ded['epf'] as num).toDouble(),
      socsoDeduction: (ded['socso'] as num).toDouble(),
      taxDeduction: (ded['income_tax'] as num).toDouble(),
      netSalary: (ded['net_salary'] as num).toDouble(),
      city: json['city'] as String,
      rent: (exp['rent'] as num).toDouble(),
      food: (exp['food'] as num).toDouble(),
      transport: (exp['transport'] as num).toDouble(),
      utilities: (exp['utilities'] as num).toDouble(),
      healthcare: (exp['healthcare'] as num).toDouble(),
      totalExpenses: (exp['total_expenses'] as num).toDouble(),
      disposableIncome: (json['disposable_income'] as num).toDouble(),
      meetsLivingWage: json['meets_living_wage'] as bool,
      livingWageBenchmark: (json['living_wage_benchmark'] as num).toDouble(),
      sustainability: json['sustainability'] as String? ?? 'tight',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
