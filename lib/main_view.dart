import 'package:flutter/material.dart';
import 'Menu_Usuario/Perfil.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('images/logoPrueba.png', height: 40),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('Inicio', style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Servicios', style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Contacto', style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16)),
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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar sesión'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Center(child: Text('Contenido principal')),
    );
  }
}