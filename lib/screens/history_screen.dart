import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
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

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<CounterSession> _sessions = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _filterPeriod = 'all'; // all, today, week, month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final sessions = await _getFilteredSessions();
      final stats = await _db.getStatistics();
      
      // Get current active session from provider
      if (mounted) {
        final counterProvider = context.read<CounterProvider>();
        final currentSession = counterProvider.currentSession;
        final currentCount = counterProvider.currentCount;
        
        // Add current active session to the list if it exists
        List<CounterSession> allSessions = List.from(sessions);
        if (currentSession != null && counterProvider.isSessionActive) {
          // Create a copy with current count
          final activeSession = currentSession.copyWith(
            count: currentCount,
          );
          allSessions.insert(0, activeSession);
        }
        
        // Calculate accurate statistics including active session
        int totalCount = stats['totalCount'] as int? ?? 0;
        int completedSessions = stats['completedSessions'] as int? ?? 0;
        
        if (currentSession != null && counterProvider.isSessionActive) {
          totalCount += currentCount;
        }
        
        setState(() {
          _sessions = allSessions;
          _statistics = {
            'totalCount': totalCount,
            'completedSessions': completedSessions,
            'countByDurood': stats['countByDurood'],
          };
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

  Future<List<CounterSession>> _getFilteredSessions() async {
    final now = DateTime.now();
    
    switch (_filterPeriod) {
      case 'today':
        return await _db.getSessionsByDateRange(
          DateHelper.startOfDay(now),
          DateHelper.endOfDay(now),
        );
      case 'week':
        return await _db.getSessionsByDateRange(
          DateHelper.startOfWeek(now),
          DateHelper.endOfWeek(now),
        );
      case 'month':
        return await _db.getSessionsByDateRange(
          DateHelper.startOfMonth(now),
          DateHelper.endOfMonth(now),
        );
      default:
        return await _db.getAllSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sessions'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessionsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _sessions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 100, // Extra padding for floating footer
                        ),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          return _SessionItem(session: _sessions[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All Time', 'all', theme),
            const SizedBox(width: 8),
            _buildFilterChip('Today', 'today', theme),
            const SizedBox(width: 8),
            _buildFilterChip('This Week', 'week', theme),
            const SizedBox(width: 8),
            _buildFilterChip('This Month', 'month', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    final isSelected = _filterPeriod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _filterPeriod = value);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No History Yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start counting to see your history here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final theme = Theme.of(context);
    final counterProvider = context.watch<CounterProvider>();
    final duroodProvider = context.watch<DuroodProvider>();
    
    final totalCount = _statistics['totalCount'] as int? ?? 0;
    final completedSessions = _statistics['completedSessions'] as int? ?? 0;
    final countByDurood = _statistics['countByDurood'] as List<dynamic>? ?? [];
    
    // Build count by durood map including current active session
    final Map<String, int> duroodCounts = {};
    for (var item in countByDurood) {
      final name = item['name'] as String;
      final count = item['total'] as int;
      duroodCounts[name] = count;
    }
    
    // Add current active session count
    if (counterProvider.isSessionActive && 
        counterProvider.currentSession != null && 
        duroodProvider.selectedDurood != null) {
      final currentDuroodName = duroodProvider.selectedDurood!.name;
      duroodCounts[currentDuroodName] = 
          (duroodCounts[currentDuroodName] ?? 0) + counterProvider.currentCount;
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 100, // Extra padding for floating footer
        ),
        children: [
          _buildStatCard(
            title: 'Total Count',
            value: totalCount.toString(),
            icon: CupertinoIcons.square_stack_3d_up,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Completed Sessions',
            value: completedSessions.toString(),
            icon: CupertinoIcons.checkmark_seal,
            color: theme.colorScheme.secondary,
          ),
          if (counterProvider.isSessionActive && counterProvider.currentCount > 0) ...[
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Current Session',
              value: '${counterProvider.currentCount} / ${counterProvider.currentSession?.target ?? 0}',
              icon: CupertinoIcons.play_circle,
              color: Colors.orange,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Count by Tasbi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (duroodCounts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No data available yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            )
          else
            ...duroodCounts.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final CounterSession session;

  const _SessionItem({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DatabaseHelper db = DatabaseHelper.instance;
    
    return FutureBuilder<Durood?>(
      future: db.getDurood(session.duroodId),
      builder: (context, snapshot) {
        final durood = snapshot.data;
        
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
                      durood?.name ?? 'Unknown',
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
                    label: '${session.count} / ${session.target}',
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
      },
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
