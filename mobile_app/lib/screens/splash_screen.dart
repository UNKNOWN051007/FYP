import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/app_provider.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import '../widgets/main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2000), _navigate);
  }

  void _navigate() {
    final provider = context.read<AppProvider>();
    Widget dest;
    if (provider.isSignedIn) {
      dest = const MainScaffold();
    } else {
      dest = const OnboardingScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dest),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.teal],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGlow,
                        blurRadius: 32,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 42,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'WageWise',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your Fair Wage Navigator',
                  style: TextStyle(color: AppColors.muted, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
