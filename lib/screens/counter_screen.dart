import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/counter_provider.dart';
import '../providers/durood_provider.dart';
import '../models/durood.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../utils/haptic_helper.dart';
import '../widgets/clock_face_progress_ring.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true; // Sound enabled by default
  bool _isVibrateEnabled = false;

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

    // Initialize audio player with low latency mode
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);

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
    _audioPlayer.dispose();
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
    
    // Play sound if enabled
    if (_isSoundEnabled) {
      _playTapSound();
    }
    
    // Vibration/Haptic feedback based on vibrate toggle
    if (_isVibrateEnabled) {
      HapticFeedback.vibrate(); // Actual vibration when enabled
    } else {
      HapticHelper.light(); // Light haptic feedback when disabled
    }
    
    // Check if target reached (only for non-unlimited mode)
    if (!counterProvider.isUnlimitedMode && 
        counterProvider.isTargetReached && 
        counterProvider.currentCount == counterProvider.currentSession!.target) {
      _celebrateCompletion();
    }
  }

  void _playTapSound() async {
    try {
      debugPrint('Attempting to play tap sound...');
      // Use a fresh play for each tap
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(1.0); // Increase volume to full
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
      debugPrint('Sound played successfully');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });
    HapticHelper.light();
    debugPrint('Sound enabled: $_isSoundEnabled');
  }

  void _toggleVibrate() {
    setState(() {
      _isVibrateEnabled = !_isVibrateEnabled;
    });
    HapticHelper.light();
    debugPrint('Vibrate enabled: $_isVibrateEnabled');
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
      duroodProvider.selectedDurood?.name ?? 'Tasbeeh',
      counterProvider.currentCount,
    );
    
    // Show dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final duroodProvider = context.read<DuroodProvider>();
    final selectedDurood = duroodProvider.selectedDurood;
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text('You have completed ${selectedDurood?.name ?? "your target"}!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue Counting'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save & Restart'),
            onPressed: () {
              Navigator.pop(context);
              _saveAndRestartSameTasbeeh();
            },
          ),
        ],
      ),
    );
  }

  void _saveAndRestartSameTasbeeh() async {
    final counterProvider = context.read<CounterProvider>();
    final duroodProvider = context.read<DuroodProvider>();
    final currentDurood = duroodProvider.selectedDurood;
    
    // Save the completed session
    await counterProvider.completeSession();
    
    // Restart the same tasbi (don't clear selection)
    if (currentDurood != null) {
      await counterProvider.startSession(currentDurood);
    }
    
    // Show interstitial ad occasionally
    if (counterProvider.currentCount % 5 == 0) {
      AdService.instance.showInterstitialAd();
    }
  }

  void _saveAndReset() async {
    final counterProvider = context.read<CounterProvider>();
    final duroodProvider = context.read<DuroodProvider>();
    final currentDurood = duroodProvider.selectedDurood;
    
    // Save the current session
    await counterProvider.completeSession();
    
    // If there's a selected durood, restart it; otherwise go to default unlimited
    if (currentDurood != null) {
      await counterProvider.startSession(currentDurood);
    } else {
      // Clear selection to return to default unlimited mode
      duroodProvider.clearSelection();
    }
    
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
              // Simplified App Bar
              _buildAppBar(theme, duroodProvider),
              
              const SizedBox(height: 8),
              
              // Main Arabic heading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E90FF),
                    height: 1.4,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 6),
            
            // Counter Display
            Expanded(
              child: Stack(
                children: [
                  // Main counter ring
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Horizontal action bar
                        _buildActionBar(theme, counterProvider),
                        
                        const SizedBox(height: 16),
                        
                        // Clock-face progress ring
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: ClockFaceProgressRing(
                            progress: counterProvider.progress,
                            endpointProgress: counterProvider.endpointProgress,
                            currentCount: counterProvider.currentCount,
                            size: 280,
                            strokeWidth: 22,
                            showClockFace: true,
                            showMilestones: !counterProvider.isUnlimitedMode,
                            milestones: const [100, 300, 500, 1000],
                            child: _buildCounterDisplay(theme, counterProvider),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bottom label
                        _buildBottomLabel(theme, counterProvider, selectedDurood),
                        
                        // Add bottom spacing for floating nav bar and banner ad
                        const SizedBox(height: 160), // Increased from 100 to accommodate banner ad (60) + spacing
                      ],
                    ),
                  ),
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
          const SizedBox(width: 48), // Balanced spacing
          Text(
            'Digital Tasbeeh',
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

  Widget _buildActionBar(ThemeData theme, CounterProvider counterProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A).withOpacity(0.3), // Same grey as ring background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sound button
          _buildActionButton(
            icon: CupertinoIcons.volume_up,
            isActive: _isSoundEnabled,
            onTap: _toggleSound,
          ),
          const SizedBox(width: 8),
          
          // Vibrate button
          _buildActionButton(
            icon: CupertinoIcons.device_phone_portrait,
            isActive: _isVibrateEnabled,
            onTap: _toggleVibrate,
          ),
          const SizedBox(width: 8),
          
          // Undo button (minus)
          _buildActionButton(
            icon: CupertinoIcons.minus,
            isEnabled: counterProvider.currentCount > 0,
            alwaysBlue: true,
            onTap: () {
              counterProvider.decrement();
              HapticHelper.light();
            },
          ),
          const SizedBox(width: 8),
          
          // Restart button
          _buildActionButton(
            icon: CupertinoIcons.arrow_clockwise,
            isEnabled: counterProvider.isSessionActive && counterProvider.currentCount > 0,
            alwaysBlue: true,
            onTap: () {
              _showResetDialog();
            },
          ),
          const SizedBox(width: 8),
          
          // Rate button
          _buildActionButton(
            icon: CupertinoIcons.star,
            alwaysBlue: true,
            onTap: () {
              // TODO: Open rate dialog/store
              HapticHelper.light();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isEnabled = true,
    bool isActive = false,
    bool alwaysBlue = false,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Icon(
        icon,
        size: 20,
        color: (isActive || alwaysBlue)
            ? const Color(0xFF1E90FF) // Blue when active or always blue
            : Colors.white.withOpacity(0.8), // White when inactive
      ),
    );
  }

  Widget _buildCounterDisplay(ThemeData theme, CounterProvider counterProvider) {
    final isUnlimited = counterProvider.isUnlimitedMode;
    final hasTarget = !isUnlimited && counterProvider.currentSession != null;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400), // 300-500ms as per design system
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0.95, end: 1.0),
      key: ValueKey<int>(counterProvider.currentCount), // Trigger animation on count change
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: scale, // Fade in with scale
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Large count display (as per design system: 72-96px, weight 200-300)
                Text(
                  '${counterProvider.currentCount}',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: Color(0xFF1E90FF), // primary_accent from design system
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),
                
                // Target count (for non-unlimited mode)
                if (hasTarget)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '/ ${counterProvider.currentSession!.target}',
                      style: const TextStyle(
                        fontSize: 20, // time_unit size: 24-28px from design system
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8A8A8A), // text_secondary from design system
                        letterSpacing: 0,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBottomLabel(ThemeData theme, CounterProvider counterProvider, Durood? selectedDurood) {
    final isUnlimited = counterProvider.isUnlimitedMode || selectedDurood == null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        isUnlimited ? 'صَلَّى ٱللّٰهُ عَلَيْهِ وَآلِهِ وَسَلَّمَ' : selectedDurood!.name,
        style: TextStyle(
          fontSize: 18, // bottom_label: 20-24px from design system
          fontWeight: FontWeight.w400, // Regular weight
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTopRightButtons(ThemeData theme, CounterProvider counterProvider) {
    return Row(
      children: [
        // Undo button
        GestureDetector(
          onTap: counterProvider.currentCount > 0
              ? () {
                  counterProvider.decrement();
                  HapticHelper.light();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: counterProvider.currentCount > 0
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF1A1A1A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF3A3A3A),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.arrow_counterclockwise,
              size: 20,
              color: counterProvider.currentCount > 0
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Reset button
        GestureDetector(
          onTap: counterProvider.isSessionActive && counterProvider.currentCount > 0
              ? _showResetDialog
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: counterProvider.isSessionActive && counterProvider.currentCount > 0
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF1A1A1A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF3A3A3A),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.arrow_clockwise,
              size: 20,
              color: counterProvider.isSessionActive && counterProvider.currentCount > 0
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateDuroodSheet(DuroodProvider duroodProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const DuroodManagementScreen(),
    );
  }
}
