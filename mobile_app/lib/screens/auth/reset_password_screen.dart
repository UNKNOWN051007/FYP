import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/animated_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _success = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pass = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (pass.isEmpty) {
      setState(() => _error = 'Please enter a new password.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.updatePassword(pass);
      if (!mounted) return;
      setState(() => _success = true);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: AnimatedBackground(
          colors: c,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: c.gradientPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock_reset, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('WageWise', style: TextStyle(color: c.accent, fontSize: 28, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _success ? 'Password updated' : 'Set a new password',
                  style: TextStyle(color: c.text, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _success
                      ? 'Your password has been changed. You can now sign in with the new one.'
                      : 'Enter the new password you want to use for your account.',
                  style: TextStyle(color: c.muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 32),
                if (_success) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: c.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: c.green, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Password reset successful.',
                            style: TextStyle(color: c.green, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Continue to sign in',
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await AuthService.signOut();
                      if (!mounted) return;
                      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
                    },
                  ),
                ] else ...[
                  if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 12)],
                  const FieldLabel('New password'),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: TextStyle(color: c.text),
                    decoration: InputDecoration(
                      hintText: 'At least 6 characters',
                      prefixIcon: Icon(Icons.lock_outline, color: c.muted, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: c.muted, size: 18,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Confirm new password'),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: _obscure,
                    style: TextStyle(color: c.text),
                    decoration: const InputDecoration(hintText: 'Re-enter password'),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(label: 'Update password', onPressed: _submit, loading: _loading),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
