import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../providers/app_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/salary/salary_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/col/col_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    SalaryScreen(),
    ChatbotScreen(),
    ColScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final currentIndex = provider.tabIndex;
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.read<AppProvider>().setTab(i),
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.dimmed,
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

