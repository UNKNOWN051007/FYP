import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text('WageWise', style: TextStyle(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l.signIn, style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 8)],
              if (_showResend) ...[
                _resendSent
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('Confirmation email resent! Check your inbox.', style: TextStyle(color: AppColors.green, fontSize: 13)),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend confirmation email', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                      ),
              ],
              if (_error != null || _showResend) const SizedBox(height: 8),
              FieldLabel(l.email),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(hintText: 'you@email.com'),
              ),
              const SizedBox(height: 16),
              FieldLabel(l.password),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(hintText: '••••••'),
                onSubmitted: (_) => _signIn(),
              ),
              const SizedBox(height: 24),
              GradientButton(label: l.signIn, onPressed: _signIn, loading: _loading),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(l.noAccount, style: const TextStyle(color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
