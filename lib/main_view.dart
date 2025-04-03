import 'package:flutter/material.dart';
import 'Menu_Usuario/Perfil.dart';
import 'Menu_Usuario/Configuracion.dart';
import 'main.dart';
import 'dart:async';
import 'Header/Contacto.dart';
import 'Header/Blog.dart';
import 'Header/Explorar.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
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
                      style: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black, fontSize: 16),
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
                      style: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black, fontSize: 16),
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
                      style: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black, fontSize: 16),
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
                      style: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black, fontSize: 16),
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
                      style: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black),
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
        backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
      ),

      endDrawer: Drawer(
        child: Container(
          color: isDark ? Color(0xFF060D17) : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: isDark ? Color(0xFF060D17) : Colors.blue.shade100),
                child: Text(
                  'Menú de usuario',
                  style: TextStyle(color: isDark ? Color(0xFFF6F6F7) : Colors.black),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: isDark ? Colors.white : Colors.black87),
                title: Text('Perfil', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PerfilScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: isDark ? Colors.white : Colors.black87),
                title: Text('Configuración', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfiguracionScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: isDark ? Colors.white : Colors.black87),
                title: Text('Cerrar sesión', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
      ),

      body: Container(
        color: isDark ? Color(0xFF060D17) : Colors.white,
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
                                        style: TextStyle(fontSize: 16, color: isDark ? Color(0xFFF6F6F7) : Colors.black),
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
              color: isDark ? Color(0xFF060D17) : Colors.grey.shade100,
              child: Column(
                children: [
                  Divider(color: isDark ? Color(0xFF333333) : Colors.grey.shade300, thickness: 1),
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
                                    color: isDark ? Colors.white : Colors.black,
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
                                color: isDark ? Color(0xFFF6F6F7) : Colors.black87, 
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
                            _buildFooterLink(
                              Icons.home, 
                              'Inicio',
                              isDark: isDark,
                              onPressed: () {
                                // Recargar la vista actual (main_view)
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Menu()),
                                );
                              },
                            ),
                            _buildFooterLink(
                              Icons.explore, 
                              'Explorar',
                              isDark: isDark,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Explorar()),
                                );
                              },
                            ),
                            _buildFooterLink(
                              Icons.article, 
                              'Blog',
                              isDark: isDark,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Blog()),
                                );
                              },
                            ),
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
                            _buildFooterLink(
                              Icons.movie, 
                              'Películas',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de películas
                              },
                            ),
                            _buildFooterLink(
                              Icons.tv, 
                              'Series',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de series
                              },
                            ),
                            _buildFooterLink(
                              Icons.video_library, 
                              'Documentales',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de documentales  
                              },
                            ),
                            _buildFooterLink(
                              Icons.new_releases, 
                              'Novedades',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de novedades
                              },
                            ),
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
                            _buildFooterLink(
                              Icons.description, 
                              'Términos de servicio',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de términos
                              },
                            ),
                            _buildFooterLink(
                              Icons.privacy_tip, 
                              'Política de privacidad',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de privacidad
                              },
                            ),
                            _buildFooterLink(
                              Icons.cookie, 
                              'Cookies',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de cookies
                              },
                            ),
                            _buildFooterLink(
                              Icons.info, 
                              'Información legal',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de información legal
                              },
                            ),
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
                            _buildFooterLink(
                              Icons.email, 
                              'contacto@streamhub.com',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la funcionalidad de enviar email
                              },
                            ),
                            _buildFooterLink(
                              Icons.support_agent, 
                              'Soporte',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de soporte
                              },
                            ),
                            _buildFooterLink(
                              Icons.campaign, 
                              'Publicidad',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de publicidad
                              },
                            ),
                            _buildFooterLink(
                              Icons.question_answer, 
                              'FAQ',
                              isDark: isDark,
                              onPressed: () {
                                // Aquí iría la navegación a la vista de FAQ
                              },
                            ),
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
                      _buildSocialIcon(
                        Icons.facebook,
                        isDark: isDark,
                        onPressed: () {
                          // Aquí iría la acción para Facebook
                        },
                      ),
                      SizedBox(width: 15),
                      _buildSocialIcon(
                        Icons.whatshot,
                        isDark: isDark,
                        onPressed: () {
                          // Aquí iría la acción para Twitter/X
                        },
                      ),
                      SizedBox(width: 15),
                      _buildSocialIcon(
                        Icons.camera_alt,
                        isDark: isDark,
                        onPressed: () {
                          // Aquí iría la acción para Instagram
                        },
                      ),
                      SizedBox(width: 15),
                      _buildSocialIcon(
                        Icons.play_arrow_rounded,
                        isDark: isDark,
                        onPressed: () {
                          // Aquí iría la acción para YouTube
                        },
                      ),
                      SizedBox(width: 15),
                      _buildSocialIcon(
                        Icons.discord,
                        isDark: isDark,
                        onPressed: () {
                          // Aquí iría la acción para Discord
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Payment methods
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentMethod('VISA', isDark: isDark),
                      SizedBox(width: 10),
                      _buildPaymentMethod('MC', isDark: isDark),
                      SizedBox(width: 10),
                      _buildPaymentMethod('AMEX', isDark: isDark),
                      SizedBox(width: 10),
                      _buildPaymentMethod('PP', isDark: isDark),
                      SizedBox(width: 10),
                      _buildPaymentMethod('GPay', isDark: isDark),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Copyright
                  Text(
                    '© 2023 StreamHub',
                    style: TextStyle(
                      color: isDark ? Color(0xFF999999) : Colors.grey.shade600,
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
                      child: Icon(Icons.arrow_upward, color: isDark ? Color(0xFF060D17) : Colors.black),
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
  
  Widget _buildFooterLink(IconData icon, String text, {bool isDark = false, VoidCallback? onPressed}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
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
                color: isDark ? Color(0xFFF6F6F7) : Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSocialIcon(IconData icon, {bool isDark = false, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1A1A1A) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: Color(0xFFFFD700),
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethod(String text, {bool isDark = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1A1A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Color(0xFFF6F6F7) : Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
