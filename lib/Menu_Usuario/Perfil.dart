import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF060D17),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF060D17),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    backgroundImage: AssetImage('images/logoPrueba.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          // Implementar la funcionalidad de cambiar foto
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              buildTextField(
                controller: nombreController,
                label: "Nombre",
                icon: Icons.person,
              ),
              SizedBox(height: 15),
              buildTextField(
                controller: apellidoController,
                label: "Apellidos",
                icon: Icons.person_outline,
              ),
              SizedBox(height: 15),
              buildTextField(
                controller: usuarioController,
                label: "Nombre de Usuario",
                icon: Icons.account_circle,
              ),
              SizedBox(height: 15),
              buildTextField(
                controller: correoController,
                label: "Correo Electrónico",
                icon: Icons.email,
              ),
              SizedBox(height: 15),
              buildPasswordField(),
              SizedBox(height: 30),
              buildButton("Guardar Cambios", Colors.white, Colors.blue.shade900, () {
                // Implementar la funcionalidad de guardar cambios
                showMessage("Cambios guardados exitosamente", Colors.green);
              }),
              SizedBox(height: 15),
              buildButton("Cancelar", Colors.red, Colors.white, () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      width: 400,
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade900),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      width: 400,
      child: TextField(
        controller: passwordController,
        obscureText: !_passwordVisible,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Contraseña",
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(Icons.lock, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade900),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
