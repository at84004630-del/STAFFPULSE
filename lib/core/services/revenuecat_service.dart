import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/app_config.dart';

/// Service wrapper around RevenueCat Purchases SDK.
/// Handles initialization, entitlement checking, and purchase flows.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _isInitialized = false;
  CustomerInfo? _cachedCustomerInfo;

  /// Initialize RevenueCat with platform-specific API key.
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint('RevenueCat: Running on web — using sandbox mock mode.');
      _isInitialized = true;
      return;
    }

    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.debug : LogLevel.error,
    );

    late PurchasesConfiguration configuration;

    if (kDebugMode && AppConfig.revenueCatTestApiKey.isNotEmpty) {
      debugPrint('RevenueCat: Initializing with Test Store key for sandbox testing.');
      configuration = PurchasesConfiguration(AppConfig.revenueCatTestApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(AppConfig.revenueCatIosApiKey);
    } else if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(AppConfig.revenueCatAndroidApiKey);
    } else {
      // Fallback for other platforms (Samsung Galaxy Store uses Android key)
      configuration = PurchasesConfiguration(AppConfig.revenueCatAndroidApiKey);
    }

    await Purchases.configure(configuration);
    _isInitialized = true;

    // Cache initial customer info safely
    try {
      _cachedCustomerInfo = await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat: Initial customer info fetch deferred: $e');
    }
  }

  /// Identify user (call after login/signup)
  Future<void> identifyUser(String userId) async {
    await Purchases.logIn(userId);
    _cachedCustomerInfo = await Purchases.getCustomerInfo();
  }

  /// Log out user (call on sign out)
  Future<void> logOut() async {
    await Purchases.logOut();
    _cachedCustomerInfo = null;
  }

  /// Check if user has active Pro entitlement
  Future<bool> isProUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _cachedCustomerInfo = customerInfo;
      return customerInfo.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false;
    } catch (e) {
      debugPrint('RevenueCat: Error checking entitlement: $e');
      // Fall back to cached value if network fails
      return _cachedCustomerInfo?.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false;
    }
  }

  /// Get sync cached pro status (use when you can't await)
  bool get isCachedProUser =>
      _cachedCustomerInfo?.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false;

  /// Fetch available offerings (paywalls/packages)
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat: Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a specific package
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _cachedCustomerInfo = customerInfo;
      final isActive =
          customerInfo.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false;
      return PurchaseResult(success: isActive, customerInfo: customerInfo);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseResult(success: false, cancelled: true);
      }
      return PurchaseResult(success: false, error: e.toString());
    } catch (e) {
      return PurchaseResult(success: false, error: e.toString());
    }
  }

  /// Restore previous purchases (REQUIRED by Apple/Samsung guidelines)
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _cachedCustomerInfo = customerInfo;
      return customerInfo.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false;
    } catch (e) {
      debugPrint('RevenueCat: Error restoring purchases: $e');
      return false;
    }
  }

  /// Refresh customer info from server
  Future<CustomerInfo?> refreshCustomerInfo() async {
    try {
      _cachedCustomerInfo = await Purchases.getCustomerInfo();
      return _cachedCustomerInfo;
    } catch (e) {
      return _cachedCustomerInfo;
    }
  }
}

class PurchaseResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final CustomerInfo? customerInfo;

  const PurchaseResult({
    required this.success,
    this.cancelled = false,
    this.error,
    this.customerInfo,
  });
}
