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

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = await AuthService.signIn(email: email, password: pass);
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
              Text(l.signIn, style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              if (_error != null) ...[ErrorBox(_error!), const SizedBox(height: 16)],
              FieldLabel(l.email),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(hintText: 'you@email.com'),
              ),
              const SizedBox(height: 16),
              FieldLabel(l.password),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(hintText: 'â€¢â€¢â€¢â€¢â€¢â€¢'),
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

