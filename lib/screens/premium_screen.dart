import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_provider.dart';
import '../providers/theme_provider.dart';

/// Premium Screen - Unlock Pro Features
/// Minimalist design showcasing premium features
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int selectedPlanIndex = 2; // Default to Lifetime (index 2)

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider);
    final currentTheme = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Status badge
                  if (isPremium)
                    _buildPremiumBadge(currentTheme)
                  else
                    _buildUpgradePrompt(),

                  const SizedBox(height: 40),

                  // Pricing cards
                  if (!isPremium) ...[
                    _buildPricingCards(currentTheme),
                    const SizedBox(height: 40),
                  ],

                  // Features list
                  _buildFeaturesList(currentTheme),

                  const SizedBox(height: 40),

                  // Action button
                  if (!isPremium) ...[
                    _buildUpgradeButton(context, ref, currentTheme),
                    const SizedBox(height: 16),
                    _buildRestoreButton(context, ref),
                  ],

                  const SizedBox(height: 20),

                  // Terms
                  _buildTermsText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          const Text(
            'PRO VERSION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance with back button
        ],
      ),
    );
  }

  Widget _buildPremiumBadge(AppThemeColor currentTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: currentTheme.color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: currentTheme.color, size: 24),
          const SizedBox(width: 12),
          Text(
            'PREMIUM ACTIVE',
            style: TextStyle(
              color: currentTheme.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt() {
    return Column(
      children: [
        Icon(
          Icons.star_border_rounded,
          color: Colors.white.withValues(alpha: 0.8),
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock Premium',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Experience the full potential',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCards(AppThemeColor currentTheme) {
    final pricingPlans = [
      _PricingPlan(
        title: 'Monthly',
        price: '\$4.99',
        period: '/month',
        savings: null,
      ),
      _PricingPlan(
        title: 'Yearly',
        price: '\$29.99',
        period: '/year',
        savings: 'Save 50%',
      ),
      _PricingPlan(
        title: 'Lifetime',
        price: '\$49.99',
        period: 'once',
        savings: 'Best Value',
        isPopular: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'CHOOSE YOUR PLAN',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: pricingPlans.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 111.127,
                    child: _buildPricingCard(plan, currentTheme, index),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    _PricingPlan plan,
    AppThemeColor currentTheme,
    int index,
  ) {
    final isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        duration: const Duration(milliseconds: 200),

        decoration: BoxDecoration(
          color: isSelected
              ? currentTheme.color.withValues(alpha: 0.15)
              : plan.isPopular
              ? currentTheme.color.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.amber
                : plan.isPopular
                ? currentTheme.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected
                ? 2.5
                : plan.isPopular
                ? 2
                : 1,
          ),
        ),
        child: Column(
          children: [
            if (plan.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: currentTheme.color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            Text(
              plan.title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.price,
                  style: TextStyle(
                    color: isSelected || plan.isPopular
                        ? currentTheme.color
                        : Colors.white.withValues(alpha: 0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              plan.period,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (plan.savings != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  plan.savings!,
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppThemeColor currentTheme) {
    final features = [
      _PremiumFeature(
        icon: Icons.color_lens,
        title: 'All Themes Unlocked',
        description: 'Access to all premium color themes',
      ),
      _PremiumFeature(
        icon: Icons.font_download,
        title: 'Premium Fonts',
        description: 'Exclusive font collections',
      ),
      _PremiumFeature(
        icon: Icons.wallpaper,
        title: 'Premium Wallpapers',
        description: 'Curated minimal backgrounds',
      ),
      _PremiumFeature(
        icon: Icons.widgets,
        title: 'Advanced Widgets',
        description: 'Enhanced productivity tools',
      ),
      _PremiumFeature(
        icon: Icons.install_mobile_rounded,
        title: 'Focus Mode',
        description: 'Work without Distraction',
      ),
      _PremiumFeature(
        icon: Icons.cloud_off,
        title: 'Ad-Free Experience',
        description: 'Clean, distraction-free interface',
      ),
      _PremiumFeature(
        icon: Icons.mobile_off_rounded,
        title: 'Multiple App Interrupts',
        description: 'Reduce App usage with multiple Interrupts',
      ),
      _PremiumFeature(
        icon: Icons.sync,
        title: 'Cloud Sync',
        description: 'Backup & sync across devices',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'PREMIUM FEATURES',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        ...features.map((feature) => _buildFeatureItem(feature, currentTheme)),
      ],
    );
  }

  Widget _buildFeatureItem(
    _PremiumFeature feature,
    AppThemeColor currentTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: currentTheme.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(feature.icon, color: currentTheme.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(
    BuildContext context,
    WidgetRef ref,
    AppThemeColor currentTheme,
  ) {
    return InkWell(
      onTap: () => _handlePurchase(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            const Text(
              'UPGRADE TO PRO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _handleRestore(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'RESTORE PURCHASE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: Text(
        'One-time purchase • Lifetime access\nNo subscription required',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    // Simulate purchase process
    // TODO: Integrate with actual payment provider (in_app_purchase package)
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, activate premium
    await ref.read(premiumProvider.notifier).activatePremium();

    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Premium activated! Take benefits from it.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    // Simulate restore process
    // TODO: Integrate with actual payment provider to restore purchases
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      // Show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No previous purchases found',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PremiumFeature {
  final IconData icon;
  final String title;
  final String description;

  _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _PricingPlan {
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool isPopular;

  _PricingPlan({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    this.isPopular = false,
  });
}
