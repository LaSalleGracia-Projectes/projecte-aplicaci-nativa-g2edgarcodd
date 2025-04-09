import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es';
  final Map<String, String> _languageNames = {
    'es': 'Español',
    'en': 'English',
    'ca': 'Català'
  };

  String get currentLanguage => _currentLanguage;
  String get currentLanguageName => _languageNames[_currentLanguage] ?? 'Español';
  List<String> get availableLanguages => _languageNames.keys.toList();
  List<String> get availableLanguageNames => _languageNames.values.toList();

  LanguageProvider() {
    _loadLanguage();
  }

  void changeLanguage(String languageCode) async {
    if (_languageNames.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
    }
  }

  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'es';
    notifyListeners();
  }

  String getLanguageCode(String languageName) {
    return _languageNames.entries
        .firstWhere((entry) => entry.value == languageName,
            orElse: () => MapEntry('es', 'Español'))
        .key;
  }
} 