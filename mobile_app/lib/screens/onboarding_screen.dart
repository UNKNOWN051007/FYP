import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../widgets/common_widgets.dart';

class _Slide {
  final String titleKey;
  final String descKey;
  final IconData icon;
  // gradient index: 0=primary, 1=secondary, 2=primary (reuse)
  final int gradientIdx;
  const _Slide(this.titleKey, this.descKey, this.icon, this.gradientIdx);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide('onboarding1Title', 'onboarding1Desc', Icons.trending_up, 0),
    _Slide('onboarding2Title', 'onboarding2Desc', Icons.mic, 1),
    _Slide('onboarding3Title', 'onboarding3Desc', Icons.shield_outlined, 0),
  ];

  void _next() {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  String _getTitle(AppLocalizations l, int i) {
    switch (i) {
      case 0: return l.onboarding1Title;
      case 1: return l.onboarding2Title;
      default: return l.onboarding3Title;
    }
  }

  String _getDesc(AppLocalizations l, int i) {
    switch (i) {
      case 0: return l.onboarding1Desc;
      case 1: return l.onboarding2Desc;
      default: return l.onboarding3Desc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.wc;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text(l.skip, style: TextStyle(color: c.muted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final slide = _slides[i];
                  final gradient = slide.gradientIdx == 1 ? c.gradientSecondary : c.gradientPrimary;
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(slide.icon, color: Colors.white, size: 60),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _getTitle(l, i),
                          style: TextStyle(color: c.text, fontSize: 26, fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getDesc(l, i),
                          style: TextStyle(color: c.muted, fontSize: 15, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? c.accent : c.dimmed,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GradientButton(
                label: _page == 2 ? l.getStarted : l.next,
                onPressed: _next,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
