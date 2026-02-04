import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usage_stats_provider.dart';
import '../providers/premium_provider.dart';
import '../screens/screen_time_screen.dart';
import '../screens/premium_paywall_screen.dart';

/// Screen Time Dashboard Widget - PREMIUM FEATURE
/// Compact widget showing today's screen time summary
class ScreenTimeWidget extends ConsumerWidget {
  const ScreenTimeWidget({super.key});

  static const Color _green = Color(0xFF40C463);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageState = ref.watch(usageStatsProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final today = usageState.todaySummary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        
        if (!isPremium) {
          showPremiumPaywall(context, triggerFeature: 'Screen Time Analytics');
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScreenTimeScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPremium
                ? [
                    _green.withValues(alpha: 0.08),
                    _green.withValues(alpha: 0.04),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.01),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? _green.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPremium
                    ? _green.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: isPremium
                        ? _green
                        : Colors.white.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  if (!isPremium)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Screen Time',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: isPremium ? 0.9 : 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF40C463), Color(0xFF30A14E)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (isPremium && today != null)
                    Row(
                      children: [
                        Text(
                          today.formattedTotal,
                          style: TextStyle(
                            color: _green,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' today',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                        if (today.islamicMinutes > 0) ...[
                          const Text(' • '),
                          Text(
                            '${today.islamicMinutes}m Islamic',
                            style: TextStyle(
                              color: _green.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    )
                  else if (isPremium && !usageState.hasPermission)
                    Text(
                      'Enable usage access to track',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      'Analyze your digital habits',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Action
            if (isPremium)
              Icon(
                Icons.arrow_forward_ios,
                color: _green.withValues(alpha: 0.5),
                size: 16,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _green.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Unlock',
                  style: TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
