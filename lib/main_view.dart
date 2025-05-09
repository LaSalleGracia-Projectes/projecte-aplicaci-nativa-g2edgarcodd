import 'package:flutter/material.dart';
import 'Menu_Usuario/Perfil.dart';
import 'Menu_Usuario/Configuracion.dart';
import 'main.dart';
import 'dart:async';
import 'Header/Contacto.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
              child: Image.asset('images/streamhub.png', height: 50),
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
                      style: TextStyle(/*color: Color(0xFFF6F6F7),*/ fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Servicios',
                      style: TextStyle(/*color: Color(0xFFF6F6F7),*/ fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Foro',
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
                      style: TextStyle(/*color: Color(0xFFF6F6F7),*/ fontSize: 16),
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
                      /*style: TextStyle(color: Color(0xFFF6F6F7)),*/
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        /*hintStyle: TextStyle(color: Color(0xFFF6F6F7)),*/
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
                /*style: TextStyle(color: Color(0xFFF6F6F7)),*/
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
      body: SingleChildScrollView(
        child: Container(
          /*color: Color(0xFF060D17),*/
          child: Center(
            child: _items.isEmpty
                ? CircularProgressIndicator()
                : CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
              ),
              items: _items.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    double posterHeight = MediaQuery.of(context).size.height * 0.7;
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        /*color: Color(0xFF060D17),*/
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Parte izquierda: título encima del póster
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Título de la película
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item['titulo'] ?? '',
                                    style: TextStyle(
                                      /*color: Color(0xFFF6F6F7),*/
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Imagen del póster
                                Container(
                                  height: posterHeight,
                                  child: item['portada']!.isNotEmpty
                                      ? Image.network(
                                    item['portada']!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.error, color: Color(0xFFF6F6F7)),
                                  )
                                      : Icon(Icons.image, size: 50, color: Color(0xFFF6F6F7)),
                                ),
                              ],
                            ),
                          ),
                          // Parte derecha: imagen de perfil y texto debajo
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/100'), // Imagen de stock
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Lorem Ipsum",
                                  style: TextStyle(/*color: Color(0xFFF6F6F7),*/ fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
