import 'package:flutter/material.dart';
import 'Editar_Perfil.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PerfilScreen extends StatefulWidget {
  final String? token;
  
  PerfilScreen({this.token});

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      String token = widget.token ?? "11|Gt4FFtLcWsOY61ImE3Bbd6J9IMF2TFtHPDOjKLVtea3cbeca";
      
      print('Iniciando petición al servidor...');
      print('Token usado: $token');

      // Construir la URL con los parámetros query
      final queryParameters = {
        'token': token,
        'user_id': '13'
      };

      final response = await http.get(
        Uri.http('25.17.74.119:8000', '/api/getUser', queryParameters),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('URL de la petición: ${Uri.http('192.168.194.245:8000', '/api/getUser', queryParameters)}');
      print('Código de estado: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final userData = jsonResponse['data'];
          setState(() {
            nombreController.text = userData['name'] ?? '';
            apellidoController.text = userData['surname'] ?? '';
            usuarioController.text = userData['username'] ?? '';
            correoController.text = userData['email'] ?? '';
            _isLoading = false;
          });
          print('Datos de usuario cargados exitosamente');
        } else {
          throw Exception('La respuesta no tiene el formato esperado');
        }
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        setState(() => _isLoading = false);
        showMessage('Error al cargar los datos del usuario: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      print('Error en _loadUserData: $e');
      setState(() => _isLoading = false);
      showMessage('Error de conexión: ${e.toString()}', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
        appBar: AppBar(
          title: Text('Mi Perfil',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
          ),
          backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : Colors.blue.shade900,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil', 
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF060D17) : Colors.white,
          image: DecorationImage(
            image: AssetImage('images/streamhub.png'),
            opacity: isDark ? 0.05 : 0.1,
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return TextField(
      controller: passwordController,
      obscureText: !_passwordVisible,
      enabled: false,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: "Contraseña",
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white70 : Colors.black54, size: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
      ),
    );
  }

  Widget buildButton(String text, Color textColor, Color backgroundColor, VoidCallback onPressed) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      width: 160,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
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
