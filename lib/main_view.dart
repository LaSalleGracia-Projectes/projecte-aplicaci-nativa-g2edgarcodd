import 'package:flutter/material.dart';
import 'Menu_Usuario/Perfil.dart';
import 'Menu_Usuario/Configuracion.dart';
import 'main.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool _showContactForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('images/streamhub.png', height: 40),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showContactForm = false;
                      });
                    },
                    child: Text('Inicio', 
                      style: TextStyle(
                        color: Color(0xFFF6F6F7), 
                        fontSize: 16,
                      )
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showContactForm = false;
                      });
                    },
                    child: Text('Servicios', 
                      style: TextStyle(
                        color: Color(0xFFF6F6F7), 
                        fontSize: 16,
                      )
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showContactForm = true;
                      });
                    },
                    child: Text('Contacto', 
                      style: TextStyle(
                        color: Color(0xFFF6F6F7), 
                        fontSize: 16,
                        decoration: _showContactForm ? TextDecoration.underline : TextDecoration.none,
                      )
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      style: TextStyle(color: Color(0xFFF6F6F7)),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Color(0xFFF6F6F7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('images/logoPrueba.png'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF060D17),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF060D17)),
              child: Text('Menú de usuario', style: TextStyle(color: Color(0xFFF6F6F7))),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfiguracionScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _showContactForm 
        ? Container(
            decoration: BoxDecoration(
              color: Color(0xFF060D17),
              image: DecorationImage(
                image: AssetImage('images/streamhub.png'),
                opacity: 0.05,
                fit: BoxFit.cover,
              ),
            ),
            child: ContactForm(),
          )
        : Container(
            color: Colors.white,
            child: Center(
              child: Text(
                'Contenido principal',
                style: TextStyle(
                  color: Color(0xFF060D17),
                  fontSize: 18,
                ),
              ),
            ),
          ),
    );
  }
}

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  int caracteresRestantes = 2000;

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final formWidth = screenSize.width * 0.4;

    return Center(
      child: Container(
        width: formWidth,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(Icons.contact_support, size: 80, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Contáctanos",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "¿Tienes alguna pregunta o sugerencia? ¡Nos encantaría escucharte!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: nombreController,
                          label: "Nombre",
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                              return 'Solo se permiten letras';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: buildTextField(
                          controller: apellidoController,
                          label: "Apellido",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu apellido';
                            }
                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                              return 'Solo se permiten letras';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                    controller: correoController,
                    label: "Correo Electrónico",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
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
                    child: TextFormField(
                      controller: descripcionController,
                      maxLength: 2000,
                      maxLines: 6,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        labelStyle: TextStyle(color: Colors.white70),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        prefixIcon: Icon(Icons.description, color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        counterStyle: TextStyle(color: Colors.white70),
                      ),
                      onChanged: (text) {
                        setState(() {
                          caracteresRestantes = 2000 - text.length;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        if (value.length < 10) {
                          return 'La descripción debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showMessage(
                            context,
                            "¡Gracias por contactarnos! Te responderemos pronto.",
                            Colors.green,
                          );
                          nombreController.clear();
                          apellidoController.clear();
                          correoController.clear();
                          descripcionController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Enviar Mensaje",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
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
        validator: validator,
      ),
    );
  }

  void showMessage(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 4),
        elevation: 4,
      ),
    );
  }
}