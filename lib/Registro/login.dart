import 'package:flutter/material.dart';
import '/main.dart'; // Importar la pantalla principal

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
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(6, 13, 23, 1), // Fondo oscuro
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Iniciar Sesión",
                style: TextStyle(
                  fontSize: 28, // Tamaño de fuente más compacto
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              SizedBox(height: 20),
              buildButton("Iniciar Sesión", Colors.white, Colors.blue.shade900, () {
                verificarCredenciales();
              }),
              SizedBox(height: 10),
              buildButton("Salir", Colors.red, Colors.white, () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                );
              }),
            ],
          ),
        ),
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
