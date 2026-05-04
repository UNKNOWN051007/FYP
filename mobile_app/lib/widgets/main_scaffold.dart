import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/salary/salary_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/col/col_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  void _navigate(int index) => setState(() => _tab = index);

  static const _navItems = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home', AppColors.accent),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Salary', AppColors.accent),
    _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble_rounded, 'AI Chat', AppColors.purple),
    _NavItem(Icons.map_outlined, Icons.map_rounded, 'Living', AppColors.amber),
    _NavItem(Icons.person_outline, Icons.person_rounded, 'Profile', AppColors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigate: _navigate),
      const SalaryScreen(),
      const ChatbotScreen(),
      const ColScreen(),
      const ProfileScreen(),
    ];

    final activeColor = _navItems[_tab].activeColor;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: screens[_tab]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bg.withOpacity(0.96),
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isActive = i == _tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _navigate(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive ? activeColor : AppColors.dimmed,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isActive ? activeColor : const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;

  const _NavItem(this.icon, this.activeIcon, this.label, this.activeColor);
}
