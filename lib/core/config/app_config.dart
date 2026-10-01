class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'StaffPulse';
  static const String appVersion = '1.0.0';
  static const String appBundleId = 'com.staffpulse.app';

  // RevenueCat API Keys
  static const String revenueCatAndroidApiKey = 'test_QBjNjrsMAQsOizncYHPgfSeczxl';
  static const String revenueCatTestApiKey = 'test_QBjNjrsMAQsOizncYHPgfSeczxl';
  static const String revenueCatIosApiKey = 'test_QBjNjrsMAQsOizncYHPgfSeczxl';

  // RevenueCat Entitlements
  static const String proEntitlement = 'staffpulse_pro';

  // RevenueCat Offering IDs
  static const String defaultOfferingId = 'default';

  // Hive Boxes
  static const String settingsBox = 'settings';
  static const String pulseBox = 'pulse_checkins';
  static const String userBox = 'user_data';

  // Free Tier Limits
  static const int freeMaxTeamMembers = 3;
  static const int freePulseHistoryDays = 7;

  // Pulse Check-In Cooldown (hours)
  static const int pulseCheckinCooldownHours = 20;

  // Daily reminder defaults
  static const int defaultReminderHour = 17; // 5 PM
  static const int defaultReminderMinute = 0;

  // App Store Links (fill in after publishing)
  static const String privacyPolicyUrl = 'https://staffpulse.app/privacy';
  static const String termsOfServiceUrl = 'https://staffpulse.app/terms';
  static const String supportEmail = 'support@staffpulse.app';
}
