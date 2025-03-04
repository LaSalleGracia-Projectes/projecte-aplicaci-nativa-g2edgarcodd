import 'package:flutter/material.dart';
import 'Editar_Perfil.dart';

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
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Color(0xFF060D17),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          color: Color(0xFF060D17),
          image: DecorationImage(
            image: AssetImage('images/logoPrueba.png'),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
          child: Column(
            children: [
              SizedBox(height: 30),
              // Sección de foto de perfil
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 85,
                      backgroundColor: Colors.blue.shade900,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        backgroundImage: AssetImage('images/logoPrueba.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white, size: 25),
                          onPressed: () {
                            // Implementar la funcionalidad de cambiar foto
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Sección de información personal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna izquierda
                  Expanded(
                    child: Column(
                      children: [
                        buildTextField(
                          controller: nombreController,
                          label: "Nombre",
                          icon: Icons.person,
                        ),
                        SizedBox(height: 20),
                        buildTextField(
                          controller: apellidoController,
                          label: "Apellidos",
                          icon: Icons.person_outline,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 40),
                  // Columna derecha
                  Expanded(
                    child: Column(
                      children: [
                        buildTextField(
                          controller: usuarioController,
                          label: "Nombre de Usuario",
                          icon: Icons.account_circle,
                        ),
                        SizedBox(height: 20),
                        buildTextField(
                          controller: correoController,
                          label: "Correo Electrónico",
                          icon: Icons.email,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Contraseña centrada
              Container(
                width: screenSize.width * 0.4,
                child: buildPasswordField(),
              ),
              SizedBox(height: 40),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton("Editar Datos", Colors.white, Colors.blue.shade900, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarPerfilScreen(
                          nombre: nombreController.text,
                          apellidos: apellidoController.text,
                          usuario: usuarioController.text,
                          correo: correoController.text,
                          password: passwordController.text,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 20),
                  buildButton("Volver", Colors.red, Colors.white, () {
                    Navigator.pop(context);
                  }),
                ],
              ),
              SizedBox(height: 30),
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
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white, fontSize: 16),
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(icon, color: Colors.white70, size: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white24),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white24),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: true,
      enabled: false,
      style: TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: "Contraseña",
        labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: Icon(Icons.lock, color: Colors.white70, size: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white24),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white24),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
    );
  }

  Widget buildButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(text),
      ),
    );
  }

  void showMessage(String text, Color color) {
    final snackBar = SnackBar(
      content: Text(text, 
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(20),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
