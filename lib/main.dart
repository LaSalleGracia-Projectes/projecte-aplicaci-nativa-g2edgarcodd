import 'package:flutter/material.dart';
import 'Registro/registro.dart';
import 'Registro/login.dart';
import 'main_view.dart';
import 'package:flutter/services.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema oscuro
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(6, 13, 23, 1), // Color sólido de fondo
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¡Bienvenido!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              buildButton(context, "Sin Registro", Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Menu()),
                );
              }),
              buildButton(context, "Registrarse", Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroScreen()),
                );
              }),
              buildButton(context, "Login", Colors.orange, () {
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
          child: Text(text, style: TextStyle(color: Colors.black)), // Texto en negro
        ),
      ),
    );
  }
}
