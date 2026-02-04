import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/focus_mode_screen.dart';
import '../screens/focus_mode_settings_screen.dart';
import '../screens/premium_paywall_screen.dart';

/// Focus Mode Widget - PREMIUM FEATURE
/// Compact widget for Dashboard with premium gating
class FocusModeWidget extends ConsumerWidget {
  final VoidCallback? onExpand;

  const FocusModeWidget({super.key, this.onExpand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusMode = ref.watch(focusModeProvider);
    final themeColor = ref.watch(themeColorProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final isActive = focusMode.isEnabled;

    // If not premium, show locked state
    if (!isPremium) {
      return _buildLockedCard(context, themeColor);
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(
                color: themeColor.color.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isActive) {
              // Go to focus mode screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FocusModeScreen()),
              );
            } else {
              // Start focus mode and navigate
              _showQuickStartDialog(context, ref, themeColor);
            }
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FocusModeSettingsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? themeColor.color.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? Icons.do_not_disturb_on : Icons.do_not_disturb_off_outlined,
                    color: isActive ? themeColor.color : Colors.white70,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Focus Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive
                            ? 'Active • ${focusMode.allowedApps.length} apps allowed'
                            : 'Tap to start • Long press for settings',
                        style: TextStyle(
                          color: isActive ? themeColor.color : Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Toggle/Status
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColor.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ON',
                      style: TextStyle(
                        color: themeColor.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.grey[600],
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedCard(BuildContext context, AppThemeColor themeColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showPremiumPaywall(
          context,
          triggerFeature: 'Focus Mode',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    Icon(
                      Icons.do_not_disturb_off_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 24,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF40C463),
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
              
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Focus Mode',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 4),
                    Text(
                      'Block distracting apps and stay focused',
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
      ),
    );
  }

  void _showQuickStartDialog(BuildContext context, WidgetRef ref, AppThemeColor themeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.do_not_disturb_on, color: themeColor.color, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Start Focus Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Block distracting apps and stay focused. Only your allowed apps will be accessible.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            
            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(focusModeProvider.notifier).toggleFocusMode();
                  Navigator.pop(context);
                  
                  // Navigate to focus mode screen
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FocusModeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor.color,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Focus Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Settings link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FocusModeSettingsScreen()),
                  );
                },
                icon: Icon(Icons.settings_outlined, color: Colors.grey[500], size: 18),
                label: Text(
                  'Configure allowed apps first',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
