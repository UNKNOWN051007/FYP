import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/animated_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();
    _init();
  }

  // Run Supabase init AND the minimum animation delay in parallel.
  Future<void> _init() async {
    await Future.wait([
      context.read<AppProvider>().init(),
      Future.delayed(const Duration(milliseconds: 1000)),
    ]);
    if (!mounted) return;
    final user = context.read<AppProvider>().user;
    Navigator.pushReplacementNamed(context, user != null ? '/main' : '/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: c.bg,
        body: AnimatedBackground(
          colors: c,
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: c.gradientPrimary),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'WageWise',
                        style: TextStyle(
                          color: c.text,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fair Wage Navigator',
                        style: TextStyle(color: c.muted, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
