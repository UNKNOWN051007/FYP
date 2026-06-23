import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final List<Color>? colors;
  final EdgeInsets? padding;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.colors,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    final resolvedColors = colors ?? c.gradientPrimary;
    return GestureDetector(
      onTap: (loading || onPressed == null) ? null : onPressed,
      child: Opacity(
        opacity: (loading || onPressed == null) ? 0.6 : 1.0,
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: resolvedColors),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? c.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

class AppTag extends StatelessWidget {
  final String label;
  final Color color;

  const AppTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class ErrorBox extends StatelessWidget {
  final String message;
  const ErrorBox(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.red.withValues(alpha: 0.3)),
      ),
      child: Text(message, style: TextStyle(color: c.red, fontSize: 13)),
    );
  }
}

class AppDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: c.dimmed)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: c.cardAlt,
        style: TextStyle(color: c.text),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
