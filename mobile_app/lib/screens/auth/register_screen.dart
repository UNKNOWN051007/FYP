import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _registered = false;

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signUp(email: email, password: pass, fullName: name);
      if (!mounted) return;
      setState(() => _registered = true);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.wc;
    if (_registered) {
      return Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: c.gradientPrimary),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 24),
                Text('Check your email', style: TextStyle(color: c.text, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(
                  'We sent a confirmation link to your email. Please click it to activate your account, then sign in.',
                  style: TextStyle(color: c.muted, fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: l.signIn,
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
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
                    child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('WageWise', style: TextStyle(color: c.accent, fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              Text(l.createAccount, style: TextStyle(color: c.text, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Create your account to get started.', style: TextStyle(color: c.muted, fontSize: 13)),
              const SizedBox(height: 32),
              if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 16)],
              FieldLabel(l.fullName),
              TextField(controller: _nameCtrl, style: TextStyle(color: c.text), decoration: const InputDecoration(hintText: 'Your Name')),
              const SizedBox(height: 16),
              FieldLabel(l.email),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: TextStyle(color: c.text), decoration: const InputDecoration(hintText: 'you@email.com')),
              const SizedBox(height: 16),
              FieldLabel(l.password),
              TextField(controller: _passCtrl, obscureText: true, style: TextStyle(color: c.text), decoration: const InputDecoration(hintText: '••••••')),
              const SizedBox(height: 16),
              FieldLabel(l.confirmPassword),
              TextField(controller: _confirmCtrl, obscureText: true, style: TextStyle(color: c.text), decoration: const InputDecoration(hintText: '••••••'), onSubmitted: (_) => _register()),
              const SizedBox(height: 24),
              GradientButton(label: l.createAccount, onPressed: _register, loading: _loading),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(l.haveAccount, style: TextStyle(color: c.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
