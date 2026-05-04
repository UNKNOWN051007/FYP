import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

// Defined at file scope so ProfileScreen can reference it without forward issues.
class _LangOption {
  final String code;
  final String label;
  const _LangOption(this.code, this.label);
}

const _kLangs = [
  _LangOption('en', 'English'),
  _LangOption('ms', 'Bahasa Malaysia'),
  _LangOption('zh', '中文'),
  _LangOption('ta', 'தமிழ்'),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final nameParts = (user?.fullName ?? '').split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : nameParts.isNotEmpty && nameParts[0].isNotEmpty
            ? nameParts[0][0].toUpperCase()
            : 'WW';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      child: Column(
        children: [
          _AvatarSection(initials: initials, fullName: user?.fullName ?? 'Guest'),
          const SizedBox(height: 20),
          _StatsRow(provider: provider),
          const SizedBox(height: 14),
          _LangSwitcher(provider: provider),
          const SizedBox(height: 14),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'Saved Reports',
            sub: '${provider.predictions.length} reports',
            color: AppColors.accent,
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            sub: 'On',
            color: AppColors.amber,
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            label: 'Privacy',
            sub: 'Data encrypted',
            color: AppColors.green,
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'About WageWise',
            sub: 'v1.0 · TAR UMT FYP 2026',
            color: AppColors.muted,
          ),
          const SizedBox(height: 6),
          _SignOutButton(provider: provider),
        ],
      ),
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final String initials;
  final String fullName;
  const _AvatarSection({required this.initials, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.teal],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGlow,
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const Text(
          'Bachelor of Software Eng.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const Text(
          'TAR UMT, Kuala Lumpur',
          style: TextStyle(color: AppColors.dimmed, fontSize: 12),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          children: [
            AppTag(label: 'Final Year Student', color: AppColors.accent),
            AppTag(label: 'IT / CS', color: AppColors.teal),
          ],
        ),
      ],
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final AppProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Salary Goal',
            value: provider.user?.salaryGoal != null
                ? 'RM ${provider.user!.salaryGoal!.toStringAsFixed(0)}'
                : 'Not set',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Predictions',
            value: '${provider.predictions.length}',
            color: AppColors.teal,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _StatCard(
            label: 'Reports',
            value: '0 saved',
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Language switcher ──────────────────────────────────────────────────────

class _LangSwitcher extends StatelessWidget {
  final AppProvider provider;
  const _LangSwitcher({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌐  Language / Bahasa / 语言 / மொழி',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildLangButtons(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLangButtons(BuildContext context) {
    final result = <Widget>[];
    for (final opt in _kLangs) {
      final active = provider.language == opt.code;
      result.add(
        GestureDetector(
          onTap: () => provider.setLanguage(opt.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: active
                  ? AppColors.accent.withOpacity(0.15)
                  : Colors.transparent,
              border: Border.all(
                color: active
                    ? AppColors.accent.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            child: Text(
              opt.label,
              style: TextStyle(
                color: active ? AppColors.accent : AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }
    return result;
  }
}

// ── Settings tile ──────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.dimmed, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Sign-out button ────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  final AppProvider provider;
  const _SignOutButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await provider.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, size: 18, color: AppColors.red),
        label: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.red),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: const BorderSide(color: Color(0x66EF4444)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
