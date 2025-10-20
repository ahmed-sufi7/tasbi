import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../services/purchase_service.dart';
import '../models/notification_settings.dart';
import '../config/app_config.dart';
import '../utils/haptic_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NotificationSettings _notificationSettings = NotificationSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');
      
      if (settingsJson != null) {
        final map = jsonDecode(settingsJson) as Map<String, dynamic>;
        _notificationSettings = NotificationSettings.fromMap(map);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'notification_settings',
        jsonEncode(_notificationSettings.toMap()),
      );
      
      // Update scheduled notifications
      await NotificationService.instance.scheduleNotificationsFromSettings(
        _notificationSettings,
      );
      
      HapticHelper.success();
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final purchaseService = PurchaseService.instance;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                icon: CupertinoIcons.moon_stars,
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  HapticHelper.selection();
                },
              ),
            ],
          ),
          
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                title: 'Enable Notifications',
                subtitle: 'Receive reminder notifications',
                icon: CupertinoIcons.bell,
                value: _notificationSettings.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationSettings = _notificationSettings.copyWith(
                      isEnabled: value,
                    );
                  });
                  _saveSettings();
                },
              ),
              if (_notificationSettings.isEnabled) ...[
                _buildTile(
                  title: 'Notification Times',
                  subtitle: '${_notificationSettings.times.length} reminders set',
                  icon: CupertinoIcons.time,
                  onTap: () => _showNotificationTimesDialog(),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                ),
                _buildSwitchTile(
                  title: 'Vibrate',
                  subtitle: 'Vibrate on notifications',
                  icon: CupertinoIcons.device_phone_portrait,
                  value: _notificationSettings.vibrate,
                  onChanged: (value) {
                    setState(() {
                      _notificationSettings = _notificationSettings.copyWith(
                        vibrate: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
              ],
            ],
          ),
          
          if (!purchaseService.adsRemoved)
            _buildSection(
              title: 'Premium',
              children: [
                _buildTile(
                  title: 'Remove Ads',
                  subtitle: purchaseService.getRemoveAdsPrice() != null
                      ? 'One-time purchase • ${purchaseService.getRemoveAdsPrice()}'
                      : 'Remove all advertisements',
                  icon: CupertinoIcons.star,
                  onTap: () => _handlePurchaseRemoveAds(),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'UPGRADE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildTile(
                  title: 'Restore Purchases',
                  subtitle: 'Restore previous purchases',
                  icon: CupertinoIcons.arrow_clockwise,
                  onTap: () => _handleRestorePurchases(),
                ),
              ],
            ),
          
          _buildSection(
            title: 'About',
            children: [
              _buildTile(
                title: 'App Version',
                subtitle: AppConfig.appVersion,
                icon: CupertinoIcons.info_circle,
              ),
              _buildTile(
                title: 'Rate App',
                subtitle: 'Share your feedback',
                icon: CupertinoIcons.star,
                onTap: () {
                  // Implement app rating
                },
              ),
              _buildTile(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: CupertinoIcons.doc_text,
                onTap: () {
                  // Implement privacy policy
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return SwitchListTile(
      secondary: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showNotificationTimesDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _NotificationTimesSheet(
        settings: _notificationSettings,
        onSave: (settings) {
          setState(() => _notificationSettings = settings);
          _saveSettings();
        },
      ),
    );
  }

  void _handlePurchaseRemoveAds() async {
    final purchaseService = PurchaseService.instance;
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove Ads'),
        content: const Text('Would you like to remove all advertisements with a one-time purchase?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Purchase'),
            onPressed: () async {
              Navigator.pop(context);
              final success = await purchaseService.purchaseRemoveAds();
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your purchase!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Purchase failed. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleRestorePurchases() async {
    final purchaseService = PurchaseService.instance;
    
    await purchaseService.restorePurchases();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored successfully')),
      );
    }
  }
}

class _NotificationTimesSheet extends StatefulWidget {
  final NotificationSettings settings;
  final ValueChanged<NotificationSettings> onSave;

  const _NotificationTimesSheet({
    Key? key,
    required this.settings,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_NotificationTimesSheet> createState() => _NotificationTimesSheetState();
}

class _NotificationTimesSheetState extends State<_NotificationTimesSheet> {
  late List<NotificationTime> _times;

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.settings.times);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification Times',
                    style: theme.textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.add_circled),
                        onPressed: _addNotificationTime,
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.checkmark_circle_fill),
                        onPressed: () {
                          widget.onSave(widget.settings.copyWith(times: _times));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _times.isEmpty
                  ? Center(
                      child: Text(
                        'No notification times set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _times.length,
                      itemBuilder: (context, index) {
                        return _buildTimeItem(_times[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(NotificationTime time, int index) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time.formattedTime,
                  style: theme.textTheme.titleLarge,
                ),
                if (time.message != null && time.message!.isNotEmpty)
                  Text(
                    time.message!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.delete,
              color: theme.colorScheme.error,
            ),
            onPressed: () {
              setState(() => _times.removeAt(index));
            },
          ),
        ],
      ),
    );
  }

  void _addNotificationTime() async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );

    if (time != null) {
      setState(() {
        _times.add(NotificationTime(
          hour: time.hour,
          minute: time.minute,
          message: 'Time to count your tasbi!',
        ));
      });
    }
  }
}
