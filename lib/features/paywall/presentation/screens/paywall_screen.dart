import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/revenuecat_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offerings? _offerings;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  int _selectedPackageIndex = 1; // Default to annual (best value)

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await RevenueCatService.instance.getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final result = await RevenueCatService.instance.purchasePackage(package);

    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Welcome to StaffPulse Pro!'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      context.go('/manager');
    } else if (!result.cancelled) {
      setState(() => _errorMessage = result.error ?? 'Purchase failed. Please try again.');
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    final restored = await RevenueCatService.instance.restorePurchases();
    if (!mounted) return;
    setState(() => _isPurchasing = false);
    if (restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pro access restored!'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      context.go('/manager');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous purchases found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00BFA6), Color(0xFF006B5E)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildFeaturesList(),
                        const SizedBox(height: 32),
                        _buildPackageSelector(),
                        const SizedBox(height: 24),
                        _buildPurchaseButton(),
                        const SizedBox(height: 16),
                        _buildRestoreButton(),
                        const SizedBox(height: 8),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(color: Colors.red.shade200, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        _buildLegalLinks(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isPurchasing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text('⚡', style: TextStyle(fontSize: 56))
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 16),
        Text(
          'Upgrade to Pro',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          'Unlock AI insights, unlimited teams,\nand PDF wellness reports',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      ('🏢', 'Unlimited team members', 'Free plan: 3 members max'),
      ('🤖', 'AI-powered burnout predictions', 'Spot risks 2 weeks earlier'),
      ('📄', 'PDF wellness reports', 'Share with HR & leadership'),
      ('📊', '30-day analytics history', 'Free plan: 7 days only'),
      ('🔔', 'Smart burnout alerts', 'Real-time manager notifications'),
      ('🌐', 'Multi-team management', 'Manage multiple departments'),
    ];

    return Column(
      children: features
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(e.value.$1, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.value.$2,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          e.value.$3,
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Color(0xFF5DF2D6), size: 20),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))
                .slideX(begin: 0.2, end: 0),
          )
          .toList(),
    );
  }

  Widget _buildPackageSelector() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    // Use real RevenueCat packages if available, else show UI placeholders
    final packages = _offerings?.current?.availablePackages;
    final hasPackages = packages != null && packages.isNotEmpty;

    final planLabels = hasPackages
        ? packages.map((p) => (
              p.packageType == PackageType.annual ? 'Annual' : 'Monthly',
              p.storeProduct.priceString,
              p.packageType == PackageType.annual ? 'Save 33%' : null,
              p,
            )).toList()
        : [
            ('Monthly', '\$4.99/mo', null, null),
            ('Annual', '\$39.99/yr', 'Save 33%', null),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...planLabels.asMap().entries.map((e) {
          final isSelected = e.key == _selectedPackageIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedPackageIndex = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppTheme.primaryTeal : Colors.white60,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasPackages ? e.value.$1 : e.value.$1,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppTheme.primaryTeal : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          hasPackages ? e.value.$2 : e.value.$2,
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.grey : Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasPackages ? e.value.$3 != null : e.value.$3 != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasPackages ? e.value.$3! : e.value.$3!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildPurchaseButton() {
    final packages = _offerings?.current?.availablePackages;
    final hasPackages = packages != null && packages.isNotEmpty;
    final selectedPackage = hasPackages && _selectedPackageIndex < packages.length
        ? packages[_selectedPackageIndex]
        : null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPurchasing
            ? null
            : () {
                if (selectedPackage != null) {
                  _purchasePackage(selectedPackage);
                } else {
                  // Sandbox / demo mode
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 StaffPulse Pro Activated (Demo / Sandbox)!'),
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  );
                  context.go('/manager');
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryTeal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          '🚀 Start Pro — Risk Free',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 850.ms);
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _restorePurchases,
      child: Text(
        'Restore Purchases',
        style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _showLegalDialog(
            context,
            'Privacy Policy',
            'StaffPulse Privacy Policy\n\n1. 100% Anonymous Check-ins: Individual employee mood, energy, and workload submissions are hashed using daily rotating tokens and never linked to employee names, emails, or hardware IDs.\n\n2. Aggregation Safeguard: Team wellness scores and burnout alerts are only displayed when a minimum threshold of 3 team members participate.\n\n3. Data Storage: Anonymized response data is encrypted in transit and at rest via Google Cloud Firestore.\n\n4. Zero Tracking: We do not sell or share employee data with third parties or data brokers.\n\nFor questions, contact privacy@staffpulse.app.',
          ),
          child: Text(
            'Privacy Policy',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, decoration: TextDecoration.underline),
          ),
        ),
        Text('·', style: GoogleFonts.inter(color: Colors.white38)),
        TextButton(
          onPressed: () => _showLegalDialog(
            context,
            'Terms of Service',
            'StaffPulse Terms of Service\n\n1. Subscription Terms: StaffPulse Pro provides unlimited team capacity, advanced burnout predictive analytics, and executive PDF reports. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.\n\n2. Billing & Cancellation: Subscriptions are managed directly via your Samsung Galaxy Store or App Store account settings.\n\n3. Workplace Psychological Safety: StaffPulse is an internal team pulse tool and does not replace certified psychological, clinical, or medical care.\n\n4. Contact: support@staffpulse.app.',
          ),
          child: Text(
            'Terms of Service',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, decoration: TextDecoration.underline),
          ),
        ),
      ],
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
