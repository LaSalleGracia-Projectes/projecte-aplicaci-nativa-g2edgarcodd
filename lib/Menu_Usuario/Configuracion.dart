import 'package:flutter/material.dart';
import '../main.dart';

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> with SingleTickerProviderStateMixin {
  bool _modoBlancoyNegro = false;
  String _idiomaSeleccionado = 'Español';
  final List<String> _idiomas = ['Español', 'Inglés', 'Catalán'];
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
            image: AssetImage('images/streamhub.png'),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono animado
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        height: 170,
                        width: 170,
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
                              spreadRadius: 5 + (_animation.value * 5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.settings,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 50),

                  // Sección de Apariencia
                  _buildSection(
                    'Apariencia',
                    Icons.palette_outlined,
                    [
                      _buildSwitchOption(
                        'Modo Blanco y Negro',
                        'Cambia la apariencia a escala de grises',
                        _modoBlancoyNegro,
                        (value) {
                          setState(() {
                            _modoBlancoyNegro = value;
                          });
                          _mostrarMensaje(
                            'Modo ${value ? "activado" : "desactivado"}',
                            Colors.blue,
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // Sección de Idioma
                  _buildSection(
                    'Idioma',
                    Icons.language_outlined,
                    [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecciona tu idioma preferido',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: DropdownButton<String>(
                                value: _idiomaSeleccionado,
                                dropdownColor: Color(0xFF060D17),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
                                isExpanded: true,
                                underline: Container(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _idiomaSeleccionado = newValue;
                                    });
                                    _mostrarMensaje(
                                      'Idioma cambiado a $newValue',
                                      Colors.blue,
                                    );
                                  }
                                },
                                items: _idiomas.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // Sección de Cuenta
                  _buildSection(
                    'Cuenta',
                    Icons.account_circle_outlined,
                    [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: _buildButton(
                          'Cerrar Sesión',
                          Icons.exit_to_app,
                          Colors.red.shade600,
                          () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Color(0xFF060D17),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                      SizedBox(width: 10),
                                      Text('Cerrar Sesión',
                                          style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  content: Text(
                                    '¿Estás seguro de que quieres cerrar sesión?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancelar',
                                          style: TextStyle(color: Colors.white70)),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text('Cerrar Sesión',
                                          style: TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HomePage()),
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade800],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchOption(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              mensaje,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
        duration: Duration(seconds: 3),
        elevation: 4,
      ),
    );
  }
}
