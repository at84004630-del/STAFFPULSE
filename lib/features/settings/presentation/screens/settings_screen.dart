import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/revenuecat_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: AppConfig.defaultReminderHour,
    minute: AppConfig.defaultReminderMinute,
  );
  bool _isPro = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _checkProStatus();
  }

  void _loadNotificationSettings() {
    try {
      final box = Hive.isBoxOpen(AppConfig.settingsBox)
          ? Hive.box(AppConfig.settingsBox)
          : null;
      if (box != null) {
        final isEnabled = box.get(NotificationService.keyNotificationsEnabled, defaultValue: true) as bool;
        final hour = box.get(NotificationService.keyReminderHour, defaultValue: AppConfig.defaultReminderHour) as int;
        final minute = box.get(NotificationService.keyReminderMinute, defaultValue: AppConfig.defaultReminderMinute) as int;
        setState(() {
          _notificationsEnabled = isEnabled;
          _reminderTime = TimeOfDay(hour: hour, minute: minute);
        });
      }
    } catch (_) {}
  }

  Future<void> _checkProStatus() async {
    final isPro = await RevenueCatService.instance.isProUser();
    if (mounted) {
      setState(() {
        _isPro = isPro;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      if (_notificationsEnabled) {
        await NotificationService.instance.scheduleDailyPulseReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'Settings',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 22),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Pro status banner
                if (!_isLoading && !_isPro)
                  _ProUpgradeBanner()
                      .animate()
                      .fadeIn(duration: 400.ms),
                if (!_isLoading && _isPro)
                  _ProBadgeCard()
                      .animate()
                      .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),

                // Notifications section
                const _SectionHeader(title: '🔔 Notifications'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text('Daily Check-in Reminder', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text('Get reminded to check in daily', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                        value: _notificationsEnabled,
                        activeThumbColor: AppTheme.primaryTeal,
                        onChanged: (val) async {
                          setState(() => _notificationsEnabled = val);
                          if (val) {
                            await NotificationService.instance.scheduleDailyPulseReminder(
                              hour: _reminderTime.hour,
                              minute: _reminderTime.minute,
                            );
                          } else {
                            await NotificationService.instance.cancelDailyReminder();
                          }
                        },
                      ),
                      if (_notificationsEnabled)
                        ListTile(
                          title: Text('Reminder Time', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          trailing: Text(
                            _reminderTime.format(context),
                            style: GoogleFonts.inter(color: AppTheme.primaryTeal, fontWeight: FontWeight.w700),
                          ),
                          onTap: _selectTime,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Privacy section
                const _SectionHeader(title: '🔒 Privacy'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Privacy Policy', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _showLegalDialog(
                          context,
                          'Privacy Policy',
                          'StaffPulse Privacy Policy\n\n1. 100% Anonymous Check-ins: Individual employee mood, energy, and workload submissions are hashed using daily rotating tokens and never linked to employee names, emails, or hardware IDs.\n\n2. Aggregation Safeguard: Team wellness scores and burnout alerts are only displayed when a minimum threshold of 3 team members participate.\n\n3. Data Storage: Anonymized response data is encrypted in transit and at rest via Google Cloud Firestore.\n\n4. Zero Tracking: We do not sell or share employee data with third parties or data brokers.\n\nFor questions, contact privacy@staffpulse.app.',
                        ),
                      ),
                      ListTile(
                        title: Text('Terms of Service', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _showLegalDialog(
                          context,
                          'Terms of Service',
                          'StaffPulse Terms of Service\n\n1. Subscription Terms: StaffPulse Pro provides unlimited team capacity, advanced burnout predictive analytics, and executive PDF reports. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.\n\n2. Billing & Cancellation: Subscriptions are managed directly via your Samsung Galaxy Store or App Store account settings.\n\n3. Workplace Psychological Safety: StaffPulse is an internal team pulse tool and does not replace certified psychological, clinical, or medical care.\n\n4. Contact: support@staffpulse.app.',
                        ),
                      ),
                      ListTile(
                        title: Text('How Anonymization Works', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showAnonymizationInfo(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Account section
                const _SectionHeader(title: '👤 Account'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Restore Purchases', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.refresh),
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final restored = await RevenueCatService.instance.restorePurchases();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(restored ? '✅ Pro access restored!' : 'No purchases found.'),
                            ),
                          );
                          if (restored) setState(() => _isPro = true);
                        },
                      ),
                      ListTile(
                        title: Text('Sign Out', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red)),
                        trailing: const Icon(Icons.logout, color: Colors.red),
                        onTap: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // App info
                Center(
                  child: Text(
                    'StaffPulse v${AppConfig.appVersion}\nBuilt for RevenueCat Ship-a-ton 2026',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, height: 1.6),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnonymizationInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🛡️ How Anonymization Works',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...[
              'Your device ID is hashed with a one-way salt that changes daily.',
              'No name, email, or IP address is ever stored with your check-in.',
              'Managers only see aggregated team data (min. 3 responses).',
              'Even StaffPulse engineers cannot link responses to individuals.',
            ].map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✓', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s, style: GoogleFonts.inter(fontSize: 14, height: 1.4))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ProUpgradeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/paywall'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to Pro', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('Unlimited teams, AI insights & PDF reports', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text('Upgrade', style: GoogleFonts.inter(color: AppTheme.primaryTeal, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBadgeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('StaffPulse Pro', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primaryTeal)),
                Text('All features unlocked. Thank you! 💚', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
