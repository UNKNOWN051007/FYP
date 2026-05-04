import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/salary_prediction.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleCtrl = TextEditingController(text: 'Software Engineer');
  final _offerCtrl = TextEditingController();

  String _industry = 'Information Technology';
  String _experience = '0';
  String _education = "Bachelor's Degree";
  String _location = 'Kuala Lumpur';

  SalaryPrediction? _result;

  static const _industries = [
    'Information Technology',
    'Engineering',
    'Business/Finance',
    'Healthcare',
    'Education',
    'Marketing',
  ];
  static const _experiences = ['0', '1', '2', '3', '4', '5+'];
  static const _educations = [
    'Diploma',
    "Bachelor's Degree",
    "Master's Degree",
    'PhD'
  ];
  static const _locations = [
    'Kuala Lumpur',
    'Penang',
    'Johor Bahru',
    'Kota Kinabalu',
    'Kuching',
    'Shah Alam',
  ];

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    final pred = await context.read<AppProvider>().predictSalary(
          jobTitle: _jobTitleCtrl.text.trim(),
          industry: _industry,
          educationLevel: _education,
          yearsExperience: int.tryParse(_experience) ?? 0,
          location: _location,
        );
    if (pred != null) setState(() => _result = pred);
  }

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    _offerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppProvider>().predictingSalary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.accent.withOpacity(0.15),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Salary Intelligence',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  Text('AI-powered · Malaysian data',
                      style:
                          TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_result == null) ...[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Job Title'),
                  TextFormField(
                    controller: _jobTitleCtrl,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                        hintText: 'e.g. Software Engineer'),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Industry'),
                  _dropdown(_industries, _industry,
                      (v) => setState(() => _industry = v!)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Years of Experience'),
                            _dropdown(
                              _experiences,
                              _experience,
                              (v) => setState(() => _experience = v!),
                              suffix: ' yr',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Education'),
                            _dropdown(
                              _educations,
                              _education,
                              (v) => setState(() => _education = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label('Location'),
                  _dropdown(_locations, _location,
                      (v) => setState(() => _location = v!)),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: loading ? '⏳ Predicting...' : 'Predict My Salary',
                    onTap: loading ? null : _predict,
                  ),
                ],
              ),
            ),
          ] else ...[
            _ResultView(
              result: _result!,
              offerCtrl: _offerCtrl,
              onReset: () => setState(() => _result = null),
            ),
          ],
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style:
                const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500)),
      );

  Widget _dropdown(
    List<String> items,
    String value,
    ValueChanged<String?> onChanged, {
    String suffix = '',
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.cardAlt,
        style: const TextStyle(color: AppColors.text, fontSize: 14),
        decoration: const InputDecoration(),
        items: items
            .map((i) => DropdownMenuItem(
                value: i,
                child: Text('$i$suffix',
                    style: const TextStyle(color: AppColors.text))))
            .toList(),
        onChanged: onChanged,
      );
}

class _ResultView extends StatefulWidget {
  final SalaryPrediction result;
  final TextEditingController offerCtrl;
  final VoidCallback onReset;

  const _ResultView({
    required this.result,
    required this.offerCtrl,
    required this.onReset,
  });

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  double _offerAmt = 0;

  String get _offerStatus {
    if (_offerAmt <= 0) return '';
    final p25 = widget.result.predictedP25 ?? 0;
    final p75 = widget.result.predictedP75 ?? 0;
    if (_offerAmt < p25) return 'below_market';
    if (_offerAmt > p75) return 'above_market';
    return 'at_market';
  }

  Color get _offerColor {
    switch (_offerStatus) {
      case 'below_market': return AppColors.red;
      case 'above_market': return AppColors.green;
      default: return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final p25 = r.predictedP25 ?? 0;
    final p50 = r.predictedP50 ?? 0;
    final p75 = r.predictedP75 ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result card
        AppCard(
          color: const Color(0xFF0E2450),
          borderColor: AppColors.accent.withOpacity(0.27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Salary Range',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  AppTag(
                      label: '${r.jobTitle} · ${r.location}',
                      color: AppColors.accent),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SalaryCol(label: 'Min', value: 'RM ${p25.toStringAsFixed(0)}', sub: '25th pct', color: AppColors.muted),
                  _SalaryCol(label: 'Median', value: 'RM ${p50.toStringAsFixed(0)}', sub: '50th pct', color: AppColors.text, large: true),
                  _SalaryCol(label: 'Max', value: 'RM ${p75.toStringAsFixed(0)}', sub: '75th pct', color: AppColors.teal),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.55,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RichText(
                  text: const TextSpan(children: [
                    TextSpan(
                        text: '📊 Based on ',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                    TextSpan(
                        text: '1,240 records',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: ' · HuggingFace Malaysian Job Dataset',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Offer evaluation
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Offer Evaluation',
                  style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.offerCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                          hintText: 'Enter offer (RM)'),
                      onChanged: (v) =>
                          setState(() => _offerAmt = double.tryParse(v) ?? 0),
                    ),
                  ),
                  if (_offerAmt > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _offerColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _offerColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        _offerStatus == 'below_market'
                            ? 'Below Market'
                            : _offerStatus == 'above_market'
                                ? 'Above Market'
                                : 'At Market',
                        style: TextStyle(
                            color: _offerColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
              if (_offerAmt > 0 && _offerStatus == 'below_market') ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.red.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    '💡 Your offer is RM ${(p50 - _offerAmt).abs().toStringAsFixed(0)} below median. You have room to negotiate up to RM ${p50.toStringAsFixed(0)}.',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // City comparison
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r.location} vs. Other Cities',
                  style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 12),
              ...const [
                _CityBar('Kuala Lumpur', 4100, 1.0, AppColors.accent),
                _CityBar('Penang', 3700, 0.90, AppColors.teal),
                _CityBar('Johor Bahru', 3500, 0.85, AppColors.purple),
                _CityBar('Kota Kinabalu', 3100, 0.76, AppColors.amber),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: widget.onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(color: AppColors.border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const SizedBox(
            width: double.infinity,
            child:
                Center(child: Text('← New Prediction')),
          ),
        ),
      ],
    );
  }
}

class _SalaryCol extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool large;

  const _SalaryCol({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: large ? 22 : 17)),
          Text(sub,
              style:
                  const TextStyle(color: AppColors.dimmed, fontSize: 10)),
        ],
      );
}

class _CityBar extends StatelessWidget {
  final String city;
  final int salary;
  final double ratio;
  final Color color;

  const _CityBar(this.city, this.salary, this.ratio, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
                width: 90,
                child: Text(city,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12))),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text('RM ${salary.toString()}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
