import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool  _isDarkmode = false;

  ThemeData get currentTheme => _isDarkmode ? _darkTheme : _lightTheme;

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFFF6F6F7),
    scaffoldBackgroundColor: Color(0xFFF6F6F7),
    appBarTheme: AppBarTheme(backgroundColor: Color(0xFFF6F6F7), foregroundColor: Colors.amber),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFBC500))
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFF060D17))
    )
  );

  final ThemeData _darkTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF060D17),
      scaffoldBackgroundColor: Color(0xFF060D17),
      appBarTheme: AppBarTheme(backgroundColor: Color(0xFF060D17), foregroundColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFBC500))
      )
  );

  bool get isDarkMode => _isDarkmode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkmode = !_isDarkmode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkmode);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkmode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

}