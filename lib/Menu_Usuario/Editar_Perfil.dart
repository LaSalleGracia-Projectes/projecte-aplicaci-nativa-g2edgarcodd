import 'package:flutter/material.dart';

class EditarPerfilScreen extends StatefulWidget {
  final String nombre;
  final String apellidos;
  final String usuario;
  final String correo;
  final String password;

  EditarPerfilScreen({
    required this.nombre,
    required this.apellidos,
    required this.usuario,
    required this.correo,
    required this.password,
  });

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController usuarioController;
  late TextEditingController correoController;
  late TextEditingController passwordController;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombre);
    apellidoController = TextEditingController(text: widget.apellidos);
    usuarioController = TextEditingController(text: widget.usuario);
    correoController = TextEditingController(text: widget.correo);
    passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    usuarioController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil', 
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
                  buildButton("Guardar Cambios", Colors.white, Colors.blue.shade900, () {
                    // Validar que todos los campos estén completos
                    List<String> camposVacios = [];
                    
                    if (nombreController.text.trim().isEmpty) {
                      camposVacios.add("Nombre");
                    }
                    if (apellidoController.text.trim().isEmpty) {
                      camposVacios.add("Apellidos");
                    }
                    if (usuarioController.text.trim().isEmpty) {
                      camposVacios.add("Nombre de Usuario");
                    }
                    if (correoController.text.trim().isEmpty) {
                      camposVacios.add("Correo Electrónico");
                    }
                    if (passwordController.text.trim().isEmpty) {
                      camposVacios.add("Contraseña");
                    }

                    if (camposVacios.isNotEmpty) {
                      // Si hay campos vacíos, mostrar mensaje de error
                      showMessage(
                        "Faltan campos por completar:\n${camposVacios.join(", ")}", 
                        Colors.orange
                      );
                    } else {
                      // Si todos los campos están completos, guardar y volver
                      showMessage("Cambios guardados exitosamente", Colors.green);
                      Navigator.pop(context);
                    }
                  }),
                  SizedBox(width: 20),
                  buildButton("Cancelar", Colors.red, Colors.white, () {
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !_passwordVisible,
      style: TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: "Contraseña",
        labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: Icon(Icons.lock, color: Colors.white70, size: 24),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
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
