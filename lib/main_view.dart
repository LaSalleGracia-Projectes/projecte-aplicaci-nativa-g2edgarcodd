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
        child: Column(
          children: [
            Expanded(
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
            // Footer
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              color: Color(0xFF060D17),
              child: Column(
                children: [
                  Divider(color: Color(0xFF333333), thickness: 1),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and tagline
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'STREAM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'HUB',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700), // Dorado
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tu destino para descubrir películas y series que te inspirarán, emocionarán y entretendrán.',
                              style: TextStyle(
                                color: Color(0xFFF6F6F7), 
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Navigation links
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Navegación',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildFooterLink(Icons.home, 'Inicio'),
                            _buildFooterLink(Icons.explore, 'Explorar'),
                            _buildFooterLink(Icons.article, 'Blog'),
                            _buildFooterLink(Icons.forum, 'Foro'),
                          ],
                        ),
                      ),
                      // Categories
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categorías',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildFooterLink(Icons.movie, 'Películas'),
                            _buildFooterLink(Icons.tv, 'Series'),
                            _buildFooterLink(Icons.video_library, 'Documentales'),
                            _buildFooterLink(Icons.new_releases, 'Novedades'),
                          ],
                        ),
                      ),
                      // Legal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Legal',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildFooterLink(Icons.description, 'Términos de servicio'),
                            _buildFooterLink(Icons.privacy_tip, 'Política de privacidad'),
                            _buildFooterLink(Icons.cookie, 'Cookies'),
                            _buildFooterLink(Icons.info, 'Información legal'),
                          ],
                        ),
                      ),
                      // Contact
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contacto',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildFooterLink(Icons.email, 'contacto@streamhub.com'),
                            _buildFooterLink(Icons.support_agent, 'Soporte'),
                            _buildFooterLink(Icons.campaign, 'Publicidad'),
                            _buildFooterLink(Icons.question_answer, 'FAQ'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Social media icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.facebook),
                      SizedBox(width: 15),
                      _buildSocialIcon(Icons.whatshot), // Twitter/X
                      SizedBox(width: 15),
                      _buildSocialIcon(Icons.camera_alt), // Instagram
                      SizedBox(width: 15),
                      _buildSocialIcon(Icons.play_arrow_rounded), // YouTube
                      SizedBox(width: 15),
                      _buildSocialIcon(Icons.discord), // Discord
                    ],
                  ),
                  SizedBox(height: 20),
                  // Payment methods
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentMethod('VISA'),
                      SizedBox(width: 10),
                      _buildPaymentMethod('MC'),
                      SizedBox(width: 10),
                      _buildPaymentMethod('AMEX'),
                      SizedBox(width: 10),
                      _buildPaymentMethod('PP'),
                      SizedBox(width: 10),
                      _buildPaymentMethod('GPay'),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Copyright
                  Text(
                    '© 2023 StreamHub',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                    ),
                  ),
                  // Back to top button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Color(0xFFFFD700),
                      onPressed: () {
                        // Scroll to top functionality would go here
                      },
                      child: Icon(Icons.arrow_upward, color: Color(0xFF060D17)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooterLink(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon, 
            size: 16, 
            color: Color(0xFFFFD700),
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Color(0xFFF6F6F7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: Color(0xFFFFD700),
        size: 20,
      ),
    );
  }
  
  Widget _buildPaymentMethod(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFFF6F6F7),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
