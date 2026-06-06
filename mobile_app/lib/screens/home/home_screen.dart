import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tips = [
    "Research the market salary before any interview.",
    "EPF (11%) and SOCSO (0.5%) are mandatory deductions in Malaysia.",
    "Probation period cannot legally exceed 6 months.",
    "You are entitled to 8 days annual leave in your first year.",
    "Overtime pay must be at least 1.5× your hourly rate.",
    "Always negotiate — the first offer is rarely the best.",
    "Minimum wage in Malaysia is RM 1,700/month.",
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final tip = _tips[DateTime.now().day % _tips.length];
    final recentPredictions = provider.predictions.take(2).toList();
    final initials = user != null && user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'WW';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l.greeting}, ${user?.fullName.split(' ').first ?? 'there'}!',
                style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
            Text('WageWise', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.gradientBlue),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Insight card
            AppCard(
              color: AppColors.cardAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.marketInsight, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      AppTag(label: '+18.4% YoY', color: AppColors.green),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l.avgFreshGrad, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('RM 3,800', style: TextStyle(color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.72,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Target: RM 4,500', style: TextStyle(color: AppColors.dimmed, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            SectionHeader(l.quickActions),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _ActionCard(label: l.salaryCheck, icon: Icons.bar_chart, color: AppColors.accent, tabIndex: 1),
                _ActionCard(label: l.negotiate, icon: Icons.mic, color: AppColors.teal, tabIndex: 2),
                _ActionCard(label: l.myRights, icon: Icons.shield_outlined, color: AppColors.purple, tabIndex: 2),
                _ActionCard(label: l.livingCost, icon: Icons.calculate_outlined, color: AppColors.amber, tabIndex: 3),
              ],
            ),
            const SizedBox(height: 20),

            // Tip of the Day
            SectionHeader(l.tipOfDay),
            AppCard(
              color: AppColors.accent.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tip, style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.5))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Predictions
            SectionHeader(l.recentPredictions),
            if (recentPredictions.isEmpty)
              AppCard(
                child: Center(
                  child: Text('No predictions yet. Try the Salary tab!', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                ),
              )
            else
              ...recentPredictions.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.trending_up, color: AppColors.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.jobTitle, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(p.location, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('RM ${p.predictedP50?.toStringAsFixed(0) ?? '-'}',
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
              )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int tabIndex;

  const _ActionCard({required this.label, required this.icon, required this.color, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppProvider>().setTab(tabIndex),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        color: color.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

