import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'auth/login_screen.dart';

class _Slide {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _Slide(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color});
}

const _slides = [
  _Slide(
    icon: '📊',
    title: 'Know Your Worth',
    subtitle:
        "Get AI-powered salary predictions specific to Malaysia's job market.",
    color: AppColors.accent,
  ),
  _Slide(
    icon: '🤝',
    title: 'Negotiate with Confidence',
    subtitle:
        'Practice salary negotiations with our AI coach tailored to Malaysian workplace culture.',
    color: AppColors.teal,
  ),
  _Slide(
    icon: '⚖️',
    title: 'Understand Your Rights',
    subtitle:
        'Access plain-language guidance on the Employment Act 1955 and labour laws.',
    color: AppColors.purple,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _current = 0;

  void _next() {
    if (_current < _slides.length - 1) {
      setState(() => _current++);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.teal],
                      ),
                    ),
                    child: const Center(
                      child: Text('W',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('WageWise',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 24)),
                  const Text('Your Fair Wage Navigator',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ),
              const Spacer(),
              // Slide content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(_current),
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: slide.color.withOpacity(0.15),
                        border: Border.all(
                            color: slide.color.withOpacity(0.3), width: 1),
                      ),
                      child: Center(
                          child: Text(slide.icon,
                              style: const TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: 1.2),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      slide.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 15, height: 1.6),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => GestureDetector(
                    onTap: () => setState(() => _current = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == _current ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _current ? AppColors.accent : AppColors.dimmed,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: _current < _slides.length - 1 ? 'Continue →' : 'Get Started',
                onTap: _next,
              ),
              if (_current < _slides.length - 1) ...[
                const SizedBox(height: 14),
                TextButton(
                  onPressed: _goToLogin,
                  child: const Text('Sign In',
                      style: TextStyle(color: AppColors.muted)),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
