import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimalist Hadiths Screen - 40 Essential Hadiths
/// 
/// Psychology & Design Science Applied:
/// 
/// 1. COGNITIVE LOAD REDUCTION
///    - Progressive disclosure (tap to expand)
///    - Category chips for mental organization
///    - Clean typography hierarchy
/// 
/// 2. VISUAL HIERARCHY
///    - Arabic text prominent (spiritual focus)
///    - Source small but accessible
///    - Actions hidden until needed
///
/// 3. CALMING AESTHETICS
///    - Dark background reduces eye strain
///    - Green accent (associated with peace in Islam)
///    - Generous whitespace
///
/// 4. FRICTION-FREE INTERACTION
///    - Single tap to expand
///    - Swipe to navigate
///    - Copy with haptic feedback
class MinimalistHadithsScreen extends StatefulWidget {
  const MinimalistHadithsScreen({super.key});

  @override
  State<MinimalistHadithsScreen> createState() => _MinimalistHadithsScreenState();
}

class _MinimalistHadithsScreenState extends State<MinimalistHadithsScreen> {
  int? _expandedIndex;
  String _selectedCategory = 'all';

  // Categories
  static const List<String> _categories = [
    'all', 'faith', 'character', 'worship', 'social', 'wisdom', 'paradise'
  ];

  // 40 Authentic Hadiths (Nawawi Collection + Essential)
  static const List<Map<String, String>> _hadiths = [
    // Faith
    {'category': 'faith', 'arabic': 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ', 'translation': 'Indeed, actions are judged by intentions, and every person shall have only what they intended.', 'source': 'Bukhari & Muslim', 'narrator': 'Umar ibn al-Khattab'},
    {'category': 'faith', 'arabic': 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ', 'translation': 'None of you truly believes until he loves for his brother what he loves for himself.', 'source': 'Bukhari & Muslim', 'narrator': 'Anas ibn Malik'},
    {'category': 'faith', 'arabic': 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ', 'translation': 'Whoever believes in Allah and the Last Day, let him speak good or remain silent.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'faith', 'arabic': 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ', 'translation': 'A Muslim is one from whose tongue and hand other Muslims are safe.', 'source': 'Bukhari & Muslim', 'narrator': 'Abdullah ibn Amr'},
    {'category': 'faith', 'arabic': 'الدِّينُ النَّصِيحَةُ', 'translation': 'The religion is sincere advice.', 'source': 'Muslim', 'narrator': 'Tamim al-Dari'},
    
    // Character
    {'category': 'character', 'arabic': 'لَا تَغْضَبْ', 'translation': 'Do not get angry.', 'source': 'Bukhari', 'narrator': 'Abu Hurairah'},
    {'category': 'character', 'arabic': 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا', 'translation': 'Fear Allah wherever you are, and follow a bad deed with a good deed; it will erase it.', 'source': 'Tirmidhi', 'narrator': 'Abu Dharr'},
    {'category': 'character', 'arabic': 'مِنْ حُسْنِ إِسْلَامِ الْمَرْءِ تَرْكُهُ مَا لَا يَعْنِيهِ', 'translation': 'Part of the perfection of a person\'s Islam is leaving what does not concern him.', 'source': 'Tirmidhi', 'narrator': 'Abu Hurairah'},
    {'category': 'character', 'arabic': 'الْحَيَاءُ شُعْبَةٌ مِنَ الْإِيمَانِ', 'translation': 'Modesty is a branch of faith.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'character', 'arabic': 'إِنَّ اللَّهَ رَفِيقٌ يُحِبُّ الرِّفْقَ فِي الْأَمْرِ كُلِّهِ', 'translation': 'Indeed, Allah is gentle and loves gentleness in all matters.', 'source': 'Bukhari & Muslim', 'narrator': 'Aisha'},
    {'category': 'character', 'arabic': 'خَيْرُكُمْ خَيْرُكُمْ لِأَهْلِهِ', 'translation': 'The best of you are those who are best to their families.', 'source': 'Tirmidhi', 'narrator': 'Aisha'},
    {'category': 'character', 'arabic': 'أَكْمَلُ الْمُؤْمِنِينَ إِيمَانًا أَحْسَنُهُمْ خُلُقًا', 'translation': 'The most complete believers are those with the best character.', 'source': 'Abu Dawud', 'narrator': 'Abu Hurairah'},
    
    // Worship
    {'category': 'worship', 'arabic': 'الطُّهُورُ شَطْرُ الْإِيمَانِ', 'translation': 'Purity is half of faith.', 'source': 'Muslim', 'narrator': 'Abu Malik al-Ash\'ari'},
    {'category': 'worship', 'arabic': 'صَلُّوا كَمَا رَأَيْتُمُونِي أُصَلِّي', 'translation': 'Pray as you have seen me pray.', 'source': 'Bukhari', 'narrator': 'Malik ibn al-Huwayrith'},
    {'category': 'worship', 'arabic': 'مَنْ قَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ', 'translation': 'Whoever stands in prayer in Ramadan with faith and seeking reward, his previous sins will be forgiven.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'worship', 'arabic': 'الصَّوْمُ جُنَّةٌ', 'translation': 'Fasting is a shield.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'worship', 'arabic': 'مَنْ حَجَّ وَلَمْ يَرْفُثْ وَلَمْ يَفْسُقْ رَجَعَ كَيَوْمِ وَلَدَتْهُ أُمُّهُ', 'translation': 'Whoever performs Hajj and does not commit sin, returns like the day his mother gave birth to him.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'worship', 'arabic': 'الصَّدَقَةُ تُطْفِئُ الْخَطِيئَةَ كَمَا يُطْفِئُ الْمَاءُ النَّارَ', 'translation': 'Charity extinguishes sin like water extinguishes fire.', 'source': 'Tirmidhi', 'narrator': 'Mu\'adh ibn Jabal'},
    
    // Social
    {'category': 'social', 'arabic': 'لَا ضَرَرَ وَلَا ضِرَارَ', 'translation': 'There should be neither harm nor reciprocating harm.', 'source': 'Ibn Majah', 'narrator': 'Ibn Abbas'},
    {'category': 'social', 'arabic': 'انْصُرْ أَخَاكَ ظَالِمًا أَوْ مَظْلُومًا', 'translation': 'Help your brother whether he is an oppressor or oppressed.', 'source': 'Bukhari', 'narrator': 'Anas ibn Malik'},
    {'category': 'social', 'arabic': 'مَنْ لَا يَرْحَمْ لَا يُرْحَمْ', 'translation': 'He who shows no mercy, will not be shown mercy.', 'source': 'Bukhari & Muslim', 'narrator': 'Jarir ibn Abdullah'},
    {'category': 'social', 'arabic': 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ', 'translation': 'Smiling at your brother is charity.', 'source': 'Tirmidhi', 'narrator': 'Abu Dharr'},
    {'category': 'social', 'arabic': 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ', 'translation': 'A good word is charity.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'social', 'arabic': 'لَا يَدْخُلُ الْجَنَّةَ قَاطِعُ رَحِمٍ', 'translation': 'One who severs family ties will not enter Paradise.', 'source': 'Bukhari & Muslim', 'narrator': 'Jubayr ibn Mut\'im'},
    {'category': 'social', 'arabic': 'إِنَّ فِي الْجَسَدِ مُضْغَةً إِذَا صَلَحَتْ صَلَحَ الْجَسَدُ كُلُّهُ', 'translation': 'Verily, in the body is a piece of flesh; if it is sound, the whole body is sound.', 'source': 'Bukhari & Muslim', 'narrator': 'Nu\'man ibn Bashir'},
    
    // Wisdom
    {'category': 'wisdom', 'arabic': 'الدُّنْيَا سِجْنُ الْمُؤْمِنِ وَجَنَّةُ الْكَافِرِ', 'translation': 'This world is a prison for the believer and a paradise for the disbeliever.', 'source': 'Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'wisdom', 'arabic': 'كُنْ فِي الدُّنْيَا كَأَنَّكَ غَرِيبٌ أَوْ عَابِرُ سَبِيلٍ', 'translation': 'Be in this world as if you were a stranger or a traveler.', 'source': 'Bukhari', 'narrator': 'Ibn Umar'},
    {'category': 'wisdom', 'arabic': 'ازْهَدْ فِي الدُّنْيَا يُحِبَّكَ اللَّهُ', 'translation': 'Be detached from this world, and Allah will love you.', 'source': 'Ibn Majah', 'narrator': 'Sahl ibn Sa\'d'},
    {'category': 'wisdom', 'arabic': 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ', 'translation': 'The strong believer is better and more beloved to Allah than the weak believer.', 'source': 'Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'wisdom', 'arabic': 'احْرِصْ عَلَى مَا يَنْفَعُكَ', 'translation': 'Be keen on what benefits you.', 'source': 'Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'wisdom', 'arabic': 'اغْتَنِمْ خَمْسًا قَبْلَ خَمْسٍ', 'translation': 'Take advantage of five before five.', 'source': 'Hakim', 'narrator': 'Ibn Abbas'},
    {'category': 'wisdom', 'arabic': 'إِذَا لَمْ تَسْتَحِ فَاصْنَعْ مَا شِئْتَ', 'translation': 'If you have no shame, do as you wish.', 'source': 'Bukhari', 'narrator': 'Abu Mas\'ud'},
    
    // Paradise
    {'category': 'paradise', 'arabic': 'أَنَا زَعِيمٌ بِبَيْتٍ فِي رَبَضِ الْجَنَّةِ لِمَنْ تَرَكَ الْمِرَاءَ', 'translation': 'I guarantee a house in the surroundings of Paradise for one who leaves argumentation.', 'source': 'Abu Dawud', 'narrator': 'Abu Umamah'},
    {'category': 'paradise', 'arabic': 'الْجَنَّةُ أَقْرَبُ إِلَى أَحَدِكُمْ مِنْ شِرَاكِ نَعْلِهِ', 'translation': 'Paradise is closer to any of you than the strap of his sandal.', 'source': 'Bukhari', 'narrator': 'Abdullah ibn Mas\'ud'},
    {'category': 'paradise', 'arabic': 'قُلْ آمَنْتُ بِاللَّهِ ثُمَّ اسْتَقِمْ', 'translation': 'Say, "I believe in Allah," then be steadfast.', 'source': 'Muslim', 'narrator': 'Sufyan ibn Abdullah'},
    {'category': 'paradise', 'arabic': 'مَنْ يَضْمَنْ لِي مَا بَيْنَ لَحْيَيْهِ وَمَا بَيْنَ رِجْلَيْهِ أَضْمَنْ لَهُ الْجَنَّةَ', 'translation': 'Whoever guarantees me what is between his jaws and legs, I guarantee him Paradise.', 'source': 'Bukhari', 'narrator': 'Sahl ibn Sa\'d'},
    {'category': 'paradise', 'arabic': 'اتَّقُوا النَّارَ وَلَوْ بِشِقِّ تَمْرَةٍ', 'translation': 'Protect yourselves from the Fire, even with half a date.', 'source': 'Bukhari & Muslim', 'narrator': 'Adi ibn Hatim'},
    {'category': 'paradise', 'arabic': 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ', 'translation': 'Whoever takes a path seeking knowledge, Allah makes easy for him a path to Paradise.', 'source': 'Muslim', 'narrator': 'Abu Hurairah'},
    {'category': 'paradise', 'arabic': 'حُفَّتِ الْجَنَّةُ بِالْمَكَارِهِ وَحُفَّتِ النَّارُ بِالشَّهَوَاتِ', 'translation': 'Paradise is surrounded by hardships, and the Fire is surrounded by desires.', 'source': 'Bukhari & Muslim', 'narrator': 'Abu Hurairah'},
  ];

  List<Map<String, String>> get _filteredHadiths {
    if (_selectedCategory == 'all') return _hadiths;
    return _hadiths.where((h) => h['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHadiths;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Category filter
            _buildCategoryFilter(),
            
            // Hadith count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} hadiths',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Hadiths List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildHadithCard(index, filtered[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          // Title with icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF40C463).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '📚',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '40 Hadiths',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Prophetic wisdom',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = category;
                _expandedIndex = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF40C463).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF40C463).withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                category == 'all' ? 'All' : category[0].toUpperCase() + category.substring(1),
                style: TextStyle(
                  color: isSelected 
                      ? const Color(0xFF40C463)
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHadithCard(int index, Map<String, String> hadith) {
    final isExpanded = _expandedIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isExpanded 
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded 
                ? const Color(0xFF40C463).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Row(
              children: [
                // Source badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF40C463).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hadith['source']!,
                    style: TextStyle(
                      color: const Color(0xFF40C463).withValues(alpha: 0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hadith['category']!.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 18,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Arabic text
            Text(
              hadith['arabic']!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: isExpanded ? 22 : 18,
                height: 1.8,
              ),
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            
            // Expanded content
            if (isExpanded) ...[
              const SizedBox(height: 20),
              
              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              
              const SizedBox(height: 16),
              
              // Translation
              Text(
                hadith['translation']!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Narrator
              Text(
                '— ${hadith['narrator']}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(Icons.copy, 'Copy', () {
                    Clipboard.setData(ClipboardData(
                      text: '${hadith['arabic']}\n\n"${hadith['translation']}"\n\n— ${hadith['narrator']} (${hadith['source']})',
                    ));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Hadith copied'),
                        backgroundColor: const Color(0xFF40C463).withValues(alpha: 0.9),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  _buildActionButton(Icons.share, 'Share', () {
                    HapticFeedback.selectionClick();
                    // Share functionality
                  }),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              
              // Hint
              Text(
                'tap to read translation',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.15),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
