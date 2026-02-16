import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common_widgets/glass_container.dart';
import '../../../constants/app_theme.dart';
import '../domain/finance_models.dart';
import '../data/finance_repository.dart';

class FinanceHubScreen extends ConsumerStatefulWidget {
  const FinanceHubScreen({super.key});

  @override
  ConsumerState<FinanceHubScreen> createState() => _FinanceHubScreenState();
}

class _FinanceHubScreenState extends ConsumerState<FinanceHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _selectDate(BuildContext context) async {
    // Basic dialog to pick month and year
    final int? selectedYear = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Select Year', style: GoogleFonts.outfit(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(11, (index) => 2020 + index).map((year) {
              return InkWell(
                onTap: () => Navigator.pop(context, year),
                child: Center(
                  child: Text(
                    year.toString(),
                    style: GoogleFonts.outfit(
                      color: year == _selectedDate.year ? AppTheme.indigo : Colors.white70,
                      fontWeight: year == _selectedDate.year ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selectedYear == null) return;

    final int? selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Select Month', style: GoogleFonts.outfit(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(12, (index) => index + 1).map((month) {
              return InkWell(
                onTap: () => Navigator.pop(context, month),
                child: Center(
                  child: Text(
                    _getMonthName(month),
                    style: GoogleFonts.outfit(
                      color: month == _selectedDate.month && selectedYear == _selectedDate.year ? AppTheme.indigo : Colors.white70,
                      fontWeight: month == _selectedDate.month && selectedYear == _selectedDate.year ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selectedMonth != null) {
      final newDate = DateTime(selectedYear, selectedMonth);
      setState(() {
        _selectedDate = newDate;
      });
      ref.read(selectedFinanceDateProvider.notifier).setDate(newDate);
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finance',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Manage your money wisely',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
              // Month/Year Picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: GlassContainer(
                  blur: 15,
                  opacity: 0.15,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.indigo),
                      const SizedBox(width: 8),
                      Text(
                        '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Tab Bar
        GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          blur: 10,
          opacity: 0.12,
          padding: const EdgeInsets.all(4),
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.indigo.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Expenses'),
              Tab(text: 'Analytics'),
              Tab(text: 'Goals'),
              Tab(text: 'Earnings'),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExpensesTab(ref),
              _buildAnalyticsTab(ref),
              _buildGoalsTab(ref),
              _buildIncomeTab(ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab(WidgetRef ref) {
    final expensesAsyncValue = ref.watch(expensesStreamProvider);

    return expensesAsyncValue.when(
      data: (expenses) => SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => _showAddExpenseModal(context, ref),
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.indigo),
                  tooltip: 'Add Expense',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text('No transactions yet', style: GoogleFonts.outfit(color: Colors.white38)),
                ),
              )
            else
              ..._groupExpensesByEffectiveName(expenses).entries.map((group) {
                final categoryName = group.key;
                final categoryExpenses = group.value;
                final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
                
                // Get color/icon from the first expense in the group (they should all be the same category)
                final firstExpense = categoryExpenses.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        categoryName,
                        style: GoogleFonts.outfit(
                          fontSize: 14, 
                          color: _getCategoryColor(firstExpense.category), 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    ...categoryExpenses.map((expense) {
                      final percentage = totalSpent > 0 ? (expense.amount / totalSpent * 100).toInt() : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showAddExpenseModal(context, ref, expense: expense),
                          borderRadius: BorderRadius.circular(16),
                          child: _buildExpenseCard(
                            expense.title,
                            '₹${expense.amount.toStringAsFixed(0)}',
                            _getCategoryIcon(expense.category),
                            _getCategoryColor(expense.category),
                            '$percentage%',
                            expense.date,
                            category: categoryName,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildIncomeTab(WidgetRef ref) {
    final incomeAsyncValue = ref.watch(incomeStreamProvider);

    return incomeAsyncValue.when(
      data: (income) => SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Earnings', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => _showAddIncomeModal(context, ref),
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.emerald),
                  tooltip: 'Add Earning',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (income.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text('No earnings yet', style: GoogleFonts.outfit(color: Colors.white38)),
                ),
              )
            else
              ...income.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showAddIncomeModal(context, ref, income: item),
                  borderRadius: BorderRadius.circular(16),
                  child: _buildIncomeCard(item),
                ),
              )),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildIncomeCard(Income income) {
    return GlassContainer(
      blur: 10,
      opacity: 0.08,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.emerald.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, color: AppTheme.emerald, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(income.title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text('${_formatDate(income.date)} • ${_formatTime(income.date)}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          Text('₹${income.amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent: return Icons.home;
      case ExpenseCategory.wifi: return Icons.wifi;
      case ExpenseCategory.groceries: return Icons.shopping_cart;
      case ExpenseCategory.subscriptions: return Icons.subscriptions;
      case ExpenseCategory.shopping: return Icons.shopping_bag;
      case ExpenseCategory.food: return Icons.restaurant;
      case ExpenseCategory.transport: return Icons.directions_car;
      case ExpenseCategory.entertainment: return Icons.movie;
      case ExpenseCategory.other: return Icons.receipt;
      case ExpenseCategory.custom: return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent: return AppTheme.indigo;
      case ExpenseCategory.wifi: return Colors.blue;
      case ExpenseCategory.groceries: return AppTheme.emerald;
      case ExpenseCategory.subscriptions: return AppTheme.rose;
      case ExpenseCategory.shopping: return Colors.orange;
      case ExpenseCategory.food: return Colors.deepOrange;
      case ExpenseCategory.transport: return Colors.teal;
      case ExpenseCategory.entertainment: return Colors.purple;
      case ExpenseCategory.other: return Colors.grey;
      case ExpenseCategory.custom: return AppTheme.indigo;
    }
  }

  Widget _buildExpenseCard(String title, String amount, IconData icon, Color color, String percentage, DateTime date, {required String category}) {
    return GlassContainer(
      blur: 10,
      opacity: 0.08,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(category, style: GoogleFonts.outfit(fontSize: 12, color: color.withValues(alpha: 0.7))),
                const SizedBox(height: 2),
                Text('${_formatDate(date)} • ${_formatTime(date)}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white24)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(percentage, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, List<Expense>> _groupExpensesByEffectiveName(List<Expense> expenses) {
    final groups = <String, List<Expense>>{};
    for (var expense in expenses) {
      final name = expense.category == ExpenseCategory.custom 
          ? (expense.customCategory ?? 'Custom') 
          : expense.category.displayName;
      groups.putIfAbsent(name, () => []).add(expense);
    }
    return groups;
  }

  Widget _buildAnalyticsTab(WidgetRef ref) {
    final expensesAsyncValue = ref.watch(expensesStreamProvider);

    return expensesAsyncValue.when(
      data: (expenses) => SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          children: [
            // Pie Chart
            GlassContainer(
              blur: 10,
              opacity: 0.08,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Spending Breakdown',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (expenses.isEmpty)
                    const SizedBox(height: 200, child: Center(child: Text('No data for charts', style: TextStyle(color: Colors.white38))))
                  else
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _generateSections(expenses),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildLegend(expenses),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Line Chart
          GlassContainer(
            blur: 10,
            opacity: 0.08,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Monthly Trend',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                _buildMonthlyTrend(expenses),
              ],
            ),
          ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildMonthlyTrend(List<Expense> allExpenses) {
    // Generate last 6 months
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));
    
    // Group expenses by month
    final spots = months.asMap().entries.map((entry) {
      final month = entry.value;
      final total = allExpenses
          .where((e) => e.date.year == month.year && e.date.month == month.month)
          .fold(0.0, (sum, e) => sum + e.amount);
      return FlSpot(entry.key.toDouble(), total);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= months.length) return const SizedBox.shrink();
                  return Text(
                    _getMonthShortName(months[value.toInt()].month),
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.indigo,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.indigo.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthShortName(int month) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
  }

  List<PieChartSectionData> _generateSections(List<Expense> expenses) {
    if (expenses.isEmpty) return [];

    final Map<String, double> totals = {};
    double totalAll = 0;
    
    for (var e in expenses) {
      final name = e.category == ExpenseCategory.custom 
          ? (e.customCategory ?? 'Custom') 
          : e.category.displayName;
      
      totals[name] = (totals[name] ?? 0) + e.amount;
      totalAll += e.amount;
    }

    // Sort by amount descending
    final sortedEntries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    // Define a vibrant color palette for dynamic mapping
    final palette = [
      AppTheme.indigo,
      Colors.teal,
      AppTheme.rose,
      Colors.amber,
      AppTheme.emerald,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
      Colors.pinkAccent,
      Colors.blueAccent,
    ];

    final List<PieChartSectionData> sections = [];
    double otherTotal = 0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final percentage = totalAll > 0 ? (entry.value / totalAll * 100) : 0;
      
      // If we have many entries or very small ones, group small ones into "Other"
      // But only if we have more than 6 categories total
      if (sortedEntries.length > 6 && percentage < 4) {
        otherTotal += entry.value;
        continue;
      }

      sections.add(PieChartSectionData(
        value: entry.value,
        color: palette[i % palette.length],
        title: '${percentage.toInt()}%', // Only show percentage as requested
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ));
    }

    if (otherTotal > 0) {
      final percentage = (otherTotal / totalAll * 100);
      sections.add(PieChartSectionData(
        value: otherTotal,
        color: Colors.grey,
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ));
    }

    return sections;
  }

  Widget _buildGoalsTab(WidgetRef ref) {
    final goalsAsyncValue = ref.watch(goalsStreamProvider);

    return goalsAsyncValue.when(
      data: (goals) => SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savings Goals', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => _showAddGoalModal(context, ref),
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.indigo),
                  tooltip: 'Add Goal',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (goals.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('No goals set yet', style: GoogleFonts.outfit(color: Colors.white38)),
              )
            else
              ...goals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showAddGoalModal(context, ref, goal: goal),
                  borderRadius: BorderRadius.circular(20),
                  child: _buildGoalCard(goal.title, goal.currentAmount, goal.targetAmount, Color(goal.colorValue), goal.targetDate),
                ),
              )),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildGoalCard(String title, double current, double target, Color color, DateTime targetDate) {
    final progress = current / target;
    final remaining = target - current;
    
    return GlassContainer(
      blur: 10,
      opacity: 0.08,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.track_changes, color: AppTheme.emerald, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Target: ${_getMonthName(targetDate.month)} ${targetDate.year}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                    Text('₹${current.toInt()} of ₹${target.toInt()}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                  ],
                ),
              ),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.emerald, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emerald),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text('₹${remaining.toInt()} remaining', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildLegend(List<Expense> expenses) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    final Map<String, double> totals = {};
    double totalAll = 0;
    for (var e in expenses) {
      final name = e.category == ExpenseCategory.custom 
          ? (e.customCategory ?? 'Custom') 
          : e.category.displayName;
      totals[name] = (totals[name] ?? 0) + e.amount;
      totalAll += e.amount;
    }

    final sortedEntries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final palette = [
      AppTheme.indigo,
      Colors.teal,
      AppTheme.rose,
      Colors.amber,
      AppTheme.emerald,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
      Colors.pinkAccent,
      Colors.blueAccent,
    ];

    final List<MapEntry<String, Color>> legendItems = [];
    double otherTotal = 0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final percentage = totalAll > 0 ? (entry.value / totalAll * 100) : 0;

      if (sortedEntries.length > 6 && percentage < 4) {
        otherTotal += entry.value;
        continue;
      }
      legendItems.add(MapEntry(entry.key, palette[i % palette.length]));
    }

    if (otherTotal > 0) {
      legendItems.add(const MapEntry('Other', Colors.grey));
    }
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: legendItems.map((entry) {
        return _legendItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }


    void _showAddExpenseModal(BuildContext context, WidgetRef ref, {Expense? expense}) {
    final isEditing = expense != null;
    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(text: expense?.amount.toStringAsFixed(0) ?? '');
    final customCategoryController = TextEditingController(text: expense?.customCategory ?? '');
    
    // Derived state for the hybrid dropdown
    String? selectedHybridValue;
    if (isEditing) {
      if (expense.category == ExpenseCategory.custom) {
        selectedHybridValue = expense.customCategory;
      } else {
        selectedHybridValue = expense.category.name;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final customCategoriesAsync = ref.watch(customCategoriesStreamProvider);
          final savedCustomCategories = customCategoriesAsync.value ?? [];
          
          return _buildAddDataModal(
            context,
            title: isEditing ? 'Edit Expense' : 'Add New Expense',
            fields: [
              _buildModalField('Title', Icons.title, controller: titleController),
              _buildModalField('Amount', Icons.attach_money, controller: amountController, keyboardType: TextInputType.number),
              _buildHybridCategoryDropdown(
                currentValue: selectedHybridValue,
                savedCustomCategories: savedCustomCategories,
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      selectedHybridValue = val;
                      if (val != 'ADD_NEW') {
                        // If it's a standard or saved custom, clear the manual input
                        customCategoryController.clear();
                      }
                    });
                  }
                },
              ),
              if (selectedHybridValue == 'ADD_NEW')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildModalField('New Category Name', Icons.category_outlined, controller: customCategoryController),
                ),
            ],
            onSave: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (titleController.text.isNotEmpty && amount > 0) {
                ExpenseCategory finalCategory = ExpenseCategory.other;
                String? finalCustomName;

                if (selectedHybridValue == 'ADD_NEW') {
                  finalCategory = ExpenseCategory.custom;
                  finalCustomName = customCategoryController.text.isNotEmpty ? customCategoryController.text : 'Custom';
                } else if (savedCustomCategories.contains(selectedHybridValue)) {
                  finalCategory = ExpenseCategory.custom;
                  finalCustomName = selectedHybridValue;
                } else if (selectedHybridValue != null) {
                  try {
                    finalCategory = ExpenseCategory.values.byName(selectedHybridValue!);
                  } catch (_) {
                    finalCategory = ExpenseCategory.other;
                  }
                }

                final newExpense = Expense(
                  id: expense?.id ?? '',
                  title: titleController.text,
                  amount: amount,
                  category: finalCategory,
                  date: expense?.date ?? DateTime.now(),
                  customCategory: finalCustomName,
                );

                if (finalCategory == ExpenseCategory.custom && finalCustomName != null) {
                  ref.read(financeRepositoryProvider).addCustomCategory(finalCustomName);
                }

                if (isEditing) {
                  ref.read(financeRepositoryProvider).updateExpense(newExpense);
                } else {
                  ref.read(financeRepositoryProvider).addExpense(newExpense);
                }
                Navigator.pop(context);
              }
            },
            onDelete: isEditing ? () {
              ref.read(financeRepositoryProvider).deleteExpense(expense.id);
              Navigator.pop(context);
            } : null,
          );
        },
      ),
    );
  }

  void _showAddIncomeModal(BuildContext context, WidgetRef ref, {Income? income}) {
    final isEditing = income != null;
    final titleController = TextEditingController(text: income?.title ?? '');
    final amountController = TextEditingController(text: income?.amount.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddDataModal(
        context,
        title: isEditing ? 'Edit Earning' : 'Add New Earning',
        fields: [
          _buildModalField('Source', Icons.source, controller: titleController),
          _buildModalField('Amount', Icons.attach_money, controller: amountController, keyboardType: TextInputType.number),
        ],
        onSave: () {
          final amount = double.tryParse(amountController.text) ?? 0;
          if (titleController.text.isNotEmpty && amount > 0) {
            final newIncome = Income(
              id: income?.id ?? '',
              title: titleController.text,
              amount: amount,
              date: income?.date ?? DateTime.now(),
            );
            if (isEditing) {
              ref.read(financeRepositoryProvider).updateIncome(newIncome);
            } else {
              ref.read(financeRepositoryProvider).addIncome(newIncome);
            }
            Navigator.pop(context);
          }
        },
        onDelete: isEditing ? () {
          ref.read(financeRepositoryProvider).deleteIncome(income.id);
          Navigator.pop(context);
        } : null,
      ),
    );
  }

  void _showAddGoalModal(BuildContext context, WidgetRef ref, {SavingGoal? goal}) {
    final isEditing = goal != null;
    final titleController = TextEditingController(text: goal?.title ?? '');
    final targetController = TextEditingController(text: goal?.targetAmount.toStringAsFixed(0) ?? '');
    DateTime selectedTargetDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 90));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _buildAddDataModal(
          context,
          title: isEditing ? 'Edit Saving Goal' : 'Create New Goal',
          fields: [
            _buildModalField('Goal Name', Icons.flag_outlined, controller: titleController),
            _buildModalField('Target Amount', Icons.attach_money, controller: targetController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedTargetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(primary: AppTheme.indigo, surface: Color(0xFF1E293B)),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) {
                  setModalState(() => selectedTargetDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target Date', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                        Text('${selectedTargetDate.day} ${_getMonthName(selectedTargetDate.month)} ${selectedTargetDate.year}', 
                          style: GoogleFonts.outfit(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          onSave: () {
            final target = double.tryParse(targetController.text) ?? 0;
            if (titleController.text.isNotEmpty && target > 0) {
              final newGoal = SavingGoal(
                id: goal?.id ?? '',
                title: titleController.text,
                currentAmount: goal?.currentAmount ?? 0,
                targetAmount: target,
                colorValue: goal?.colorValue ?? AppTheme.indigo.toARGB32(),
                targetDate: selectedTargetDate,
              );
              if (isEditing) {
                ref.read(financeRepositoryProvider).updateGoal(newGoal);
              } else {
                ref.read(financeRepositoryProvider).addGoal(newGoal);
              }
              Navigator.pop(context);
            }
          },
          onDelete: isEditing ? () {
            ref.read(financeRepositoryProvider).deleteGoal(goal.id);
            Navigator.pop(context);
          } : null,
        ),
      ),
    );
  }

  Widget _buildHybridCategoryDropdown({
    required String? currentValue,
    required List<String> savedCustomCategories,
    required ValueChanged<String?> onChanged,
  }) {
    final List<DropdownMenuItem<String>> items = [];
    final Set<String> seenValues = {};

    // 1. Add Standard Categories
    for (var cat in ExpenseCategory.values) {
      if (cat == ExpenseCategory.custom) continue;
      if (seenValues.contains(cat.name)) continue;
      
      seenValues.add(cat.name);
      items.add(DropdownMenuItem(
        value: cat.name,
        child: Text(cat.displayName, style: const TextStyle(color: Colors.white)),
      ));
    }

    // 2. Add Saved Custom Categories
    for (var cat in savedCustomCategories) {
      if (seenValues.contains(cat)) continue;
      
      seenValues.add(cat);
      items.add(DropdownMenuItem(
        value: cat,
        child: Text(cat, style: const TextStyle(color: Colors.white)),
      ));
    }

    // 3. Add the "Add New Category" Action
    if (!seenValues.contains('ADD_NEW')) {
      items.add(DropdownMenuItem(
        value: 'ADD_NEW',
        child: Text(
          'Add New Category...',
          style: GoogleFonts.outfit(color: AppTheme.indigo, fontWeight: FontWeight.bold),
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (currentValue != null && seenValues.contains(currentValue)) ? currentValue : null,
          isExpanded: true,
          hint: const Text('Select Category', style: TextStyle(color: Colors.white38)),
          dropdownColor: const Color(0xFF1E293B),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAddDataModal(
    BuildContext context, {
    required String title,
    required List<Widget> fields,
    required VoidCallback onSave,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassContainer(
        blur: 20,
        opacity: 0.15,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: AppTheme.rose),
                    tooltip: 'Delete Entry',
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ...fields,
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Save', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildModalField(String hint, IconData icon, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.white54, size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
