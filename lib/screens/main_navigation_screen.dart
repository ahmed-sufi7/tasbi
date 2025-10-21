import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/footer_nav_bar.dart';
import '../providers/counter_provider.dart';
import '../providers/durood_provider.dart';
import '../utils/haptic_helper.dart';
import 'counter_screen.dart';
import 'durood_management_screen.dart';
import 'history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    HapticHelper.light();
  }

  void _showAddDuroodSheet() {
    HapticHelper.light();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const DuroodManagementScreen(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content with PageView for smooth transitions
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable horizontal swiping
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: const [
              CounterScreen(),
              HistoryScreen(),
            ],
          ),
          
          // Floating footer navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 12, // 12px margin from bottom
            child: SafeArea(
              child: FooterNavBar(
                activeIndex: _currentIndex,
                onHomeTap: () => _onTabChanged(0),
                onAddTap: _showAddDuroodSheet,
                onStatsTap: () => _onTabChanged(1),
                backgroundColor: const Color(0xFF1A1A1A),
                iconColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
