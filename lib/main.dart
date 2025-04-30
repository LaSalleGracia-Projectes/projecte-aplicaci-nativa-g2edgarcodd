import 'package:flutter/material.dart';
import 'Registro/registro.dart';
import 'Registro/login.dart';
import 'main_view.dart';
import 'package:flutter/services.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      locale: Locale(languageProvider.currentLanguage),
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
        Locale('ca'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: PaginaInicio(),
    );
  }
}

class PaginaInicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Color.fromRGBO(6, 13, 23, 1) : Colors.white, // Color adaptado al tema
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcome,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 30),
              buildButton(context, l10n.noRegistration, Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Menu(isGuest: true)),
                );
              }),
              buildButton(context, l10n.register, Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroScreen()),
                );
              }),
              buildButton(context, l10n.login, Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(correo: '', password: '')),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 260,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            shadowColor: Colors.black,
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          child: Text(text, style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}
