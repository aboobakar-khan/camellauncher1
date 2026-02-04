import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/deen_mode_provider.dart';
import '../providers/premium_provider.dart';
import '../screens/deen_mode_entry_screen.dart';
import '../screens/deen_mode_screen.dart';
import '../screens/premium_paywall_screen.dart';

/// Deen Mode Widget - PREMIUM FEATURE
/// Entry point widget for dashboard with premium gating
class DeenModeWidget extends ConsumerWidget {
  const DeenModeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deenMode = ref.watch(deenModeProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    
    // If not premium, show locked state
    if (!isPremium) {
      return _buildLockedCard(context);
    }
    
    // If Deen Mode is active, show status
    if (deenMode.isEnabled && !deenMode.hasExpired) {
      return _buildActiveCard(context, deenMode);
    }
    
    // Show entry card
    return _buildEntryCard(context);
  }

  Widget _buildLockedCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showPremiumPaywall(
          context,
          triggerFeature: 'Deen Mode',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.03),
              Colors.white.withValues(alpha: 0.01),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Locked icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF40C463).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Text(
                    '☪',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 20,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF40C463),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Deen Mode',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Block distractions, focus on faith',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Unlock button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF40C463).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF40C463).withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'Unlock',
                style: TextStyle(
                  color: Color(0xFF40C463),
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

  Widget _buildEntryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeenModeEntryScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF40C463).withValues(alpha: 0.08),
              const Color(0xFF30A14E).withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF40C463).withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF40C463).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '☪',
                style: TextStyle(
                  color: const Color(0xFF40C463).withValues(alpha: 0.9),
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deen Mode',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Block distractions, focus on faith',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, dynamic deenMode) {
    final remaining = deenMode.remainingTime;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeenModeScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF40C463).withValues(alpha: 0.15),
              const Color(0xFF30A14E).withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF40C463).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF40C463).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '☪',
                style: TextStyle(
                  color: const Color(0xFF40C463).withValues(alpha: 0.95),
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF40C463),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF40C463).withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deen Mode Active',
                        style: TextStyle(
                          color: const Color(0xFF40C463).withValues(alpha: 0.95),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hours > 0 
                        ? '${hours}h ${minutes}m remaining'
                        : '${minutes}m remaining',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF40C463).withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
