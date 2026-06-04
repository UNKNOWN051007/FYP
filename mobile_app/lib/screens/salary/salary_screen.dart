import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../models/salary_prediction.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

const _industries = [
  'Information Technology', 'Engineering', 'Business/Finance', 'Healthcare',
  'Education', 'Marketing/Sales', 'Manufacturing', 'Accounting',
  'Law', 'Architecture', 'Hospitality', 'Others',
];
const _educationLevels = [
  'SPM/O-Level', 'Diploma', "Bachelor's Degree", "Master's Degree", 'PhD',
];
const _locations = [
  'Kuala Lumpur', 'Penang', 'Johor Bahru', 'Shah Alam', 'Ipoh',
  'Kota Kinabalu', 'Kuching', 'Kota Bharu',
];

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});
  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final _titleCtrl = TextEditingController();
  final _expCtrl = TextEditingController(text: '0');
  final _offerCtrl = TextEditingController();
  String? _industry, _education, _location;
  bool _showResults = false;
  SalaryPrediction? _prediction;
  Map<String, dynamic>? _offerResult;
  bool _loading = false;
  bool _evaluatingOffer = false;
  String? _error;

  Future<void> _predict() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _industry == null || _education == null || _location == null) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      await provider.predictSalary(
        jobTitle: title, industry: _industry!, educationLevel: _education!,
        yearsExperience: int.tryParse(_expCtrl.text) ?? 0, location: _location!,
      );
      if (provider.salaryError != null) {
        setState(() => _error = provider.salaryError);
      } else {
        setState(() { _prediction = provider.latestPrediction; _showResults = true; });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _evaluateOffer() async {
    final p = _prediction;
    if (p == null) return;
    final offer = double.tryParse(_offerCtrl.text.trim());
    if (offer == null) return;
    setState(() { _evaluatingOffer = true; _offerResult = null; });
    try {
      final result = await ApiService.evaluateOffer(
        jobTitle: p.jobTitle, industry: p.industry, educationLevel: p.educationLevel,
        yearsExperience: p.yearsExperience, location: p.location, offer: offer,
      );
      setState(() => _offerResult = result);
    } catch (_) {} finally {
      setState(() => _evaluatingOffer = false);
    }
  }

  void _reset() => setState(() { _showResults = false; _prediction = null; _offerResult = null; _offerCtrl.clear(); });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(l.salaryHeading)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _showResults && _prediction != null ? _buildResults(l, _prediction!) : _buildForm(l),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 16)],
      FieldLabel(l.jobTitle),
      TextField(controller: _titleCtrl, style: const TextStyle(color: AppColors.text), decoration: const InputDecoration(hintText: 'e.g. Software Engineer')),
      const SizedBox(height: 16),
      FieldLabel(l.industry),
      AppDropdown(value: _industry, items: _industries, hint: 'Select industry', onChanged: (v) => setState(() => _industry = v)),
      const SizedBox(height: 16),
      FieldLabel(l.educationLevel),
      AppDropdown(value: _education, items: _educationLevels, hint: 'Select education', onChanged: (v) => setState(() => _education = v)),
      const SizedBox(height: 16),
      FieldLabel(l.yearsExperience),
      TextField(controller: _expCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.text)),
      const SizedBox(height: 16),
      FieldLabel(l.location),
      AppDropdown(value: _location, items: _locations, hint: 'Select city', onChanged: (v) => setState(() => _location = v)),
      const SizedBox(height: 24),
      GradientButton(label: l.predictButton, onPressed: _predict, loading: _loading),
      const SizedBox(height: 80),
    ],
  );

  Widget _buildResults(AppLocalizations l, SalaryPrediction p) {
    String statusLabel = l.atMarket;
    Color statusColor = AppColors.amber;
    if (_offerResult != null) {
      final s = _offerResult!['status'] as String? ?? '';
      if (s == 'below_market') { statusLabel = l.belowMarket; statusColor = AppColors.red; }
      else if (s == 'above_market') { statusLabel = l.aboveMarket; statusColor = AppColors.green; }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${p.jobTitle} Â· ${p.location}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 12),
              SectionHeader(l.salaryRange),
              Row(children: [
                _RangeCol(label: l.entryLevel, amount: p.predictedP25, color: AppColors.muted),
                _RangeCol(label: l.marketRate, amount: p.predictedP50, color: AppColors.accent, large: true),
                _RangeCol(label: l.seniorLevel, amount: p.predictedP75, color: AppColors.green),
              ]),
              if (p.confidenceLabel != null) ...[const SizedBox(height: 12), AppTag(label: 'Confidence: ${p.confidenceLabel}', color: AppColors.teal)],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(l.offerEvaluation),
              FieldLabel(l.enterOffer),
              Row(children: [
                Expanded(child: TextField(controller: _offerCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.text))),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _evaluateOffer,
                  child: _evaluatingOffer
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.evaluate),
                ),
              ]),
              if (_offerResult != null) ...[
                const SizedBox(height: 12),
                AppTag(label: statusLabel, color: statusColor),
                if ((_offerResult!['negotiation_tip'] as String?) != null) ...[
                  const SizedBox(height: 8),
                  Text(_offerResult!['negotiation_tip'] as String, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5)),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _reset,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accent),
            foregroundColor: AppColors.accent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(l.newPrediction),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _RangeCol extends StatelessWidget {
  final String label;
  final double? amount;
  final Color color;
  final bool large;
  const _RangeCol({required this.label, this.amount, required this.color, this.large = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(
        amount != null ? 'RM ${amount!.toStringAsFixed(0)}' : '-',
        style: TextStyle(color: color, fontSize: large ? 20 : 15, fontWeight: FontWeight.w800),
      ),
    ]),
  );
}

