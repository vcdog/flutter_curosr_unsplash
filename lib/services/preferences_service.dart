import 'package:shared_preferences.dart';

class PreferencesService {
  static const String _welcomeShownKey = 'welcome_shown';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  Future<bool> isWelcomeShown() async {
    return _prefs.getBool(_welcomeShownKey) ?? false;
  }

  Future<void> setWelcomeShown(bool value) async {
    await _prefs.setBool(_welcomeShownKey, value);
  }
}
