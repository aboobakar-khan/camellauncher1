
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasbih_provider.dart';
import '../providers/dhikr_history_provider.dart';
import '../screens/dhikr_history_screen.dart';

/// Tasbih Counter Widget - Ultra-minimalist design
class TasbihCounterWidget extends ConsumerStatefulWidget {
  const TasbihCounterWidget({super.key});

  @override
  ConsumerState<TasbihCounterWidget> createState() => _TasbihCounterWidgetState();
}

class _TasbihCounterWidgetState extends ConsumerState<TasbihCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    
    // Celebratory feedback and record session on target completion
    if (!wasComplete && ref.read(tasbihProvider).currentCount >= state.targetCount) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
      
      // Record the completed session
      ref.read(dhikrHistoryProvider.notifier).recordSession(
        dhikrIndex: state.selectedDhikrIndex,
        count: state.targetCount,
      );
      
      // Update longest streak
      ref.read(dhikrHistoryProvider.notifier).updateLongestStreak(
        ref.read(tasbihProvider).streakDays,
      );
    }
  }

  void _openHistory() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => const DhikrHistoryScreen(),
      ),
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
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF40C463).withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Dhikr selector - minimal
          GestureDetector(
            onTap: _showDhikrPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dhikr.transliteration.toLowerCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.unfold_more,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Arabic text
          Text(
            dhikr.arabic,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 26,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textDirection: TextDirection.rtl,
          ),
          
          const SizedBox(height: 32),
          
          // Main counter - tap area
          GestureDetector(
            onTap: _onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // Progress ring with count
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 3,
                            backgroundColor: Colors.white.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.06)),
                          ),
                        ),
                        // Progress
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                            duration: const Duration(milliseconds: 200),
                            builder: (context, value, _) => CircularProgressIndicator(
                              value: value,
                              strokeWidth: 3,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(
                                isComplete 
                                    ? const Color(0xFF40C463)
                                    : const Color(0xFF40C463).withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                        // Count
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${state.currentCount}',
                              style: TextStyle(
                                color: isComplete ? const Color(0xFF40C463) : Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w200,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.targetCount}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.25),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Tap hint
                    Text(
                      isComplete ? 'complete' : 'tap to count',
                      style: TextStyle(
                        color: isComplete 
                            ? const Color(0xFF40C463).withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.2),
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Stats row - minimal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('🔥 ${state.streakDays}', 'streak'),
              Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.05)),
              _buildStat('${state.todayCount}', 'today'),
              Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.05)),
              _buildStat('${state.monthlyTotal}', 'month'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons - History and Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // History button
              GestureDetector(
                onTap: _openHistory,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF40C463).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: const Color(0xFF40C463).withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'History',
                        style: TextStyle(
                          color: const Color(0xFF40C463).withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Reset button
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(tasbihProvider.notifier).reset();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Minimal Dhikr picker
class _DhikrPickerSheet extends ConsumerWidget {
  const _DhikrPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihProvider);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'select dhikr',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: Dhikr.presets.length,
              itemBuilder: (context, index) {
                final dhikr = Dhikr.presets[index];
                final isSelected = index == state.selectedDhikrIndex;
                final count = ref.read(tasbihProvider.notifier).getCountForDhikr(index);
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(tasbihProvider.notifier).selectDhikr(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF40C463).withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF40C463).withValues(alpha: 0.2))
                          : null,
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
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 18,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dhikr.transliteration.toLowerCase(),
                                style: TextStyle(
                                  color: isSelected 
                                      ? const Color(0xFF40C463).withValues(alpha: 0.8)
                                      : Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (count > 0)
                          Text(
                            '$count',
                            style: TextStyle(
                              color: const Color(0xFF40C463).withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check,
                            color: const Color(0xFF40C463).withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SafeArea(top: false, child: const SizedBox(height: 8)),
        ],
      ),
    );
  }
}
