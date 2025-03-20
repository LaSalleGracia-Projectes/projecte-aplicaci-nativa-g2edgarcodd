import 'dart:ui';
import 'package:flutter/material.dart';
import '/main.dart'; // Importar la pantalla principal
import '/main_view.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  final String correo;
  final String password;

  LoginScreen({required this.correo, required this.password});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/fondo1.png', // Imagen de fondo
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Ajusta el desenfoque
            child: Container(
              color: Colors.black.withOpacity(0.3), // Ajusta la opacidad
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 32, // Tamaño de fuente ajustado
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "¡Bienvenido de nuevo a Streamhub!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 25),
                  buildTextField(
                    controller: correoController,
                    label: "Correo Electrónico",
                    icon: Icons.email,
                    isPassword: false,
                  ),
                  SizedBox(height: 12),
                  buildTextField(
                    controller: passwordController,
                    label: "Contraseña",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: 20),
                  buildButton("Iniciar Sesión", Colors.yellow, Colors.black, () {
                    verificarCredenciales();
                  }),
                  SizedBox(height: 20),
                  Text(
                    "O inicia sesión con",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.g_mobiledata, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.facebook, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "¿No tienes una cuenta? Regístrate aquí",
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void verificarCredenciales() {
    String correoIngresado = correoController.text.trim();
    String passwordIngresada = passwordController.text.trim();

    if (correoIngresado.isEmpty || passwordIngresada.isEmpty) {
      showMessage("Información incompleta", Colors.orange);
    } else if (correoIngresado == widget.correo && passwordIngresada == widget.password) {
      showMessage("Login exitoso", Colors.green);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Menu()),
            (route) => false,
      );
    } else {
      showMessage("Correo y/o contraseña incorrectos", Colors.red);
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
  }) {
    return SizedBox(
      width: 400, // Ancho reducido
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_passwordVisible : false,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordes más suaves
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: 200, // Ancho reducido
      height: 50, // Altura reducida
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes más redondeados
          ),
          elevation: 5,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  void showMessage(String text, Color color) {
    final snackBar = SnackBar(
      content: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
