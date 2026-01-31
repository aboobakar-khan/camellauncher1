import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Premium status provider
/// Manages pro version status and features
class PremiumNotifier extends StateNotifier<bool> {
  static const String _boxName = 'premium';
  static const String _isPremiumKey = 'isPremium';

  PremiumNotifier() : super(false) {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final box = await Hive.openBox(_boxName);
    state = box.get(_isPremiumKey, defaultValue: false);
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_isPremiumKey, isPremium);
    state = isPremium;
  }

  Future<void> activatePremium() async {
    await setPremiumStatus(true);
  }

  Future<void> deactivatePremium() async {
    await setPremiumStatus(false);
  }

  Future<void> clearPremiumData() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_isPremiumKey);
    state = false;
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});
