import 'dart:ui';
import 'package:flutter/material.dart';
import '/main.dart';
import '/Registro/login.dart';

class RegistroScreen extends StatelessWidget {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final formWidth = screenSize.width * 0.4;

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con desenfoque y opacidad corregida
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/fondo1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Desenfoque ligero
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Oscurece un poco el fondo
                ),
              ),
            ),
          ),
          // Contenido del formulario
          Center(
            child: Container(
              width: formWidth,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(Icons.person_add, size: 80, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
                      buildTextField(
                        controller: nombreController,
                        label: "Nombre completo",
                        icon: Icons.person,
                        isPassword: false,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: correoController,
                        label: "Correo electrónico",
                        icon: Icons.email,
                        isPassword: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: passwordController,
                        label: "Contraseña",
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: confirmPasswordController,
                        label: "Confirmar contraseña",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            String nombre = nombreController.text.trim();
                            String correo = correoController.text.trim();
                            String password = passwordController.text.trim();
                            String confirmPassword = confirmPasswordController.text.trim();

                            if (nombre.isEmpty || correo.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                              showMessage(context, "Por favor completa todos los campos", Colors.red);
                            } else if (!correo.contains("@") || !correo.contains(".")) {
                              showMessage(context, "Correo inválido", Colors.orange);
                            } else if (password.length < 6) {
                              showMessage(context, "La contraseña debe tener al menos 6 caracteres", Colors.orange);
                            } else if (password != confirmPassword) {
                              showMessage(context, "Las contraseñas no coinciden", Colors.red);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(correo: correo, password: password),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: Text(
                            "Continuar →",
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        child: Text(
                          "¿Ya tienes una cuenta? Inicia sesión aquí",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  void showMessage(BuildContext context, String text, Color color) {
    final snackBar = SnackBar(
      content: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(20),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
