import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/animated_background.dart';

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
    final c = context.wc;
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final tip = _tips[DateTime.now().day % _tips.length];
    final recentPredictions = provider.predictions.take(2).toList();
    final initials = user != null && user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'WW';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.greeting}, ${user?.fullName.split(' ').first ?? 'there'}!',
              style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text('WageWise', style: TextStyle(color: c.muted, fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: c.gradientPrimary),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
      body: AnimatedBackground(
        colors: c,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Market Insight card
              AppCard(
                color: c.cardAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.marketInsight, style: TextStyle(color: c.muted, fontSize: 13)),
                        AppTag(label: '+18.4% YoY', color: c.green),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l.avgFreshGrad, style: TextStyle(color: c.muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('RM 3,800', style: TextStyle(color: c.text, fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.72,
                        backgroundColor: c.border,
                        valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Target: RM 4,500', style: TextStyle(color: c.dimmed, fontSize: 11)),
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
                  _ActionCard(label: l.salaryCheck, icon: Icons.bar_chart, color: c.accent, tabIndex: 1),
                  _ActionCard(label: l.negotiate, icon: Icons.mic, color: c.teal, tabIndex: 2),
                  _ActionCard(label: l.myRights, icon: Icons.shield_outlined, color: c.purple, tabIndex: 2),
                  _ActionCard(label: l.livingCost, icon: Icons.calculate_outlined, color: c.amber, tabIndex: 3),
                ],
              ),
              const SizedBox(height: 20),

              // Tip of the Day
              SectionHeader(l.tipOfDay),
              AppCard(
                color: c.accent.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.lightbulb_outline, color: c.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(tip, style: TextStyle(color: c.text, fontSize: 13, height: 1.5))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Predictions
              SectionHeader(l.recentPredictions),
              if (recentPredictions.isEmpty)
                AppCard(
                  child: Center(
                    child: Text(
                      'No predictions yet. Try the Salary tab!',
                      style: TextStyle(color: c.muted, fontSize: 13),
                    ),
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
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.trending_up, color: c.accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.jobTitle, style: TextStyle(color: c.text, fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(p.location, style: TextStyle(color: c.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          'RM ${p.predictedP50?.toStringAsFixed(0) ?? '-'}',
                          style: TextStyle(color: c.accent, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),
              const SizedBox(height: 80),
            ],
          ),
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
