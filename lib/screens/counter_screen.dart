import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/counter_provider.dart';
import '../providers/durood_provider.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../utils/haptic_helper.dart';
import '../widgets/counter_button.dart';
import '../widgets/progress_ring.dart';
import '../widgets/durood_selector.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for counter button
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Rotation animation for celebration
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.elasticOut),
    );

    // Load active session if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounterProvider>().loadActiveSession();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _handleCounterTap() {
    final counterProvider = context.read<CounterProvider>();
    final duroodProvider = context.read<DuroodProvider>();
    
    if (!counterProvider.isSessionActive && duroodProvider.selectedDurood != null) {
      // Start new session
      counterProvider.startSession(duroodProvider.selectedDurood!);
    }
    
    // Animate button
    _scaleController.forward().then((_) => _scaleController.reverse());
    
    // Increment counter
    counterProvider.increment();
    
    // Haptic feedback
    HapticHelper.light();
    
    // Check if target reached
    if (counterProvider.isTargetReached && counterProvider.currentCount == counterProvider.currentSession!.target) {
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
    counterProvider.completeSession();
    
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
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(theme),
            
            // Durood Selector
            if (selectedDurood != null)
              DuroodSelector(
                durood: selectedDurood,
                onChanged: (durood) {
                  if (counterProvider.isSessionActive && counterProvider.currentCount > 0) {
                    _showSwitchDuroodDialog(durood);
                  } else {
                    duroodProvider.selectDurood(durood);
                  }
                },
              ),
            
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
                      child: _buildCounterDisplay(theme, counterProvider),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Counter Button
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: CounterButton(
                      onTap: _handleCounterTap,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
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
    );
  }

  Widget _buildAppBar(ThemeData theme) {
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
    );
  }

  Widget _buildCounterDisplay(ThemeData theme, CounterProvider counterProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${counterProvider.currentCount}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'of ${counterProvider.currentSession?.target ?? 0}',
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

  void _showSwitchDuroodDialog(durood) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Switch Durood?'),
        content: const Text('This will save your current progress and start a new session with the selected durood.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Switch'),
            onPressed: () {
              Navigator.pop(context);
              context.read<CounterProvider>().saveSession();
              context.read<DuroodProvider>().selectDurood(durood);
            },
          ),
        ],
      ),
    );
  }
}
