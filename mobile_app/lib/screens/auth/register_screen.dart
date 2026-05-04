import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final user = await context.read<AppProvider>().authService.signUp(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            fullName: _nameCtrl.text.trim(),
          );
      if (!mounted) return;
      context.read<AppProvider>().setUser(user);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = 'Registration failed. $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.bg,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join WageWise',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 26)),
                const SizedBox(height: 6),
                const Text('Start your fair wage journey today',
                    style: TextStyle(color: AppColors.muted, fontSize: 14)),
                const SizedBox(height: 28),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red.withOpacity(0.3)),
                    ),
                    child: Text(_error!,
                        style:
                            const TextStyle(color: AppColors.red, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: AppColors.muted),
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.muted, size: 20),
                  ),
                  validator: (v) =>
                      v != null && v.trim().isNotEmpty ? null : 'Required',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppColors.muted),
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.muted, size: 20),
                  ),
                  validator: (v) => v != null && v.contains('@')
                      ? null
                      : 'Enter a valid email',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: AppColors.muted),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.muted, size: 20),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: AppColors.muted),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: AppColors.muted, size: 20),
                  ),
                  validator: (v) => v == _passCtrl.text
                      ? null
                      : 'Passwords do not match',
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: _loading ? 'Creating account…' : 'Create Account',
                  onTap: _loading ? null : _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
