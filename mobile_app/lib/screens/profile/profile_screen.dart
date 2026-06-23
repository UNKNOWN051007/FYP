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
    final c = context.wc;
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final initials = user != null && user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'WW';

    return Scaffold(
      backgroundColor: c.bg,
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
                      gradient: LinearGradient(colors: c.gradientPrimary),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.fullName ?? 'Guest', style: TextStyle(color: c.text, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: TextStyle(color: c.muted, fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      AppTag(label: 'Final Year Student', color: c.accent),
                      AppTag(label: 'IT / CS', color: c.teal),
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
                  color: c.accent,
                ),
                const SizedBox(width: 8),
                _StatCard(title: 'Predictions', value: provider.predictions.length.toString(), color: c.teal),
                const SizedBox(width: 8),
                _StatCard(title: 'Saved', value: '0', color: c.purple),
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

            // Theme Picker
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader('Appearance'),
                  const SizedBox(height: 4),
                  const _ThemePicker(),
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
                    trailing: Text('0', style: TextStyle(color: c.muted)),
                  ),
                  Divider(color: c.border),
                  _SettingRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: Switch(value: false, onChanged: (_) {}, activeThumbColor: c.accent),
                  ),
                  Divider(color: c.border),
                  _SettingRow(
                    icon: Icons.lock_outline,
                    label: 'Privacy',
                    trailing: Text('Data encrypted', style: TextStyle(color: c.muted, fontSize: 12)),
                  ),
                  Divider(color: c.border),
                  _SettingRow(
                    icon: Icons.info_outline,
                    label: 'About',
                    trailing: Text(l.version, style: TextStyle(color: c.dimmed, fontSize: 11)),
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
                  backgroundColor: c.card,
                  title: Text('Sign Out', style: TextStyle(color: c.text)),
                  content: Text(l.signOutConfirm, style: TextStyle(color: c.muted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<AppProvider>().signOut();
                        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(l.signOut, style: TextStyle(color: c.red)),
                    ),
                  ],
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.red),
                foregroundColor: c.red,
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

// ── Theme Picker ────────────────────────────────────────────────────────────

class _ThemePicker extends StatelessWidget {
  static const _names = ['Dark Navy', 'Light Day', 'Midnight', 'Sunset', 'Ocean'];
  static const _bgs = [
    Color(0xFF0E1B2E),
    Color(0xFFF5F7FA),
    Color(0xFF050505),
    Color(0xFF1C0F05),
    Color(0xFF051520),
  ];
  static const _accents = [
    Color(0xFFFF921C),
    Color(0xFFFF921C),
    Color(0xFFFF921C),
    Color(0xFFFF6B35),
    Color(0xFF14B8A6),
  ];

  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final c = context.wc;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(5, (i) {
        final active = provider.themeIndex == i;
        return GestureDetector(
          onTap: () => provider.setTheme(i),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _bgs[i],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? c.accent : c.border,
                    width: active ? 2.5 : 1,
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: c.accent.withValues(alpha: 0.4), blurRadius: 8)]
                      : null,
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: _accents[i], shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _names[i],
                style: TextStyle(
                  color: active ? c.accent : c.muted,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Expanded(
      child: AppCard(
        color: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: c.muted, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label, code, current;
  const _LangBtn({required this.label, required this.code, required this.current});

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    final active = code == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<AppProvider>().setLanguage(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? c.accent : c.cardAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? c.accent : c.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
  Widget build(BuildContext context) {
    final c = context.wc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: c.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: c.text))),
          trailing,
        ],
      ),
    );
  }
}
