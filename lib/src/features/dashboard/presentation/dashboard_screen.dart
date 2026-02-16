import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common_widgets/glass_container.dart';
import '../../../constants/app_theme.dart';
import '../../home/home_controller.dart';
import '../../finance/data/finance_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/profile_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);
    final expensesAsyncValue = ref.watch(expensesStreamProvider);
    final incomeAsyncValue = ref.watch(incomeStreamProvider);
    final profileAsyncValue = ref.watch(userProfileProvider);
    final user = ref.watch(authStateChangesProvider).value;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aura Home',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    profileAsyncValue.when(
                      data: (profile) => Text(
                        'Welcome back, ${profile?.displayName ?? user?.displayName ?? "User"}',
                        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
                      ),
                      loading: () => const SizedBox(height: 14),
                      error: (err, stack) => Text(
                        'Welcome back, ${user?.displayName ?? "User"}',
                        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: AppTheme.indigo.withValues(alpha: 0.1),
                  child: const Icon(Icons.notifications_none, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Balance Card
            expensesAsyncValue.when(
              data: (expenses) {
                return incomeAsyncValue.when(
                  data: (incomes) {
                    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
                    final totalEarned = incomes.fold(0.0, (sum, e) => sum + e.amount);
                    const double initialBalance = 0.0; 
                    final currentBalance = initialBalance + totalEarned - totalSpent;

                    return GlassContainer(
                      blur: 20,
                      opacity: 0.12,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Balance',
                                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${currentBalance.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.indigo.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.account_balance_wallet, color: AppTheme.indigo, size: 32),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildBalanceMiniStat('Spent', '₹${totalSpent.toInt()}', AppTheme.rose, Icons.arrow_downward),
                              const SizedBox(width: 24),
                              _buildBalanceMiniStat('Earned', '₹${totalEarned.toInt()}', AppTheme.emerald, Icons.arrow_upward),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                  error: (err, stack) => const Text('Error loading income'),
                );
              },
              loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const Text('Error loading balance'),
            ),
            
            const SizedBox(height: 16),
            
            // Daily Tasks Progress
            tasksAsyncValue.when(
              data: (tasks) {
                final completedCount = tasks.where((t) => t.isCompleted).length;
                final totalCount = tasks.length;
                final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

                return GlassContainer(
                  blur: 15,
                  opacity: 0.1,
                  padding: const EdgeInsets.all(20),
                  onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.indigo),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: GoogleFonts.outfit(
                                  fontSize: 10, // Slightly smaller to fit better
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Tasks',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$completedCount of $totalCount completed today',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const Text('Error loading tasks'),
            ),
            
            const SizedBox(height: 16),
            
            // Recent Activity
            expensesAsyncValue.when(
              data: (expenses) {
                final recent = expenses.take(3).toList();
                return GlassContainer(
                  blur: 15,
                  opacity: 0.1,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(1),
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.indigo),
                                ),
                                const Icon(Icons.chevron_right, size: 14, color: AppTheme.indigo),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (recent.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.white24))),
                        )
                      else
                        ...recent.indexed.map((item) {
                          final index = item.$1;
                          final expense = item.$2;
                          return Column(
                            children: [
                              _buildActivityItem(
                                _getCategoryIcon(expense.category), 
                                expense.title, 
                                '₹${expense.amount.toStringAsFixed(0)}', 
                                'This Month'
                              ),
                              if (index < recent.length - 1)
                                const Divider(color: Colors.white10, height: 20, indent: 40),
                            ],
                          );
                        }),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const Text('Error loading activity'),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions Header
            Text(
              'Quick Actions',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildQuickAction(
                  context, 
                  Icons.add_task, 
                  'Add Task', 
                  AppTheme.indigo,
                  () {
                    ref.read(navigationIndexProvider.notifier).setIndex(2); // Tasks Tab
                  }
                ),
                _buildQuickAction(
                  context, 
                  Icons.signal_cellular_alt, 
                  'Analytics', 
                  AppTheme.emerald,
                  () {
                    ref.read(navigationIndexProvider.notifier).setIndex(1); // Finance Tab
                  }
                ),
                _buildQuickAction(
                  context, 
                  Icons.qr_code_scanner, 
                  'Scan & Pay', 
                  AppTheme.rose,
                  () {
                    // Navigate to Scanner is usually a separate push, handled in HomeScreen FAB
                    // but we can trigger it here too if we want
                  }
                ),
                _buildQuickAction(
                  context, 
                  Icons.auto_awesome, 
                  'AI Insights', 
                  Colors.purple,
                  () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI Insights: Your spending is optimized!')),
                    );
                  }
                ),
              ],
            ),
            const SizedBox(height: 24), // Reduced from 100 since extendBody is false
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceMiniStat(String label, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String amount, String date) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.indigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.indigo, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(date, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ),
        Text(amount, style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GlassContainer(
      blur: 10,
      opacity: 0.08,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(dynamic category) {
    final catName = category.toString().split('.').last;
    switch (catName) {
      case 'shopping': return Icons.shopping_bag_outlined;
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car_outlined;
      case 'rent': return Icons.home_work_outlined;
      case 'wifi': return Icons.wifi;
      case 'subscriptions': return Icons.subscriptions_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }
}

