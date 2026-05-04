import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Gradient primary button – mirrors HTML's GradientBtn.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final List<Color> colors;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.colors = const [AppColors.accent, Color(0xFF6366F1)],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card widget matching the HTML Card component.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets? padding;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

/// Pill tag – mirrors HTML's Tag component.
class AppTag extends StatelessWidget {
  final String label;
  final Color color;

  const AppTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Section header text.
class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const SectionHeader({super.key, required this.title, this.padding});

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
        child: Text(title,
            style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      );
}

/// Small muted label above a field.
class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );
}
