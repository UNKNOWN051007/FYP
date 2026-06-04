import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final initials = user != null && user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'WW';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(l.profileHeading)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar section
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.gradientBlue),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.fullName ?? 'Guest', style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    children: [
                      AppTag(label: 'Final Year Student', color: AppColors.accent),
                      AppTag(label: 'IT / CS', color: AppColors.teal),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                _StatCard(
                  title: 'Salary Goal',
                  value: user?.salaryGoal != null ? 'RM ${user!.salaryGoal!.toStringAsFixed(0)}' : 'Not set',
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                _StatCard(title: 'Predictions', value: provider.predictions.length.toString(), color: AppColors.teal),
                const SizedBox(width: 8),
                _StatCard(title: 'Saved', value: '0', color: AppColors.purple),
              ],
            ),
            const SizedBox(height: 12),

            // Language
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(l.language),
                  Row(
                    children: [
                      _LangBtn(label: l.english, code: 'en', current: provider.language),
                      const SizedBox(width: 8),
                      _LangBtn(label: l.bahasa, code: 'ms', current: provider.language),
                      const SizedBox(width: 8),
                      _LangBtn(label: l.chinese, code: 'zh', current: provider.language),
                      const SizedBox(width: 8),
                      _LangBtn(label: l.tamil, code: 'ta', current: provider.language),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Settings
            AppCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.bookmark_border,
                    label: 'Saved Reports',
                    trailing: const Text('0', style: TextStyle(color: AppColors.muted)),
                  ),
                  const Divider(color: AppColors.border),
                  _SettingRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: Switch(value: false, onChanged: (_) {}, activeThumbColor: AppColors.accent),
                  ),
                  const Divider(color: AppColors.border),
                  _SettingRow(
                    icon: Icons.lock_outline,
                    label: 'Privacy',
                    trailing: const Text('Data encrypted', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ),
                  const Divider(color: AppColors.border),
                  _SettingRow(
                    icon: Icons.info_outline,
                    label: 'About',
                    trailing: Text(l.version, style: const TextStyle(color: AppColors.dimmed, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign out
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: const Text('Sign Out', style: TextStyle(color: AppColors.text)),
                  content: Text(l.signOutConfirm, style: const TextStyle(color: AppColors.muted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<AppProvider>().signOut();
                        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(l.signOut, style: const TextStyle(color: AppColors.red)),
                    ),
                  ],
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.red),
                foregroundColor: AppColors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: AppCard(
      color: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _LangBtn extends StatelessWidget {
  final String label, code, current;
  const _LangBtn({required this.label, required this.code, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = code == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<AppProvider>().setLanguage(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.cardAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.accent : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: active ? Colors.white : AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _SettingRow({required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: AppColors.muted, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.text))),
        trailing,
      ],
    ),
  );
}

