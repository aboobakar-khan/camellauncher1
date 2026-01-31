import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/todo_widget.dart';
import '../widgets/notes_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/pomodoro_widget.dart';
import '../widgets/focus_mode_widget.dart';
import '../widgets/event_tracker_widget.dart';
import '../widgets/prayer_tracker_widget.dart';
import '../widgets/tasbih_counter_widget.dart';
import 'todo_list_screen.dart';
import 'premium_screen.dart';
import '../features/quran/providers/quran_provider.dart';
import '../features/quran/widgets/tafseer_bottom_sheet.dart';
import '../providers/arabic_font_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/theme_provider.dart';

/// Widget Dashboard - Oasis-style productivity screen
/// Contains cards for To-Do, Notes, Calendar, etc.
class WidgetDashboardScreen extends ConsumerWidget {
  const WidgetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arabicFont = ref.watch(arabicFontProvider);
    final isPremium = ref.watch(premiumProvider);
    final currentTheme = ref.watch(themeColorProvider);

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Column(
        children: [
          // Widget grid
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Tap for next Verse
                  Consumer(
                    builder: (context, ref, child) {
                      final verseAsync = ref.watch(randomVerseProvider);
                      return verseAsync.when(
                        data: (verse) {
                          if (verse == null) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () {
                              // Invalidate the provider to get a new random verse
                              ref.invalidate(randomVerseProvider);
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    255,
                                    133,
                                    252,
                                    137,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: const Color.fromARGB(
                                          255,
                                          133,
                                          252,
                                          137,
                                        ),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tap for next Verse',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    verse['arabic'] as String,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      height: 1.8,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: arabicFont.fontFamily,
                                    ),
                                  ),
                                  if (verse['translation'] != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      textAlign: TextAlign.left,
                                      verse['translation'] as String,
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${verse['surahTransliteration']} ${verse['verseNumber']}',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            133,
                                            252,
                                            137,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          TafseerBottomSheet.show(
                                            context,
                                            surahId: verse['surahId'] as int,
                                            ayahId: verse['verseNumber'] as int,
                                            surahName: verse['surahTransliteration'] as String,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF30A14E).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFF40C463).withValues(alpha: 0.4),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.menu_book_outlined,
                                                size: 14,
                                                color: const Color(0xFF40C463),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Tafseer',
                                                style: TextStyle(
                                                  color: const Color(0xFF40C463),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
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
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      );
                    },
                  ),

                  // Prayer Tracker Widget - 5 times daily prayer tracking
                  const PrayerTrackerWidget(),

                  const SizedBox(height: 16),

                  // Tasbih Counter Widget - Dhikr counting
                  const TasbihCounterWidget(),

                  // Todo Widget
                  TodoWidget(
                    onExpand: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TodoListScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Notes Widget
                  NotesWidget(
                    onExpand: () {
                      // TODO: Navigate to full notes screen
                    },
                  ),

                  const SizedBox(height: 16),

                  // Pomodoro Timer Widget
                  PomodoroWidget(
                    onExpand: () {
                      // TODO: Navigate to full pomodoro screen
                    },
                  ),

                  // Focus Mode Widget (near Pomodoro for productivity)
                  const FocusModeWidget(),

                  const SizedBox(height: 16),

                  // Event Tracker Widget
                  EventTrackerWidget(
                    onExpand: () {
                      // TODO: Navigate to full events screen
                    },
                  ),

                  const SizedBox(height: 16),

                  // Calendar (full width)
                  CalendarWidget(
                    onExpand: () {
                      // TODO: Navigate to full calendar screen
                    },
                  ),

                  const SizedBox(height: 16),

                  // Future widgets can go here
                  // App Usage, Habits, etc.

                  // Premium card (only show if not premium)
                  if (!isPremium) _buildPremiumCard(context, currentTheme),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, AppThemeColor currentTheme) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const PremiumScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentTheme.color.withValues(alpha: 0.2),
              currentTheme.color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: currentTheme.color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 48),
            const SizedBox(height: 12),
            Text(
              'UNLOCK PREMIUM',
              style: TextStyle(
                color: currentTheme.color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get access to all premium features',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'VIEW PLANS',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
