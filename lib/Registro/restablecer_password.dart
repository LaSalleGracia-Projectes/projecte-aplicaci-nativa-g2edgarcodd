import 'dart:ui';
import 'package:flutter/material.dart';
import '/main.dart'; // Importar la pantalla principal
import '/main_view.dart'; // Importar la vista principal
import '/Registro/registro.dart'; // Importar la vista de registro
import '/Registro/restablecer_password.dart'; // Importar la vista de restablecer contraseña
import '/Registro/login.dart';  // Importa la vista de login


class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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
                    "Restablecer Contraseña",
                    style: TextStyle(
                      fontSize: 32, // Tamaño de fuente ajustado
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ingresa una nueva contraseña",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 25),
                  buildTextField(
                    controller: newPasswordController,
                    label: "Nueva Contraseña",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 12),
                  buildTextField(
                    controller: confirmPasswordController,
                    label: "Confirmar Contraseña",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  buildButton("Restablecer Contraseña", Color(0xFFFCB500), Colors.black, () {
                    verificarContrasena();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void verificarContrasena() {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showMessage("Por favor completa ambos campos", Colors.orange);
    } else if (newPassword != confirmPassword) {
      showMessage("Las contraseñas no coinciden", Colors.red);
    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$').hasMatch(newPassword)) {
      showMessage("La contraseña no cumple con los requisitos de seguridad", Colors.orange);
    } else {
      showMessage("Contraseña restablecida con éxito", Colors.green);
      // Navegar a la vista de login después de un restablecimiento exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(correo: '', password: '',)), // Cambia LoginScreen() por la ruta correcta
      );
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