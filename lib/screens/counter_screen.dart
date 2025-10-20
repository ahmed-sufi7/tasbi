import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/counter_provider.dart';
import '../providers/durood_provider.dart';
import '../models/durood.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../utils/haptic_helper.dart';
import '../widgets/progress_ring.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'durood_management_screen.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for celebration
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.elasticOut),
    );

    // Reset to default unlimited mode on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final counterProvider = context.read<CounterProvider>();
      final duroodProvider = context.read<DuroodProvider>();
      
      // Clear any selected durood to show default
      duroodProvider.clearSelection();
      
      // Cancel any active session to start fresh
      if (counterProvider.isSessionActive) {
        counterProvider.cancelSession();
      }
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  void _handleCounterTap() async {
    final counterProvider = context.read<CounterProvider>();
    final duroodProvider = context.read<DuroodProvider>();
    
    // Start session if not active
    if (!counterProvider.isSessionActive) {
      if (duroodProvider.selectedDurood != null) {
        // Start session with selected tasbi
        await counterProvider.startSession(duroodProvider.selectedDurood!);
      } else {
        // Start unlimited default counting
        counterProvider.startUnlimitedSession();
      }
    }
    
    // Increment counter
    counterProvider.increment();
    
    // Haptic feedback
    HapticHelper.light();
    
    // Check if target reached (only for non-unlimited mode)
    if (!counterProvider.isUnlimitedMode && 
        counterProvider.isTargetReached && 
        counterProvider.currentCount == counterProvider.currentSession!.target) {
      _celebrateCompletion();
    }
  }

  void _celebrateCompletion() {
    final duroodProvider = context.read<DuroodProvider>();
    final counterProvider = context.read<CounterProvider>();
    
    // Animate celebration
    _rotateController.forward().then((_) => _rotateController.reverse());
    
    // Haptic feedback
    HapticHelper.success();
    
    // Show notification
    NotificationService.instance.showCompletionNotification(
      duroodProvider.selectedDurood?.name ?? 'Tasbi',
      counterProvider.currentCount,
    );
    
    // Show dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: const Text('You have completed your target!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save & Start New'),
            onPressed: () {
              Navigator.pop(context);
              _saveAndReset();
            },
          ),
        ],
      ),
    );
  }

  void _saveAndReset() {
    final counterProvider = context.read<CounterProvider>();
    final duroodProvider = context.read<DuroodProvider>();
    
    counterProvider.completeSession();
    
    // Clear selection to return to default unlimited mode
    duroodProvider.clearSelection();
    
    // Show interstitial ad occasionally
    if (counterProvider.currentCount % 5 == 0) {
      AdService.instance.showInterstitialAd();
    }
  }

  void _showResetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Counter?'),
        content: const Text('This will save your current progress and start a new session.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              Navigator.pop(context);
              _saveAndReset();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counterProvider = context.watch<CounterProvider>();
    final duroodProvider = context.watch<DuroodProvider>();
    final selectedDurood = duroodProvider.selectedDurood;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: _handleCounterTap,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(theme, duroodProvider),
              
              const SizedBox(height: 20),
            
            // Counter Display
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress Ring
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: ProgressRing(
                      progress: counterProvider.progress,
                      size: 280,
                      strokeWidth: 20,
                      child: _buildCounterDisplay(theme, counterProvider, selectedDurood),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  _buildActionButtons(theme, counterProvider),
                ],
              ),
            ),
            
            // Banner Ad
            if (AdService.instance.bannerAd != null)
              SizedBox(
                height: 60,
                child: AdWidget(ad: AdService.instance.bannerAd!),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAppBar(ThemeData theme, DuroodProvider duroodProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.chart_bar),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          Text(
            'Digital Tasbi',
            style: theme.textTheme.titleLarge,
          ),
          Row(
            children: [
              // Create Button
              IconButton(
                icon: const Icon(CupertinoIcons.add_circled),
                onPressed: () {
                  _showCreateDuroodSheet(duroodProvider);
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay(ThemeData theme, CounterProvider counterProvider, Durood? selectedDurood) {
    final isUnlimited = counterProvider.isUnlimitedMode || selectedDurood == null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tasbi Name or Default Text
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            isUnlimited ? 'صَلَّى ٱللّٰهُ عَلَيْهِ وَآلِهِ وَسَلَّمَ' : selectedDurood!.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: isUnlimited ? 20 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Counter
        Text(
          '${counterProvider.currentCount}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        // Target or Unlimited text
        if (!isUnlimited)
          Text(
            'of ${counterProvider.currentSession?.target ?? selectedDurood!.target}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, CounterProvider counterProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: CupertinoIcons.minus_circle,
            label: 'Undo',
            onTap: counterProvider.currentCount > 0
                ? () {
                    counterProvider.decrement();
                    HapticHelper.light();
                  }
                : null,
            theme: theme,
          ),
          _buildActionButton(
            icon: CupertinoIcons.arrow_clockwise,
            label: 'Reset',
            onTap: counterProvider.isSessionActive && counterProvider.currentCount > 0
                ? _showResetDialog
                : null,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? theme.colorScheme.surface
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isEnabled
                  ? theme.iconTheme.color
                  : theme.iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isEnabled
                    ? theme.textTheme.labelMedium?.color
                    : theme.textTheme.labelMedium?.color?.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDuroodSheet(DuroodProvider duroodProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const DuroodManagementScreen(),
    );
  }
}
