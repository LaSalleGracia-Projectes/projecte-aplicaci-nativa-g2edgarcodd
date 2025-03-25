import 'package:flutter/material.dart';
import 'Menu_Usuario/Perfil.dart';
import 'Menu_Usuario/Configuracion.dart';
import 'main.dart';
import 'dart:async';
import 'Header/Contacto.dart';
import 'Header/Blog.dart';
import 'Header/Explorar.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 2;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % _totalPages;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
                    onPressed: () {},
                    child: Text(
                      'Inicio',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Explorar()),
                      );
                    },
                    child: Text(
                      'Explorar',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Blog()),
                      );
                    },
                    child: Text(
                      'Blog',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Usuarios',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactoScreen()),
                      );
                    },
                    child: Text(
                      'Contacto',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
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
              child: Text(
                'Menú de usuario',
                style: TextStyle(color: Color(0xFFF6F6F7)),
              ),
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

      body: Container(
        color: Color(0xFF060D17),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.9,
            child: PageView(
              controller: _pageController,
              children: List.generate(
                _totalPages,
                    (index) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Image.asset(
                          'images/logoPrueba.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'images/logoPrueba.png',
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
                                  style: TextStyle(fontSize: 16, color: Color(0xFFF6F6F7)),
                                  maxLines: 8,
                                  overflow: TextOverflow.fade,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Leer más'),
                          ),
                        ],
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
}
