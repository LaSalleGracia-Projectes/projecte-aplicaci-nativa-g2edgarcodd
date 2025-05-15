import 'dart:ui';
import 'package:flutter/material.dart';
import '/main.dart';
import '/Registro/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistroScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> registrarUsuario(BuildContext context) async {
    String username = usernameController.text.trim();
    String name = nameController.text.trim();
    String surname = surnameController.text.trim();
    String dateOfBirth = dateController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validaciones básicas
    if (username.isEmpty || name.isEmpty || surname.isEmpty || dateOfBirth.isEmpty || 
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage(context, "Por favor completa todos los campos", Colors.red);
      return;
    }

    // Validación mejorada del correo electrónico
    if (!email.contains("@") || !email.contains(".") || email.indexOf("@") > email.lastIndexOf(".")) {
      showMessage(context, "Formato de correo electrónico no válido", Colors.orange);
      return;
    }

    // Validación del formato de fecha (YYYY-MM-DD)
    if (!dateOfBirth.contains("-") || dateOfBirth.length != 10) {
      showMessage(context, "Formato de fecha incorrecto. Usa YYYY-MM-DD", Colors.orange);
      return;
    }

    if (password.length < 6) {
      showMessage(context, "La contraseña debe tener al menos 6 caracteres", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      showMessage(context, "Las contraseñas no coinciden", Colors.red);
      return;
    }

    try {
      print("Enviando solicitud de registro con datos: ${json.encode({
        'username': username,
        'name': name,
        'surname': surname,
        'date_of_birth': dateOfBirth,
        'email': email,
        'password': "********", // Ocultamos la contraseña por seguridad
        'password_confirmation': "********",
      })}");
      
      final response = await http.post(
        Uri.parse('http://25.17.74.119:8000/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'name': name,
          'surname': surname,
          'date_of_birth': dateOfBirth,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      print("Respuesta del servidor (Status: ${response.statusCode}): ${response.body}");
      
      final responseData = json.decode(response.body);

      // Verificación más robusta de la respuesta del servidor
      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['success'] == true) {
        showMessage(context, responseData['message'] ?? "Registro exitoso", Colors.green);
        
        // Esperar un momento para que se muestre el mensaje de éxito y luego redirigir
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(correo: email, password: password),
            ),
          );
        });
      } else {
        // Handle specific error messages from the API
        if (responseData.containsKey('errors')) {
          String errorMessage = "";
          
          // Check for email errors
          if (responseData['errors'].containsKey('email')) {
            errorMessage = responseData['errors']['email'][0];
            // If email is already taken, show a dialog with option to go to login
            if (errorMessage.contains("already been taken")) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Email ya registrado"),
                    content: Text("Este correo electrónico ya está registrado. ¿Quieres iniciar sesión en lugar de registrarte?"),
                    actions: [
                      TextButton(
                        child: Text("Cancelar"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Ir a iniciar sesión"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(correo: email, password: ''),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
              return; // Don't show the error message as SnackBar since we're showing a dialog
            }
          } 
          // Check for other specific errors as needed
          else if (responseData['errors'].containsKey('username')) {
            errorMessage = responseData['errors']['username'][0];
          }
          else if (responseData['errors'].containsKey('password')) {
            errorMessage = responseData['errors']['password'][0];
          }
          else {
            // Si hay errores pero no están en los campos que verificamos específicamente
            // intentamos extraer el primer error que encontremos
            Map<String, dynamic> errors = responseData['errors'];
            if (errors.isNotEmpty) {
              String firstErrorKey = errors.keys.first;
              if (errors[firstErrorKey] is List && errors[firstErrorKey].isNotEmpty) {
                errorMessage = errors[firstErrorKey][0];
              } else {
                errorMessage = "Error en el campo: $firstErrorKey";
              }
            } else {
              errorMessage = responseData['message'] ?? "Error en el registro";
            }
          }
          
          showMessage(context, errorMessage, Colors.red);
        } else {
          // Si no hay una estructura de errores específica, mostramos el mensaje general
          showMessage(context, responseData['message'] ?? "Error en el registro", Colors.red);
          
          // Depuración adicional
          print("Respuesta de error sin estructura 'errors': $responseData");
        }
      }
    } catch (e) {
      print("Excepción durante el registro: ${e.toString()}");
      
      // Manejar diferentes tipos de errores
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        showMessage(context, "No se pudo conectar al servidor. Verifica tu conexión a internet.", Colors.red);
      } else if (e.toString().contains('TimeoutException')) {
        showMessage(context, "La conexión al servidor ha tardado demasiado. Inténtalo de nuevo.", Colors.red);
      } else if (e.toString().contains('FormatException')) {
        showMessage(context, "Error en el formato de la respuesta del servidor.", Colors.red);
      } else {
        showMessage(context, "Error de conexión: ${e.toString()}", Colors.red);
      }
    }
  }

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
          // Botón de volver en la esquina superior izquierda
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton.icon(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              label: Text("Volver", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PaginaInicio()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCB500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
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
                        controller: usernameController,
                        label: "Nombre de usuario",
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: nameController,
                        label: "Nombre",
                        icon: Icons.person,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: surnameController,
                        label: "Apellidos",
                        icon: Icons.person,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: dateController,
                        label: "Fecha de nacimiento (YYYY-MM-DD)",
                        icon: Icons.calendar_today,
                      ),
                      SizedBox(height: 15),
                      buildTextField(
                        controller: emailController,
                        label: "Correo electrónico",
                        icon: Icons.email,
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
                          onPressed: () => registrarUsuario(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFCB500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            "Registrarse →",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(correo: '', password: ''),
                            ),
                          );
                        },
                        child: Text(
                          "¿Ya tienes una cuenta? Inicia sesión aquí",
                          style: TextStyle(color: Color(0xFFFCB500)),
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
