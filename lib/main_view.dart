import 'package:flutter/material.dart';
import 'dart:async';

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

  void _navigateToPage(int page) {
    setState(() {
      _currentPage = page;
      _pageController.animateToPage(
        page,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }



  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      'Inicio',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Servicios',
                      style: TextStyle(color: Color(0xFFF6F6F7), fontSize: 16),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
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
              onTap: () {},
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

      body: Container(
        color: Color(0xFF060D17),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.9,
            child: PageView(
              controller: _pageController,
              children: [
                Row(
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
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: Text(
                                        'Lorem ipsum odor amet, consectetuer adipiscing elit. Dictum cras et tellus nulla semper quam velit lacus. Cursus non eget maximus dignissim sagittis facilisis. Platea donec senectus ut augue ornare et aenean quis. Accumsan ultrices non quisque rutrum netus nulla vel. Sem ornare venenatis interdum aliquet natoque semper elit felis. Eros pretium volutpat congue vitae vitae massa. Dictumst cubilia ad laoreet cursus quam placerat convallis class. Mauris gravida eget efficitur massa diam semper. Lorem ipsum odor amet, consectetuer adipiscing elit. Dictum cras et tellus nulla semper quam velit lacus. Cursus non eget maximus dignissim sagittis facilisis. Platea donec senectus ut augue ornare et aenean quis. Accumsan ultrices non quisque rutrum netus nulla vel. Sem ornare venenatis interdum aliquet natoque semper elit felis. Eros pretium volutpat congue vitae vitae massa. Dictumst cubilia ad laoreet cursus quam placerat convallis class. Mauris gravida eget efficitur massa diam semper.',
                                        style: TextStyle(fontSize: 16, color: Color(0xFFF6F6F7)),
                                        maxLines: 8,
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Color(0xFF060D17).withValues(alpha: 0.5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtraVista(),
                                ),
                              );*/
                            },
                            child: Text('Leer más'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
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
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: Text(
                                        'Lorem ipsum odor amet, consectetuer adipiscing elit. Dictum cras et tellus nulla semper quam velit lacus. Cursus non eget maximus dignissim sagittis facilisis. Platea donec senectus ut augue ornare et aenean quis. Accumsan ultrices non quisque rutrum netus nulla vel. Sem ornare venenatis interdum aliquet natoque semper elit felis. Eros pretium volutpat congue vitae vitae massa. Dictumst cubilia ad laoreet cursus quam placerat convallis class. Mauris gravida eget efficitur massa diam semper. Lorem ipsum odor amet, consectetuer adipiscing elit. Dictum cras et tellus nulla semper quam velit lacus. Cursus non eget maximus dignissim sagittis facilisis. Platea donec senectus ut augue ornare et aenean quis. Accumsan ultrices non quisque rutrum netus nulla vel. Sem ornare venenatis interdum aliquet natoque semper elit felis. Eros pretium volutpat congue vitae vitae massa. Dictumst cubilia ad laoreet cursus quam placerat convallis class. Mauris gravida eget efficitur massa diam semper.',
                                        style: TextStyle(fontSize: 16, color: Color(0xFFF6F6F7)),
                                        maxLines: 8,
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Color(0xFF060D17).withValues(alpha: 0.5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtraVista(),
                                ),
                              );*/
                            },
                            child: Text('Leer más'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Puedes agregar más páginas aquí
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
