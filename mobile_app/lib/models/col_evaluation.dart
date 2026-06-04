class ColEvaluation {
  final String? evalId;
  final double grossSalary;
  final String city;
  final double epfDeduction;
  final double socsoDeduction;
  final double taxDeduction;
  final double netSalary;
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

  const ColEvaluation({
    this.evalId,
    required this.grossSalary,
    required this.city,
    required this.epfDeduction,
    required this.socsoDeduction,
    required this.taxDeduction,
    required this.netSalary,
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
  });

  factory ColEvaluation.fromApiResponse(Map<String, dynamic> json) {
    final ded = json['deductions'] as Map<String, dynamic>? ?? {};
    final exp = json['expenses'] as Map<String, dynamic>? ?? {};
    return ColEvaluation(
      grossSalary: (json['gross_salary'] as num?)?.toDouble() ?? 0,
      city: json['city'] as String? ?? '',
      epfDeduction: (ded['epf'] as num?)?.toDouble() ?? 0,
      socsoDeduction: (ded['socso'] as num?)?.toDouble() ?? 0,
      taxDeduction: (ded['income_tax'] as num?)?.toDouble() ?? 0,
      netSalary: (ded['net_salary'] as num?)?.toDouble() ?? 0,
      rent: (exp['rent'] as num?)?.toDouble() ?? 0,
      food: (exp['food'] as num?)?.toDouble() ?? 0,
      transport: (exp['transport'] as num?)?.toDouble() ?? 0,
      utilities: (exp['utilities'] as num?)?.toDouble() ?? 0,
      healthcare: (exp['healthcare'] as num?)?.toDouble() ?? 0,
      totalExpenses: (exp['total_expenses'] as num?)?.toDouble() ?? 0,
      disposableIncome: (json['disposable_income'] as num?)?.toDouble() ?? 0,
      meetsLivingWage: (json['meets_living_wage'] as bool?) ?? false,
      livingWageBenchmark: (json['living_wage_benchmark'] as num?)?.toDouble() ?? 0,
      sustainability: json['sustainability'] as String? ?? 'unknown',
    );
  }
}
