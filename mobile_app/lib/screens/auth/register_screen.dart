import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
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
      final user = await AuthService.signUp(email: email, password: pass, fullName: name);
      context.read<AppProvider>().setUser(user);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
              Text(l.createAccount, style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 16)],
              FieldLabel(l.fullName),
              TextField(controller: _nameCtrl, style: const TextStyle(color: AppColors.text), decoration: const InputDecoration(hintText: 'Your Name')),
              const SizedBox(height: 16),
              FieldLabel(l.email),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppColors.text), decoration: const InputDecoration(hintText: 'you@email.com')),
              const SizedBox(height: 16),
              FieldLabel(l.password),
              TextField(controller: _passCtrl, obscureText: true, style: const TextStyle(color: AppColors.text), decoration: const InputDecoration(hintText: 'â€¢â€¢â€¢â€¢â€¢â€¢')),
              const SizedBox(height: 16),
              FieldLabel(l.confirmPassword),
              TextField(controller: _confirmCtrl, obscureText: true, style: const TextStyle(color: AppColors.text), decoration: const InputDecoration(hintText: 'â€¢â€¢â€¢â€¢â€¢â€¢'), onSubmitted: (_) => _register()),
              const SizedBox(height: 24),
              GradientButton(label: l.createAccount, onPressed: _register, loading: _loading),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(l.haveAccount, style: const TextStyle(color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

