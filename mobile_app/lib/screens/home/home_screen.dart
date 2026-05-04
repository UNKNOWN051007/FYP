import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final firstName = user?.fullName.split(' ').first ?? 'there';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero header ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1628), AppColors.bg],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Good morning,',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                        Text('$firstName 👋',
                            style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 20)),
                        const Text('Ready to navigate your fair wage?',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.teal]),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.accentGlow, blurRadius: 16)
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?.fullName.isNotEmpty == true)
                              ? user!.fullName
                                  .split(' ')
                                  .map((w) => w[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                              : 'WW',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Market insight card
                _MarketInsightCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Quick actions ────────────────────────────
                const Text('Quick Actions',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _ActionCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'Salary Check',
                      sub: 'Know your market value',
                      color: AppColors.accent,
                      onTap: () => onNavigate(1),
                    ),
                    _ActionCard(
                      icon: Icons.bolt_rounded,
                      label: 'Negotiate',
                      sub: 'Practice with AI coach',
                      color: AppColors.teal,
                      onTap: () => onNavigate(2),
                    ),
                    _ActionCard(
                      icon: Icons.shield_outlined,
                      label: 'My Rights',
                      sub: 'Employment Act guide',
                      color: AppColors.purple,
                      onTap: () => onNavigate(2),
                    ),
                    _ActionCard(
                      icon: Icons.map_outlined,
                      label: 'Living Cost',
                      sub: 'Compare cities',
                      color: AppColors.amber,
                      onTap: () => onNavigate(3),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Tip of the day ───────────────────────────
                AppCard(
                  color: const Color(0xFF0E1E0E),
                  borderColor: AppColors.green.withOpacity(0.3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.green.withOpacity(0.15),
                        ),
                        child: const Center(
                          child: Icon(Icons.info_outline,
                              color: AppColors.green, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tip of the Day',
                                style: TextStyle(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            SizedBox(height: 3),
                            Text(
                              'Always negotiate. 85% of employers expect it.',
                              style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 13,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ── Recent activity ──────────────────────────
                if (provider.predictions.isNotEmpty) ...[
                  const Text('Recent',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  ...provider.predictions.take(2).map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RecentCard(
                            icon: Icons.bar_chart_rounded,
                            label: '${p.jobTitle} – ${p.location}',
                            sub:
                                'Predicted: RM ${p.predictedP25?.toStringAsFixed(0)}–${p.predictedP75?.toStringAsFixed(0)}',
                            color: AppColors.accent,
                            tag: 'Salary',
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketInsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xFF0E2450),
      borderColor: AppColors.accent.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Insight',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avg. Fresh Grad Salary',
                      style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  const Text('RM 3,800',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 26)),
                  AppTag(label: 'IT / Software', color: AppColors.accent),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Your Target',
                      style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  const Text('RM 4,500',
                      style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 22)),
                  AppTag(label: '+18.4%', color: AppColors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.78,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RM 2,500',
                  style: TextStyle(color: AppColors.dimmed, fontSize: 10)),
              Text('RM 6,000+',
                  style: TextStyle(color: AppColors.dimmed, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        color: AppColors.cardAlt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withOpacity(0.15),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 11, height: 1.4),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final String tag;

  const _RecentCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(sub,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          AppTag(label: tag, color: color),
        ],
      ),
    );
  }
}
