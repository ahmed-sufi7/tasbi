import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/counter_session.dart';
import '../models/durood.dart';
import '../database/database_helper.dart';
import '../utils/date_helper.dart';
import '../providers/counter_provider.dart';
import '../providers/durood_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  Map<String, dynamic> _statistics = {};
  List<CounterSession> _recentSessions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'week'; // week, month, year

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _db.getStatistics();
      final recentSessions = await _getRecentSessions();
      
      // Get current active session from provider
      if (mounted) {
        final counterProvider = context.read<CounterProvider>();
        
        // Calculate accurate statistics including active session
        int totalCount = stats['totalCount'] as int? ?? 0;
        int completedSessions = stats['completedSessions'] as int? ?? 0;
        
        if (counterProvider.isSessionActive) {
          totalCount += counterProvider.currentCount;
        }
        
        setState(() {
          _statistics = {
            'totalCount': totalCount,
            'completedSessions': completedSessions,
            'countByDurood': stats['countByDurood'],
          };
          _recentSessions = recentSessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<CounterSession>> _getRecentSessions() async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30)); // Last 30 days
    return await _db.getSessionsByDateRange(startDate, now);
  }

  Future<Map<String, int>> _getDailyCounts() async {
    final sessions = await _getRecentSessions();
    final dailyCounts = <String, int>{};
    
    // Initialize last 7 days with 0 counts
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';
      dailyCounts[dateKey] = 0;
    }
    
    // Aggregate counts by day
    for (var session in sessions) {
      final date = session.startTime;
      final dateKey = '${date.month}/${date.day}';
      if (dailyCounts.containsKey(dateKey)) {
        dailyCounts[dateKey] = dailyCounts[dateKey]! + session.count;
      }
    }
    
    return dailyCounts;
  }

  Widget _buildAppBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Statistics',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(width: 48), // Balanced spacing
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar to match home screen
            _buildAppBar(theme),
            
            // Content
            Expanded(
              child: _isLoading 
                ? const Center(child: CupertinoActivityIndicator())
                : _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary Cards
          _buildSummaryCards(theme),
          const SizedBox(height: 24),
          
          // Period Selector
          _buildPeriodSelector(theme),
          const SizedBox(height: 24),
          
          // Daily Activity Chart
          _buildDailyActivityChart(theme),
          const SizedBox(height: 32),
          
          // Distribution Chart
          _buildDistributionChart(theme),
          const SizedBox(height: 32),
          
          // Recent Activity
          _buildRecentActivity(theme),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    final totalCount = _statistics['totalCount'] as int? ?? 0;
    final completedSessions = _statistics['completedSessions'] as int? ?? 0;
    
    return Row(
      children: [
        // Total Count Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.square_stack_3d_up,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Count',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalCount.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Completed Sessions Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.checkmark_seal,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sessions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedSessions.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Week',
            isSelected: _selectedPeriod == 'week',
            onTap: () => setState(() => _selectedPeriod = 'week'),
          ),
          _PeriodButton(
            label: 'Month',
            isSelected: _selectedPeriod == 'month',
            onTap: () => setState(() => _selectedPeriod = 'month'),
          ),
          _PeriodButton(
            label: 'Year',
            isSelected: _selectedPeriod == 'year',
            onTap: () => setState(() => _selectedPeriod = 'year'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivityChart(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: FutureBuilder<Map<String, int>>(
              future: _getPeriodicCounts(_selectedPeriod),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  );
                }
                
                final data = snapshot.data!;
                final sortedEntries = data.entries.toList();
                
                // For week view, ensure correct order
                if (_selectedPeriod == 'week') {
                  final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  sortedEntries.sort((a, b) => weekdays.indexOf(a.key).compareTo(weekdays.indexOf(b.key)));
                }
                
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: sortedEntries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) * 1.3,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipMargin: 8,
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            '${sortedEntries[group.x].key}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${sortedEntries[group.x].value} counts',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < sortedEntries.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  sortedEntries[index].key,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ) ?? const TextStyle(),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 32,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Remove vertical labels
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false, // Remove border
                    ),
                    gridData: FlGridData(
                      show: false, // Remove all grid lines
                    ),
                    barGroups: sortedEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final key = entry.value.key;
                      final value = entry.value.value;
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value.toDouble(),
                            color: _getBarColor(value, theme),
                            width: 16,
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getBarColor(int value, ThemeData theme) {
    if (value == 0) return theme.dividerColor.withOpacity(0.2);
    return theme.colorScheme.primary;
  }

  Widget _buildDistributionChart(ThemeData theme) {
    final countByDurood = _statistics['countByDurood'] as List<dynamic>? ?? [];
    
    if (countByDurood.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No data available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Calculate total for percentages
    int total = 0;
    for (var item in countByDurood) {
      total += item['total'] as int;
    }
    
    if (total == 0) {
      return Container();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _generatePieSections(countByDurood, total, theme),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._generateLegendItems(countByDurood, total, theme),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(List<dynamic> data, int total, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];
    
    final sections = <PieChartSectionData>[];
    
    for (int i = 0; i < data.length && i < colors.length; i++) {
      final item = data[i];
      final name = item['name'] as String;
      final count = item['total'] as int;
      final percentage = (count / total) * 100;
      
      sections.add(
        PieChartSectionData(
          color: colors[i],
          value: percentage,
          title: '${percentage.round()}%',
          radius: 50,
          titleStyle: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return sections;
  }

  List<Widget> _generateLegendItems(List<dynamic> data, int total, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];
    
    final items = <Widget>[];
    
    for (int i = 0; i < data.length && i < colors.length; i++) {
      final item = data[i];
      final name = item['name'] as String;
      final count = item['total'] as int;
      final percentage = (count / total) * 100;
      
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '${percentage.round()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return items;
  }

  Widget _buildRecentActivity(ThemeData theme) {
    if (_recentSessions.isEmpty) {
      return Container();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ..._recentSessions.take(5).map((session) {
          return FutureBuilder<Durood?>(
            future: _db.getDurood(session.duroodId),
            builder: (context, snapshot) {
              final durood = snapshot.data;
              return _SessionItem(session: session, durood: durood);
            },
          );
        }),
      ],
    );
  }

  Future<Map<String, int>> _getPeriodicCounts(String period) async {
    final sessions = await _getRecentSessions();
    final periodCounts = <String, int>{};
    
    final now = DateTime.now();
    
    if (period == 'week') {
      // Initialize weekdays with 0 counts
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (final day in weekdays) {
        periodCounts[day] = 0;
      }
      
      // Aggregate counts by weekday for the current week
      for (var session in sessions) {
        final date = session.startTime;
        // Check if the session is within the current week
        if (_isInCurrentWeek(date)) {
          final weekday = _getWeekdayAbbreviation(date.weekday);
          periodCounts[weekday] = (periodCounts[weekday] ?? 0) + session.count;
        }
      }
    } else if (period == 'month') {
      // Initialize weeks with 0 counts
      for (int i = 1; i <= 5; i++) {
        periodCounts['W$i'] = 0;
      }
      
      // Aggregate counts by week of month
      for (var session in sessions) {
        final date = session.startTime;
        // Check if the session is within the current month
        if (_isInCurrentMonth(date)) {
          final weekOfMonth = _getWeekOfMonth(date);
          if (weekOfMonth >= 1 && weekOfMonth <= 5) {
            periodCounts['W$weekOfMonth'] = (periodCounts['W$weekOfMonth'] ?? 0) + session.count;
          }
        }
      }
    } else if (period == 'year') {
      // Initialize months with 0 counts
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (final month in months) {
        periodCounts[month] = 0;
      }
      
      // Aggregate counts by month
      for (var session in sessions) {
        final date = session.startTime;
        // Check if the session is within the current year
        if (date.year == now.year) {
          final monthAbbrev = _getMonthAbbreviation(date.month);
          periodCounts[monthAbbrev] = (periodCounts[monthAbbrev] ?? 0) + session.count;
        }
      }
    }
    
    return periodCounts;
  }
  
  bool _isInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  bool _isInCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  String _getWeekdayAbbreviation(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[(weekday + 5) % 7]; // Adjust for DateTime.weekday (1=Monday)
  }
  
  String _getMonthAbbreviation(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
  
  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final weekOffset = firstDayOfMonth.weekday - 1;
    final adjustedDate = date.day + weekOffset;
    return (adjustedDate / 7).ceil();
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected 
                  ? Colors.white 
                  : theme.textTheme.bodySmall?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final CounterSession session;
  final Durood? durood;

  const _SessionItem({Key? key, required this.session, required this.durood}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: session.isCompleted
            ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.duroodId == 'default' 
                      ? 'Default Tasbeeh' 
                      : (durood?.name ?? 'Unknown'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (session.isCompleted)
                Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                icon: CupertinoIcons.square_stack_3d_up,
                label: '${session.count}',
                theme: theme,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: CupertinoIcons.time,
                label: DateHelper.formatDuration(session.duration),
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateHelper.formatDateTime(session.startTime),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}