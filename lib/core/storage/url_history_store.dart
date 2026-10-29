import 'package:shared_preferences/shared_preferences.dart';

abstract class UrlHistoryStore {
  Future<List<String>> load();

  Future<void> saveSuccessful(String url);
}

class SharedPreferencesUrlHistoryStore extends UrlHistoryStore {
  static const _key = 'successful_api_urls';

  @override
  Future<List<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_key) ?? const [];
  }

  @override
  Future<void> saveSuccessful(String url) async {
    final preferences = await SharedPreferences.getInstance();
    final urls = preferences.getStringList(_key) ?? [];
    urls
      ..remove(url)
      ..insert(0, url);
    await preferences.setStringList(_key, urls);
  }
}
