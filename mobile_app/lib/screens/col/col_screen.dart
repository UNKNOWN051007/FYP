import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../models/col_evaluation.dart';
import '../../widgets/common_widgets.dart';

const _allCities = [
  'Kuala Lumpur', 'Penang', 'Johor Bahru', 'Shah Alam',
  'Ipoh', 'Kota Kinabalu', 'Kuching', 'Kota Bharu',
];

class ColScreen extends StatefulWidget {
  const ColScreen({super.key});
  @override
  State<ColScreen> createState() => _ColScreenState();
}

class _ColScreenState extends State<ColScreen> {
  final _salaryCtrl = TextEditingController(text: '4000');
  final Set<String> _selectedCities = {'Kuala Lumpur'};
  int _activeResult = 0;

  Future<void> _evaluate() async {
    final salary = double.tryParse(_salaryCtrl.text.trim());
    if (salary == null || _selectedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter salary and select at least one city')),
      );
      return;
    }
    await context.read<AppProvider>().evaluateCOL(grossSalary: salary, cities: _selectedCities.toList());
    setState(() => _activeResult = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(l.colHeading)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel(l.grossSalary),
                  TextField(
                    controller: _salaryCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.text),
                  ),
                  const SizedBox(height: 16),
                  FieldLabel(l.selectCities),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _allCities.map((city) {
                      final selected = _selectedCities.contains(city);
                      return FilterChip(
                        label: Text(city, style: TextStyle(color: selected ? AppColors.accent : AppColors.muted, fontSize: 12)),
                        selected: selected,
                        onSelected: (v) => setState(() => v ? _selectedCities.add(city) : _selectedCities.remove(city)),
                        backgroundColor: AppColors.cardAlt,
                        selectedColor: AppColors.accent.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.accent,
                        side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(label: l.evaluateButton, onPressed: _evaluate, loading: provider.colLoading),
                ],
              ),
            ),
            if (provider.colError != null) ...[const SizedBox(height: 12), ErrorBox(provider.colError!)],
            if (provider.colResults.isNotEmpty) ...[
              const SizedBox(height: 20),
              if (provider.colResults.length > 1) ...[
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.colResults.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final active = i == _activeResult;
                      return GestureDetector(
                        onTap: () => setState(() => _activeResult = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : AppColors.cardAlt,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: active ? AppColors.accent : AppColors.border),
                          ),
                          child: Text(
                            provider.colResults[i].city,
                            style: TextStyle(color: active ? Colors.white : AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _ColResults(result: provider.colResults[_activeResult], l: l),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ColResults extends StatelessWidget {
  final ColEvaluation result;
  final AppLocalizations l;
  const _ColResults({required this.result, required this.l});

  @override
  Widget build(BuildContext context) {
    final sustainColor = result.sustainability == 'comfortable'
        ? AppColors.green
        : result.sustainability == 'tight'
            ? AppColors.amber
            : AppColors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(l.deductions),
              _Row('EPF (11%)', result.epfDeduction, AppColors.accent),
              _Row('SOCSO (0.5%)', result.socsoDeduction, AppColors.teal),
              _Row('Income Tax', result.taxDeduction, AppColors.amber),
              const Divider(color: AppColors.border),
              _Row(l.netSalary, result.netSalary, AppColors.green, bold: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppCard(
                color: (result.meetsLivingWage ? AppColors.green : AppColors.red).withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Icon(
                      result.meetsLivingWage ? Icons.check_circle : Icons.warning,
                      color: result.meetsLivingWage ? AppColors.green : AppColors.red,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.meetsLivingWage ? l.meetsLivingWage : l.belowLivingWage,
                      style: TextStyle(
                        color: result.meetsLivingWage ? AppColors.green : AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'RM ${result.livingWageBenchmark.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                color: sustainColor.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, color: sustainColor),
                    const SizedBox(height: 4),
                    Text(
                      _sustainLabel(result.sustainability, l),
                      style: TextStyle(color: sustainColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'RM ${result.disposableIncome.toStringAsFixed(0)}/mo',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(l.expenses),
              _ExpBar('Rent', result.rent, result.totalExpenses),
              _ExpBar('Food', result.food, result.totalExpenses),
              _ExpBar('Transport', result.transport, result.totalExpenses),
              _ExpBar('Utilities', result.utilities, result.totalExpenses),
              _ExpBar('Healthcare', result.healthcare, result.totalExpenses),
              const Divider(color: AppColors.border),
              _Row('Total', result.totalExpenses, AppColors.red, bold: true),
            ],
          ),
        ),
      ],
    );
  }

  String _sustainLabel(String s, AppLocalizations l) {
    switch (s) {
      case 'comfortable': return l.comfortable;
      case 'tight': return l.tight;
      default: return l.deficit;
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool bold;
  const _Row(this.label, this.amount, this.color, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? AppColors.text : AppColors.muted, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        Text('RM ${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      ],
    ),
  );
}

class _ExpBar extends StatelessWidget {
  final String label;
  final double amount;
  final double total;
  const _ExpBar(this.label, this.amount, this.total);

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(
                'RM ${amount.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

