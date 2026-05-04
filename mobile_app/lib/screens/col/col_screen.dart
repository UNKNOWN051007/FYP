import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/col_evaluation.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ColScreen extends StatefulWidget {
  const ColScreen({super.key});

  @override
  State<ColScreen> createState() => _ColScreenState();
}

class _ColScreenState extends State<ColScreen> {
  final _salaryCtrl = TextEditingController(text: '4000');
  String _selectedCity = 'Kuala Lumpur';

  static const _cities = [
    'Kuala Lumpur',
    'Penang',
    'Johor Bahru',
    'Kota Kinabalu',
    'Kuching',
    'Shah Alam',
  ];

  // Local calculations (mirrors backend logic for instant feedback)
  double get _gross => double.tryParse(_salaryCtrl.text) ?? 4000;
  double get _epf => _gross * 0.11;
  double get _socso => (_gross * 0.005).clamp(0, 29.75);
  double get _tax => _gross > 5000 ? (_gross - 5000) * 0.01 : 0;
  double get _net => _gross - _epf - _socso - _tax;

  static const _expenses = <String, Map<String, double>>{
    'Kuala Lumpur': {
      'rent': 1400, 'food': 450, 'transport': 200,
      'utilities': 120, 'healthcare': 80
    },
    'Penang': {
      'rent': 900, 'food': 380, 'transport': 150,
      'utilities': 100, 'healthcare': 70
    },
    'Johor Bahru': {
      'rent': 850, 'food': 350, 'transport': 180,
      'utilities': 100, 'healthcare': 70
    },
    'Kota Kinabalu': {
      'rent': 800, 'food': 320, 'transport': 160,
      'utilities': 90, 'healthcare': 60
    },
    'Kuching': {
      'rent': 750, 'food': 300, 'transport': 150,
      'utilities': 85, 'healthcare': 60
    },
    'Shah Alam': {
      'rent': 1100, 'food': 400, 'transport': 190,
      'utilities': 110, 'healthcare': 75
    },
  };
  static const _livingWage = <String, double>{
    'Kuala Lumpur': 2900, 'Penang': 2500, 'Johor Bahru': 2200,
    'Kota Kinabalu': 2000, 'Kuching': 1900, 'Shah Alam': 2600,
  };

  static const _expColors = <String, Color>{
    'rent': AppColors.accent,
    'food': AppColors.teal,
    'transport': AppColors.purple,
    'utilities': AppColors.amber,
    'healthcare': AppColors.green,
  };
  static const _expLabels = <String, String>{
    'rent': 'Rent',
    'food': 'Food',
    'transport': 'Transport',
    'utilities': 'Utilities',
    'healthcare': 'Healthcare',
  };

  Map<String, double> get _cityExp =>
      _expenses[_selectedCity] ?? _expenses['Kuala Lumpur']!;
  double get _totalExp =>
      _cityExp.values.fold(0, (a, b) => a + b);
  double get _disposable => _net - _totalExp;
  double get _lw => _livingWage[_selectedCity] ?? 2000;
  bool get _meetsLW => _net >= _lw;

  @override
  void dispose() {
    _salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.amber.withOpacity(0.15),
                ),
                child: const Icon(Icons.map_outlined,
                    color: AppColors.amber, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cost-of-Living Evaluator',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  Text('Real purchasing power analysis',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Inputs
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gross Monthly Salary',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _salaryCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          prefixText: 'RM ',
                          prefixStyle: TextStyle(color: AppColors.muted),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select City',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        dropdownColor: AppColors.cardAlt,
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 14),
                        decoration: const InputDecoration(),
                        items: _cities
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 13))))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCity = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Deductions
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('After Deductions',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 12),
                _DeductionRow(
                    label: 'EPF (11%)',
                    value: -_epf,
                    color: AppColors.accent),
                _DeductionRow(
                    label: 'SOCSO',
                    value: -_socso,
                    color: AppColors.purple),
                _DeductionRow(
                    label: 'Income Tax',
                    value: _tax == 0 ? 0 : -_tax,
                    color: AppColors.amber),
                const Divider(color: AppColors.border, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Take-Home',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text('RM ${_net.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_meetsLW ? AppColors.green : AppColors.red)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: (_meetsLW ? AppColors.green : AppColors.red)
                            .withOpacity(0.3),
                        width: 1),
                  ),
                  child: Text(
                    _meetsLW
                        ? '✅ Meets living wage for $_selectedCity (RM ${_lw.toStringAsFixed(0)})'
                        : '⚠️ Below living wage for $_selectedCity (RM ${_lw.toStringAsFixed(0)})',
                    style: TextStyle(
                        color: _meetsLW ? AppColors.green : AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Expenses
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Expenses – $_selectedCity',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 12),
                ..._cityExp.entries.map(
                  (e) => _ExpenseRow(
                    label: _expLabels[e.key] ?? e.key,
                    value: e.value,
                    color: _expColors[e.key] ?? AppColors.accent,
                    maxVal: 1400,
                  ),
                ),
                const Divider(color: AppColors.border, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Expenses',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700)),
                    Text('RM ${_totalExp.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Disposable income
          AppCard(
            color: _disposable > 0
                ? const Color(0xFF0F2A0F)
                : const Color(0xFF2A0F0F),
            borderColor:
                (_disposable > 0 ? AppColors.green : AppColors.red)
                    .withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Disposable',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${_disposable >= 0 ? '+' : '–'}RM ${_disposable.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        color: _disposable > 0
                            ? AppColors.green
                            : AppColors.red,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_disposable > 0 ? AppColors.green : AppColors.red)
                        .withOpacity(0.15),
                    border: Border.all(
                        color: (_disposable > 0
                                ? AppColors.green
                                : AppColors.red)
                            .withOpacity(0.3),
                        width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _disposable > 0 ? '💚' : '⚠️',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // City comparison
          Text('City Comparison (RM ${_gross.toStringAsFixed(0)} gross)',
              style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 12),
          ..._cities.map((c) {
            final exp = _expenses[c] ?? _expenses['Kuala Lumpur']!;
            final cNet = _gross - (_gross * 0.11) -
                (_gross * 0.005).clamp(0, 29.75);
            final cTotalExp = exp.values.fold(0.0, (a, b) => a + b);
            final cDisp = cNet - cTotalExp;
            final isSelected = c == _selectedCity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCity = c),
                child: AppCard(
                  color: isSelected
                      ? const Color(0x221A3A6E)
                      : AppColors.card,
                  borderColor: isSelected
                      ? AppColors.accent.withOpacity(0.4)
                      : AppColors.border,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$c${isSelected ? ' ●' : ''}',
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Net: RM ${cNet.toStringAsFixed(0)} · Exp: RM ${cTotalExp.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${cDisp >= 0 ? '+' : '–'}RM ${cDisp.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              color: cDisp >= 0
                                  ? AppColors.green
                                  : AppColors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const Text('Disposable',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DeductionRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _DeductionRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 13)),
            Text(
              value < 0
                  ? '–RM ${value.abs().toStringAsFixed(2)}'
                  : value == 0
                      ? 'RM 0'
                      : '–RM ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: value < 0 ? AppColors.red : AppColors.green,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}

class _ExpenseRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double maxVal;

  const _ExpenseRow(
      {required this.label,
      required this.value,
      required this.color,
      required this.maxVal});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12)),
                Text('RM ${value.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (value / maxVal).clamp(0, 1),
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 5,
              ),
            ),
          ],
        ),
      );
}
