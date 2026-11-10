import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/neo_colors.dart';
import '../../shared/widgets/neo_app_bar.dart';
import '../ai_advisor/screens/ai_advisor_screen.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../reports/screens/reports_screen.dart';
import '../settings/screens/settings_screen.dart';
import '../transactions/screens/transactions_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<String> _titles = [
    'Beranda',
    'Transaksi',
    'Penasihat AI',
    'Laporan',
    'Pengaturan',
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AiAdvisorScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    AudioService().playClickSound();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeoAppBar(
        title: _titles[_currentIndex],
        onAvatarTap: () => _onTabSelected(4), // Buka Pengaturan saat avatar ditekan
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: NeoColors.surfaceLight,
          border: Border(
            top: BorderSide(color: NeoColors.black, width: 4.0),
          ),
          boxShadow: [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(0, -2),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.swap_horiz, Icons.swap_horiz, 'Transaksi'),
              _buildNavItem(2, Icons.smart_toy_outlined, Icons.smart_toy, 'Mentor AI'),
              _buildNavItem(3, Icons.bar_chart_outlined, Icons.bar_chart, 'Laporan'),
              _buildNavItem(4, Icons.settings_outlined, Icons.settings, 'Pengaturan'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.primaryBlueLight : Colors.transparent,
          border: Border.all(
            color: isSelected ? NeoColors.black : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: isSelected ? NeoColors.hardShadow(offset: 2.0) : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? NeoColors.black : NeoColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isSelected ? NeoColors.textDark : NeoColors.textMuted,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

