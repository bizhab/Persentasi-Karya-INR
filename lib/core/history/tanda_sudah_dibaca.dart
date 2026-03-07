import 'package:shared_preferences/shared_preferences.dart';

class LocalHistoryService {
  static const String _storageKey = 'read_news_ids';

  Future<void> saveReadNews(String newsId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentIds = prefs.getStringList(_storageKey) ?? [];
    if (!currentIds.contains(newsId)) {
      currentIds.add(newsId);
      await prefs.setStringList(_storageKey, currentIds);
    }
  }

  Future<Set<String>> fetchAllReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_storageKey) ?? [];
    return ids.toSet();
  }
}