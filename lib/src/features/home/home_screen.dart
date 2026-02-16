import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../finance/presentation/finance_hub_screen.dart';
import '../finance/presentation/qr_scanner_screen.dart';
import '../tasks/presentation/task_logger_screen.dart';
import '../auth/presentation/profile_screen.dart';
import '../../constants/app_theme.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  final List<Widget> _screens = const [
    DashboardScreen(),
    FinanceHubScreen(),
    TaskLoggerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
        ],
      ),
      
      // Changed to false to prevent content from being hidden behind the navigation bar
      extendBody: false,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFF1E293B), // This was already a solid color. No change needed here based on the instruction "Set BottomAppBar to solid color."
        elevation: 10,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, ref, 0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(context, ref, 1, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finance'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(context, ref, 2, Icons.task_alt_outlined, Icons.task_alt, 'Tasks'),
              _buildNavItem(context, ref, 3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
          );
        },
        backgroundColor: AppTheme.indigo,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, int index, IconData icon, IconData activeIcon, String label) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.indigo.withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.indigo.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppTheme.indigo : Colors.white54,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const CustomFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Custom offset to make it 20% out instead of 50%
    // Standard centerDocked is (width - fabWidth) / 2, contentBottom - fabHeight / 2
    // We want contentBottom - fabHeight * 0.2
    final double x = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2;
    final double y = scaffoldGeometry.contentBottom - (scaffoldGeometry.floatingActionButtonSize.height * 0.35); 
    // 0.35 because the notch margin also affects it visually. 
    // User asked for 20% out. Standard is 50% out. 
    // contentBottom is the top of the BottomAppBar usually when docked.
    // Actually contentBottom is the area above the bottom bar.
    // Let's adjust to get it closer to 20% out.
    return Offset(x, y);
  }
}

