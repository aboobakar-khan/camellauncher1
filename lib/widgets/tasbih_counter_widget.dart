import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasbih_provider.dart';
import '../providers/dhikr_history_provider.dart';
import '../providers/premium_provider.dart';
import '../screens/dhikr_history_screen.dart';
import '../screens/premium_paywall_screen.dart';

/// Ultra-Minimalist Dhikr Counter
/// Professional, modern design matching Prayer Tracker
class TasbihCounterWidget extends ConsumerStatefulWidget {
  const TasbihCounterWidget({super.key});

  @override
  ConsumerState<TasbihCounterWidget> createState() => _TasbihCounterWidgetState();
}

class _TasbihCounterWidgetState extends ConsumerState<TasbihCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Color palette matching prayer tracker
  static const Color _accentGreen = Color(0xFF40C463);
  static const Color _surface = Color(0xFF161B22);
  static const Color _muted = Color(0xFF484F58);
  static const Color _dimGrey = Color(0xFF21262D);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    
    final state = ref.read(tasbihProvider);
    final wasComplete = state.currentCount >= state.targetCount;
    
    ref.read(tasbihProvider.notifier).increment();
    
    // Celebratory feedback on target completion
    if (!wasComplete && ref.read(tasbihProvider).currentCount >= state.targetCount) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
      
      ref.read(dhikrHistoryProvider.notifier).recordSession(
        dhikrIndex: state.selectedDhikrIndex,
        count: state.targetCount,
      );
      
      ref.read(dhikrHistoryProvider.notifier).updateLongestStreak(
        ref.read(tasbihProvider).streakDays,
      );
    }
  }

  void _openHistory() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (context) => const DhikrHistoryScreen()),
    );
  }

  void _showDhikrPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _DhikrPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasbihProvider);
    final dhikr = Dhikr.presets[state.selectedDhikrIndex];
    final progress = state.currentCount / state.targetCount;
    final isComplete = state.currentCount >= state.targetCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accentGreen.withValues(alpha: isComplete ? 0.4 : 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Text(
                'Dhikr',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Streak indicator
              if (state.streakDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔥',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${state.streakDays}',
                        style: TextStyle(
                          color: _accentGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _openHistory,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 18,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Dhikr selector
          GestureDetector(
            onTap: _showDhikrPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _dimGrey,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dhikr.arabic,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.unfold_more,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Main counter tap area - CIRCULAR
          GestureDetector(
            onTap: _onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
              child: Column(
                children: [
                  // Circular progress ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background ring
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(_dimGrey),
                        ),
                      ),
                      // Progress ring
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, value, _) => CircularProgressIndicator(
                            value: value,
                            strokeWidth: 3,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              isComplete ? _accentGreen : _accentGreen.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                      // Count in center
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${state.currentCount}',
                            style: TextStyle(
                              color: isComplete ? _accentGreen : Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w200,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.targetCount}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.25),
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tap hint
                  Text(
                    isComplete ? '✓ Complete' : 'tap to count',
                    style: TextStyle(
                      color: isComplete 
                          ? _accentGreen.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.2),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Today', value: '${state.todayCount}'),
                Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.04)),
                _StatItem(label: 'Month', value: '${state.monthlyTotal}'),
                Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.04)),
                // Reset button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(tasbihProvider.notifier).reset();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Dhikr Picker Bottom Sheet with Premium Gating
/// Free: 3 dhikr | Premium: All dhikr presets
class _DhikrPickerSheet extends ConsumerWidget {
  const _DhikrPickerSheet();

  static const int freeDhikrCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title with premium badge
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose Dhikr',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isPremium) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40C463).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF40C463).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${Dhikr.presets.length - freeDhikrCount} PRO',
                      style: const TextStyle(
                        color: Color(0xFF40C463),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Dhikr list
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: Dhikr.presets.length,
              itemBuilder: (context, index) {
                final dhikr = Dhikr.presets[index];
                final isSelected = index == state.selectedDhikrIndex;
                final isLocked = !isPremium && index >= freeDhikrCount;
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    
                    if (isLocked) {
                      Navigator.pop(context);
                      showPremiumPaywall(
                        context,
                        triggerFeature: 'Dhikr: ${dhikr.transliteration}',
                      );
                      return;
                    }
                    
                    ref.read(tasbihProvider.notifier).selectDhikr(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF40C463).withValues(alpha: 0.12)
                          : isLocked
                              ? const Color(0xFF21262D).withValues(alpha: 0.5)
                              : const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF40C463).withValues(alpha: 0.3)
                            : isLocked
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dhikr.arabic,
                                style: TextStyle(
                                  color: isLocked 
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : isSelected 
                                          ? Colors.white 
                                          : Colors.white.withValues(alpha: 0.7),
                                  fontSize: 18,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dhikr.transliteration,
                                style: TextStyle(
                                  color: isLocked
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : isSelected 
                                          ? const Color(0xFF40C463).withValues(alpha: 0.8)
                                          : Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF40C463), Color(0xFF30A14E)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF40C463),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Target selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [33, 99, 100, 500, 1000].map((target) {
                    final isSelected = target == state.targetCount;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(tasbihProvider.notifier).setTarget(target);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF40C463).withValues(alpha: 0.15)
                                : const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF40C463).withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$target',
                              style: TextStyle(
                                color: isSelected 
                                    ? const Color(0xFF40C463)
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
