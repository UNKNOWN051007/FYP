import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'package:wagewise/app_localizations.dart';
import '../providers/app_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/salary/salary_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/col/col_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const List<Widget> _screens = [
    HomeScreen(),
    SalaryScreen(),
    ChatbotScreen(),
    ColScreen(),
    ProfileScreen(),
  ];

  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _ensureUserLoaded();
  }

  Future<void> _ensureUserLoaded() async {
    final provider = context.read<AppProvider>();

    // Profile already loaded — nothing to do.
    if (provider.user != null) return;

    // No Supabase session at all — go to login immediately.
    if (!AuthService.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      });
      return;
    }

    // Session exists but profile not yet in provider (race between login and nav).
    await provider.init();

    if (!mounted) return;

    if (context.read<AppProvider>().user == null) {
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _retry() async {
    setState(() => _loadFailed = false);
    await _ensureUserLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    final provider = context.watch<AppProvider>();

    // Network/profile load failure — let user retry or sign out.
    if (_loadFailed) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, color: c.muted, size: 48),
              const SizedBox(height: 16),
              Text('Could not load your profile.', style: TextStyle(color: c.text)),
              const SizedBox(height: 8),
              Text('Check your connection and try again.', style: TextStyle(color: c.muted, fontSize: 13)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _retry, child: const Text('Retry')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await context.read<AppProvider>().signOut();
                },
                child: Text('Sign Out', style: TextStyle(color: c.muted)),
              ),
            ],
          ),
        ),
      );
    }

    // Show spinner while profile is loading.
    if (provider.user == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(
          child: CircularProgressIndicator(color: c.accent),
        ),
      );
    }

    final l = AppLocalizations.of(context)!;
    final currentIndex = provider.tabIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.read<AppProvider>().setTab(i),
        backgroundColor: c.card,
        selectedItemColor: c.accent,
        unselectedItemColor: c.dimmed,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: l.marketInsight.split(' ').first),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: l.salaryCheck),
          BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_outline), activeIcon: const Icon(Icons.chat_bubble), label: l.chatbotHeading),
          BottomNavigationBarItem(icon: const Icon(Icons.calculate_outlined), activeIcon: const Icon(Icons.calculate), label: 'COL'),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: l.profileHeading),
        ],
      ),
    );
  }
}
