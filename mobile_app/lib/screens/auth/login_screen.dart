import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/animated_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showResend = false;
  bool _resendSent = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() { _error = 'Please fill in all fields'; _showResend = false; });
      return;
    }
    setState(() { _loading = true; _error = null; _showResend = false; _resendSent = false; });
    try {
      await AuthService.signIn(email: email, password: pass);
      if (!mounted) return;
      await context.read<AppProvider>().init();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('email_not_confirmed')) {
        setState(() {
          _error = 'Please confirm your email first. Check your inbox for the confirmation link.';
          _showResend = true;
        });
      } else {
        setState(() => _error = msg.replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above first.');
      return;
    }
    try {
      await AuthService.resendConfirmation(email);
      setState(() => _resendSent = true);
    } catch (e) {
      setState(() => _error = 'Failed to resend: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _forgotPassword() async {
    final c = context.wc;
    final resetEmailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    String? dialogError;
    bool sent = false;
    bool sending = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !sending,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lock_reset, color: c.accent, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Reset Password'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!sent) ...[
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(color: c.muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: resetEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    hintText: 'you@email.com',
                    prefixIcon: Icon(Icons.email_outlined, color: c.muted, size: 18),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 10),
                  Text(dialogError!, style: TextStyle(color: c.red, fontSize: 12)),
                ],
              ] else ...[
                Icon(Icons.mark_email_read_outlined, color: c.green, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Reset link sent! Check your inbox and follow the instructions.',
                  style: TextStyle(color: c.muted, fontSize: 13, height: 1.5),
                ),
              ],
            ],
          ),
          actions: sent
              ? [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Done', style: TextStyle(color: c.accent)),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: TextStyle(color: c.muted)),
                  ),
                  ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                            final email = resetEmailCtrl.text.trim();
                            if (email.isEmpty) {
                              setDialogState(() => dialogError = 'Please enter your email.');
                              return;
                            }
                            setDialogState(() { sending = true; dialogError = null; });
                            try {
                              await AuthService.resetPassword(email);
                              setDialogState(() { sent = true; sending = false; });
                            } catch (e) {
                              setDialogState(() {
                                dialogError = 'Failed to send reset email. Check the address and try again.';
                                sending = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: sending
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Send Link'),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                // Logo mark
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: c.gradientPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'WageWise',
                      style: TextStyle(color: c.accent, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l.signIn, style: TextStyle(color: c.text, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Welcome back! Sign in to your account.', style: TextStyle(color: c.muted, fontSize: 13)),
                const SizedBox(height: 32),
                if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 8)],
                if (_showResend) ...[
                  _resendSent
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Confirmation email resent! Check your inbox.',
                            style: TextStyle(color: c.green, fontSize: 13),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _resend,
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Resend confirmation email', style: TextStyle(fontSize: 13)),
                          style: TextButton.styleFrom(foregroundColor: c.accent),
                        ),
                ],
                if (_error != null || _showResend) const SizedBox(height: 8),
                FieldLabel(l.email),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    hintText: 'you@email.com',
                    prefixIcon: Icon(Icons.email_outlined, color: c.muted, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                FieldLabel(l.password),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    prefixIcon: Icon(Icons.lock_outline, color: c.muted, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: c.muted,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  onSubmitted: (_) => _signIn(),
                ),
                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: c.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(label: l.signIn, onPressed: _signIn, loading: _loading),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: c.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(color: c.dimmed, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: c.border)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                    style: TextButton.styleFrom(foregroundColor: c.accent),
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(color: c.muted, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
