import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // Locale (en, bn)
  String getLocale() {
    return _prefs.getString(StorageKeys.appLocale) ?? 'en';
  }

  Future<void> setLocale(String locale) async {
    await _prefs.setString(StorageKeys.appLocale, locale);
  }

  // Theme Mode (system, light, dark)
  String getThemeMode() {
    return _prefs.getString(StorageKeys.appThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageKeys.appThemeMode, mode);
  }

  // Selected Address UUID
  String? getSelectedAddressUuid() {
    return _prefs.getString(StorageKeys.selectedAddress);
  }

  Future<void> setSelectedAddressUuid(String uuid) async {
    await _prefs.setString(StorageKeys.selectedAddress, uuid);
  }

  // Search History
  List<String> getSearchHistory() {
    return _prefs.getStringList(StorageKeys.searchHistory) ?? [];
  }

  Future<void> addSearchQuery(String query) async {
    final list = getSearchHistory();
    list.remove(query);
    list.insert(0, query);
    if (list.length > 10) {
      list.removeLast();
    }
    await _prefs.setStringList(StorageKeys.searchHistory, list);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(StorageKeys.searchHistory);
  }
}
