import 'package:flutter/material.dart';
import '/main.dart';
import '/Registro/login.dart';

class RegistroScreen extends StatelessWidget {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Calculamos el ancho deseado (40% del ancho de la pantalla)
    final formWidth = screenSize.width * 0.4;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(6, 13, 23, 1),
        ),
        child: Center(
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
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Icon(Icons.person_add, size: 80, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Registro",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            controller: nombreController,
                            label: "Nombre",
                            icon: Icons.person,
                            isPassword: false,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: buildTextField(
                            controller: apellidoController,
                            label: "Apellido",
                            icon: Icons.person_outline,
                            isPassword: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    buildTextField(
                      controller: usuarioController,
                      label: "Nombre de Usuario",
                      icon: Icons.account_circle,
                      isPassword: false,
                    ),
                    SizedBox(height: 15),
                    buildTextField(
                      controller: correoController,
                      label: "Correo Electrónico",
                      icon: Icons.email,
                      isPassword: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    buildTextField(
                      controller: telefonoController,
                      label: "Teléfono",
                      icon: Icons.phone,
                      isPassword: false,
                      keyboardType: TextInputType.phone,
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
                      label: "Confirmar Contraseña",
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
                          String apellido = apellidoController.text.trim();
                          String usuario = usuarioController.text.trim();
                          String correo = correoController.text.trim();
                          String telefono = telefonoController.text.trim();
                          String password = passwordController.text.trim();
                          String confirmPassword = confirmPasswordController.text.trim();

                          if (nombre.isEmpty || apellido.isEmpty || usuario.isEmpty || correo.isEmpty || telefono.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                            showMessage(context, "Por favor completa todos los campos", Colors.red);
                          } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(nombre) || !RegExp(r'^[a-zA-Z]+$').hasMatch(apellido)) {
                            showMessage(context, "El nombre y apellido deben contener solo letras", Colors.orange);
                          } else if (!RegExp(r'^[a-zA-Z0-9_]{4,15}$').hasMatch(usuario)) {
                            showMessage(context, "El nombre de usuario debe tener entre 4-15 caracteres y solo letras, números o guion bajo", Colors.orange);
                          } else if (!correo.contains("@") || !correo.contains(".")) {
                            showMessage(context, "Correo inválido", Colors.orange);
                          } else if (!RegExp(r'^[0-9]{9,15}$').hasMatch(telefono)) {
                            showMessage(context, "Número de teléfono inválido (debe tener entre 9 y 15 dígitos)", Colors.orange);
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
                          "Registrar",
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: Text(
                          "Salir",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
