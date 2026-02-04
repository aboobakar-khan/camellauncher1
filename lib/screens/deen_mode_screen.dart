import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/deen_mode_provider.dart';
import '../providers/tasbih_provider.dart';
import '../features/quran/screens/surah_list_screen.dart';
import '../features/hadith_dua/screens/hadith_dua_screen.dart';
import 'minimalist_duas_screen.dart';

/// Deen Mode Screen - Spiritual Focus Mode
/// Hard to exit: 10-second hold with breathing exercise
class DeenModeScreen extends ConsumerStatefulWidget {
  const DeenModeScreen({super.key});

  @override
  ConsumerState<DeenModeScreen> createState() => _DeenModeScreenState();
}

class _DeenModeScreenState extends ConsumerState<DeenModeScreen> {
  late Timer _timer;
  String _currentTime = '';
  int _quickDhikrCount = 0;

  // Daily verses
  static const List<Map<String, String>> _verses = [
    {'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'translation': 'Indeed, with hardship comes ease.', 'ref': 'Ash-Sharh 94:6'},
    {'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'translation': 'Whoever relies upon Allah - then He is sufficient for him.', 'ref': 'At-Talaq 65:3'},
    {'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ', 'translation': 'So remember Me; I will remember you.', 'ref': 'Al-Baqarah 2:152'},
    {'arabic': 'وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ', 'translation': 'Be patient. Indeed, Allah does not lose the reward of those who do good.', 'ref': 'Hud 11:115'},
    {'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي', 'translation': 'My Lord, expand for me my chest.', 'ref': 'Ta-Ha 20:25'},
  ];

  Map<String, String> get _dailyVerse {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _verses[dayOfYear % _verses.length];
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _quickDhikrCount = ref.read(tasbihProvider).currentCount;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
      
      // Check if session expired
      final deenMode = ref.read(deenModeProvider);
      if (deenMode.isEnabled && deenMode.hasExpired) {
        ref.read(deenModeProvider.notifier).endDeenMode();
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _incrementDhikr() {
    HapticFeedback.lightImpact();
    setState(() => _quickDhikrCount++);
    ref.read(tasbihProvider.notifier).increment();
  }

  void _showExitSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _HardExitSheet(
        onExit: () {
          ref.read(deenModeProvider.notifier).endDeenMode();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openQuran() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const SurahListScreen(),
      ),
    );
  }

  void _openHadith() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const HadithDuaScreen(),
      ),
    );
  }

  void _openDuas() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const MinimalistDuasScreen(),
      ),
    );
  }

  void _open99Names() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const _NamesOfAllahScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deenMode = ref.watch(deenModeProvider);
    final remaining = deenMode.remainingTime;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitSheet();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '☪',
                      style: TextStyle(
                        color: const Color(0xFF40C463).withValues(alpha: 0.7),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'deen mode',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Time remaining
                Text(
                  hours > 0 
                      ? '${hours}h ${minutes}m remaining'
                      : '${minutes}m ${seconds}s remaining',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Current time
                Text(
                  _currentTime,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 64,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Daily verse
                _buildVerseCard(),
                
                const Spacer(),
                
                // Quick dhikr
                GestureDetector(
                  onTap: _incrementDhikr,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_quickDhikrCount',
                          style: TextStyle(
                            color: const Color(0xFF40C463).withValues(alpha: 0.8),
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'tap to count',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.2),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Learning resources
                _buildLearningResources(),
                
                const Spacer(),
                
                // Exit button
                GestureDetector(
                  onTap: _showExitSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'exit',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
    final verse = _dailyVerse;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            verse['arabic']!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 22,
              height: 1.6,
            ),
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            verse['translation']!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '— ${verse['ref']}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningResources() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildResourceButton('📖', 'Quran', _openQuran),
        _buildResourceButton('📚', 'Hadith', _openHadith),
        _buildResourceButton('🤲', 'Duas', _openDuas),
        _buildResourceButton('⭐', '99 Names', _open99Names),
      ],
    );
  }

  Widget _buildResourceButton(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hard Exit Sheet - 10 second hold with breathing exercise
class _HardExitSheet extends StatefulWidget {
  final VoidCallback onExit;

  const _HardExitSheet({required this.onExit});

  @override
  State<_HardExitSheet> createState() => _HardExitSheetState();
}

class _HardExitSheetState extends State<_HardExitSheet> {
  bool _isHolding = false;
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  Timer? _hapticTimer;
  
  static const List<String> _quotes = [
    'Patience is half of faith.',
    'A moment of patience saves a thousand regrets.',
    'Verily, with hardship comes ease.',
    'The strong is one who controls himself.',
  ];

  late String _quote;

  @override
  void initState() {
    super.initState();
    _quote = _quotes[DateTime.now().second % _quotes.length];
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _hapticTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    setState(() => _isHolding = true);
    
    // Progress timer - 10 seconds total
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _holdProgress += 0.01; // 10 seconds = 100 ticks
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          timer.cancel();
          _hapticTimer?.cancel();
          HapticFeedback.heavyImpact();
          widget.onExit();
        }
      });
    });
    
    // Haptic pulse every 2 seconds for breathing rhythm
    _hapticTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isHolding) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _hapticTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final secondsRemaining = (10 - (_holdProgress * 10)).ceil();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quote
            Text(
              _quote,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instruction
            Text(
              'hold for 10 seconds to exit',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Hold button with progress ring
            GestureDetector(
              onTapDown: (_) => _startHold(),
              onTapUp: (_) => _cancelHold(),
              onTapCancel: _cancelHold,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.05)),
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _holdProgress,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        _isHolding 
                            ? const Color(0xFFFF6B35).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$secondsRemaining',
                        style: TextStyle(
                          color: _isHolding 
                              ? const Color(0xFFFF6B35).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.2),
                          fontSize: 36,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      if (_isHolding)
                        Text(
                          '💨',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Breathing prompt
            AnimatedOpacity(
              opacity: _isHolding ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                'breathe deeply...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Continue button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'continue',
                style: TextStyle(
                  color: const Color(0xFF40C463).withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 99 Names of Allah Screen
class _NamesOfAllahScreen extends StatelessWidget {
  const _NamesOfAllahScreen();

  static const List<Map<String, String>> _names = [
    {'arabic': 'الرَّحْمَنُ', 'transliteration': 'Ar-Rahman', 'meaning': 'The Most Gracious'},
    {'arabic': 'الرَّحِيمُ', 'transliteration': 'Ar-Raheem', 'meaning': 'The Most Merciful'},
    {'arabic': 'الْمَلِكُ', 'transliteration': 'Al-Malik', 'meaning': 'The King'},
    {'arabic': 'الْقُدُّوسُ', 'transliteration': 'Al-Quddus', 'meaning': 'The Most Holy'},
    {'arabic': 'السَّلَامُ', 'transliteration': 'As-Salam', 'meaning': 'The Source of Peace'},
    {'arabic': 'الْمُؤْمِنُ', 'transliteration': 'Al-Mu\'min', 'meaning': 'The Guardian of Faith'},
    {'arabic': 'الْمُهَيْمِنُ', 'transliteration': 'Al-Muhaymin', 'meaning': 'The Protector'},
    {'arabic': 'الْعَزِيزُ', 'transliteration': 'Al-Aziz', 'meaning': 'The Almighty'},
    {'arabic': 'الْجَبَّارُ', 'transliteration': 'Al-Jabbar', 'meaning': 'The Compeller'},
    {'arabic': 'الْمُتَكَبِّرُ', 'transliteration': 'Al-Mutakabbir', 'meaning': 'The Supreme'},
    {'arabic': 'الْخَالِقُ', 'transliteration': 'Al-Khaliq', 'meaning': 'The Creator'},
    {'arabic': 'الْبَارِئُ', 'transliteration': 'Al-Bari', 'meaning': 'The Originator'},
    {'arabic': 'الْمُصَوِّرُ', 'transliteration': 'Al-Musawwir', 'meaning': 'The Fashioner'},
    {'arabic': 'الْغَفَّارُ', 'transliteration': 'Al-Ghaffar', 'meaning': 'The Forgiver'},
    {'arabic': 'الْقَهَّارُ', 'transliteration': 'Al-Qahhar', 'meaning': 'The Subduer'},
    {'arabic': 'الْوَهَّابُ', 'transliteration': 'Al-Wahhab', 'meaning': 'The Bestower'},
    {'arabic': 'الرَّزَّاقُ', 'transliteration': 'Ar-Razzaq', 'meaning': 'The Provider'},
    {'arabic': 'الْفَتَّاحُ', 'transliteration': 'Al-Fattah', 'meaning': 'The Opener'},
    {'arabic': 'اَلْعَلِيْمُ', 'transliteration': 'Al-Alim', 'meaning': 'The All-Knowing'},
    {'arabic': 'الْقَابِضُ', 'transliteration': 'Al-Qabid', 'meaning': 'The Restrainer'},
    {'arabic': 'الْبَاسِطُ', 'transliteration': 'Al-Basit', 'meaning': 'The Extender'},
    {'arabic': 'الْخَافِضُ', 'transliteration': 'Al-Khafid', 'meaning': 'The Abaser'},
    {'arabic': 'الرَّافِعُ', 'transliteration': 'Ar-Rafi', 'meaning': 'The Exalter'},
    {'arabic': 'الْمُعِزُّ', 'transliteration': 'Al-Mu\'izz', 'meaning': 'The Honorer'},
    {'arabic': 'الْمُذِلُّ', 'transliteration': 'Al-Mudhill', 'meaning': 'The Humiliator'},
    {'arabic': 'السَّمِيعُ', 'transliteration': 'As-Sami', 'meaning': 'The All-Hearing'},
    {'arabic': 'الْبَصِيرُ', 'transliteration': 'Al-Basir', 'meaning': 'The All-Seeing'},
    {'arabic': 'الْحَكَمُ', 'transliteration': 'Al-Hakam', 'meaning': 'The Judge'},
    {'arabic': 'الْعَدْلُ', 'transliteration': 'Al-Adl', 'meaning': 'The Just'},
    {'arabic': 'اللَّطِيفُ', 'transliteration': 'Al-Latif', 'meaning': 'The Subtle One'},
    {'arabic': 'الْخَبِيرُ', 'transliteration': 'Al-Khabir', 'meaning': 'The All-Aware'},
    {'arabic': 'الْحَلِيمُ', 'transliteration': 'Al-Halim', 'meaning': 'The Forbearing'},
    {'arabic': 'الْعَظِيمُ', 'transliteration': 'Al-Azim', 'meaning': 'The Magnificent'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.7)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '99 Names of Allah',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _names.length,
        itemBuilder: (context, index) {
          final name = _names[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF40C463).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: const Color(0xFF40C463).withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name['transliteration']!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name['meaning']!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  name['arabic']!,
                  style: TextStyle(
                    color: const Color(0xFF40C463).withValues(alpha: 0.7),
                    fontSize: 22,
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
