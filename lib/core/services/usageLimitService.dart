import 'package:shared_preferences/shared_preferences.dart';
import 'package:PDFly/core/config/apiConfig.dart';

enum AiFeature { summary, quiz }

class UsageLimitService {
  static const _dateKey = 'ai_last_date';
  static const _summaryKey = 'ai_summary_count';
  static const _quizKey = 'ai_quiz_count';

  String _featureKey(AiFeature f) =>
      f == AiFeature.summary ? _summaryKey : _quizKey;

  int _dailyLimit(AiFeature f) =>
      f == AiFeature.summary
          ? ApiConfig.dailySummaryLimit
          : ApiConfig.dailyQuizLimit;

  /// Gün değişmişse sayaçları sıfırlar
  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final today = _todayStr();
    if (prefs.getString(_dateKey) != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_summaryKey, 0);
      await prefs.setInt(_quizKey, 0);
    }
  }

  /// Kullanım hakkı var mı?
  Future<bool> canUse(AiFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final count = prefs.getInt(_featureKey(feature)) ?? 0;
    return count < _dailyLimit(feature);
  }

  /// Kullanımı kaydet
  Future<void> recordUsage(AiFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final key = _featureKey(feature);
    final count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);
  }

  /// Kalan kullanım sayısını döner
  Future<int> remaining(AiFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final count = prefs.getInt(_featureKey(feature)) ?? 0;
    return (_dailyLimit(feature) - count).clamp(0, _dailyLimit(feature));
  }

  String _todayStr() => DateTime.now().toIso8601String().substring(0, 10);
}
