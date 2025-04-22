import 'dart:ui';
import 'package:flutter/material.dart';
import '/main.dart'; // Importar la pantalla principal
import '/main_view.dart'; // Add this import
import '/Registro/registro.dart'; // Agregar la importación de la vista de registro
import '/Registro/restablecer_password.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()), // Usa el nombre correcto
                      );
                    },
                    child: Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  SizedBox(height: 20),
                  buildButton("Iniciar Sesión", Color(0xFFFCB500), Colors.black, () {
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
                    onPressed: () {
                      // Navegar a la vista de registro
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistroScreen()), // Asegúrate de que RegistroScreen() sea la pantalla de registro
                      );
                    },
                    child: Text(
                      "¿No tienes una cuenta? Regístrate aquí",
                      style: TextStyle(color: Color(0xFFFCB500)),
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

  void verificarCredenciales() async {
    String correoIngresado = correoController.text.trim();
    String passwordIngresada = passwordController.text.trim();

    if (correoIngresado.isEmpty || passwordIngresada.isEmpty) {
      showMessage("Información incompleta", Colors.orange);
      return;
    }

    try {
      // Codificar los parámetros en la URL para el método GET
      final queryParameters = {
        'email': correoIngresado,
        'password': passwordIngresada,
      };

      final uri = Uri.http('192.168.194.245:8000', '/api/login', queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.body.isEmpty) {
        showMessage("Error: Respuesta vacía del servidor", Colors.red);
        return;
      }

      try {
        final responseData = json.decode(response.body);

        if (response.statusCode == 200 && responseData['success'] == true) {
          // Guardar el token de acceso
          final String accessToken = responseData['access_token'];
          final String tokenType = responseData['token_type'];
          
          showMessage(responseData['message'], Colors.green);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Menu()),
            (route) => false,
          );
        } else {
          // Login fallido
          showMessage(responseData['message'] ?? "Credenciales incorrectas", Colors.red);
        }
      } catch (e) {
        showMessage("Error al procesar la respuesta del servidor", Colors.red);
      }
    } catch (e) {
      // Error de conexión
      if (e.toString().contains('SocketException')) {
        showMessage("Error de conexión: No se pudo conectar al servidor", Colors.red);
      } else {
        showMessage("Error de conexión: ${e.toString()}", Colors.red);
      }
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
