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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:streamhub/Secciones/peliculas.dart';
import 'package:streamhub/Secciones/series.dart';

// Clase para almacenar datos de películas/series de TMDB
class MediaItem {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final String mediaType;
  final List<String> genres;

  MediaItem({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.mediaType,
    required this.genres,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, String type) {
    // El campo de título varía entre películas y series
    String title = type == 'movie' 
        ? json['title'] ?? 'Sin título'
        : json['name'] ?? 'Sin título';
        
    // Determinar géneros
    List<String> genres = [];
    if (json['genre_ids'] != null) {
      // Aquí faltaría mapear los IDs de géneros a nombres,
      // pero simplificaremos para este ejemplo
    }
    
    return MediaItem(
      id: json['id'] ?? 0,
      title: title,
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      overview: json['overview'] ?? 'Sin descripción',
      releaseDate: type == 'movie' 
          ? (json['release_date'] ?? 'Sin fecha')
          : (json['first_air_date'] ?? 'Sin fecha'),
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      mediaType: type,
      genres: genres,
    );
  }
}

// Servicio para manejar llamadas a la API de TMDB
class TMDBService {
  static const String apiKey = "fa4912f208d8c9000b8d8d009c28e2b5";
  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";
  
  static const String token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU";

  // Obtener imagen completa
  static String getImageUrl(String path) {
    if (path.isEmpty) {
      return 'https://via.placeholder.com/150x225?text=No+Image';
    }
    return "$imageBaseUrl$path";
  }

  // Obtener películas en tendencia
  static Future<List<MediaItem>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => MediaItem.fromJson(json, 'movie')).toList();
    } else {
      throw Exception('Failed to load trending movies: ${response.statusCode}');
    }
  }

  // Obtener series en tendencia
  static Future<List<MediaItem>> getTrendingSeries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/tv/week?api_key=$apiKey'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => MediaItem.fromJson(json, 'tv')).toList();
    } else {
      throw Exception('Failed to load trending series: ${response.statusCode}');
    }
  }

  // Obtener próximos estrenos
  static Future<List<MediaItem>> getUpcomingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey&language=es-ES'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => MediaItem.fromJson(json, 'movie')).toList();
    } else {
      throw Exception('Failed to load upcoming movies: ${response.statusCode}');
    }
  }

  // Obtener contenido popular
  static Future<List<MediaItem>> getPopularContent(String mediaType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$mediaType/popular?api_key=$apiKey&language=es-ES'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => MediaItem.fromJson(json, mediaType)).toList();
    } else {
      throw Exception('Failed to load popular $mediaType: ${response.statusCode}');
    }
  }
}

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
  
  // Listas para almacenar datos de la API
  List<MediaItem> _continueWatchingItems = [];
  List<MediaItem> _newReleaseItems = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todo';

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _loadData();
  }
  
  // Cargar datos de la API
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Para "Continuar viendo" usaremos películas populares como ejemplo
      final popular = await TMDBService.getPopularContent('movie');
      // Para "Nuevos lanzamientos" usaremos próximos estrenos
      final upcoming = await TMDBService.getUpcomingMovies();
      
      setState(() {
        // Limitamos a algunos elementos para no sobrecargar la interfaz
        _continueWatchingItems = popular.take(6).toList();
        _newReleaseItems = upcoming.take(8).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
  
  // Filtrar contenido por tipo
  void _filterContent(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      // Implementamos la lógica real de filtrado
      _isLoading = true;
    });
    
    // Realizar la carga de datos según el filtro seleccionado
    Future.microtask(() async {
      try {
        List<MediaItem> filteredItems = [];
        
        switch (filter) {
          case 'Películas':
            filteredItems = await TMDBService.getPopularContent('movie');
            break;
          case 'Series':
            filteredItems = await TMDBService.getPopularContent('tv');
            break;
          case 'Todo':
          default:
            // Para "Todo", combinamos películas y series
            final movies = await TMDBService.getPopularContent('movie');
            final series = await TMDBService.getPopularContent('tv');
            filteredItems = [...movies, ...series];
            // Ordenamos por popularidad (usando voteAverage como aproximación)
            filteredItems.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
            break;
        }
        
        if (mounted) {
          setState(() {
            _newReleaseItems = filteredItems.take(8).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error filtrando contenido: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Carrusel
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
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
              
              // Sección "Continuar viendo"
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                width: double.infinity,
                color: isDark ? Color(0xFF060D17) : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Continuar viendo",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              height: 3,
                              width: 40,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Ver todo",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          height: 190,
                          child: _continueWatchingItems.isEmpty
                              ? Center(
                                  child: Text(
                                    "No hay contenido disponible",
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _continueWatchingItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _continueWatchingItems[index];
                                    // Generar tiempo restante aleatorio para ejemplo
                                    final minutes = (index + 1) * 5;
                                    return _buildContinueWatchingItemFromAPI(
                                      item,
                                      "$minutes min restantes",
                                    );
                                  },
                                ),
                        ),
                  ],
                ),
              ),
              
              // Sección "Nuevos lanzamientos"
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                width: double.infinity,
                color: isDark ? Color(0xFF060D17) : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Nuevos lanzamientos",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          height: 3,
                          width: 40,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _filterContent('Todo'),
                          child: _buildFilterButton('Todo', _selectedFilter == 'Todo'),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _filterContent('Películas'),
                          child: _buildFilterButton('Películas', _selectedFilter == 'Películas'),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _filterContent('Series'),
                          child: _buildFilterButton('Series', _selectedFilter == 'Series'),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          height: 240,
                          child: _newReleaseItems.isEmpty
                              ? Center(
                                  child: Text(
                                    "No hay estrenos disponibles",
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _newReleaseItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _newReleaseItems[index];
                                    // Determinar el tipo de badge para mostrar
                                    String badge = "NUEVO";
                                    if (index % 3 == 0) {
                                      badge = "PELÍCULA";
                                    } else if (index % 3 == 1) {
                                      badge = "SERIE";
                                    }
                                    return _buildNewReleaseItemFromAPI(
                                      item, 
                                      badge
                                    );
                                  },
                                ),
                        ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PeliculasView()),
                                  );
                                },
                              ),
                              _buildFooterLink(
                                Icons.tv, 
                                'Series',
                                isDark: isDark,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SeriesView()),
                                  );
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
                                'soporte.streamhub@gmail.com',
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
  
  // Método para construir elementos de "Continuar viendo" a partir de datos de la API
  Widget _buildContinueWatchingItemFromAPI(MediaItem item, String timeLeft) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    // Determinar la URL de la imagen del poster
    String imageUrl = TMDBService.getImageUrl(item.posterPath);
    
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poster con barra de progreso
          Container(
            height: 120,
            width: 150,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.posterPath.isEmpty
                      ? Image.asset(
                          'images/movie_poster.png',
                          height: 120,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          imageUrl,
                          height: 120,
                          width: 150,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: 150,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 150,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(Icons.error, color: Colors.white),
                              ),
                            );
                          },
                        ),
                ),
                // Barra de progreso en la parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          // Progreso aleatorio basado en el ID del elemento
                          width: 80 + (item.id % 50).toDouble(),
                          height: 4,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón de reproducción superpuesto
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Acción al hacer clic en reproducir
                        print('Reproduciendo: ${item.title}');
                      },
                      child: Center(
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Título
          Container(
            width: 150,
            child: Text(
              item.title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2),
          // Tiempo restante
          Text(
            timeLeft,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
          // Espacio adicional al final para evitar desbordamientos
          SizedBox(height: 8),
        ],
      ),
    );
  }
  
  // Método para construir elementos de "Nuevos lanzamientos" a partir de datos de la API
  Widget _buildNewReleaseItemFromAPI(MediaItem item, String badge) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    // Determinar la URL de la imagen del poster
    String imageUrl = TMDBService.getImageUrl(item.posterPath);
    
    // Determinar color de la etiqueta
    Color badgeColor;
    switch (badge) {
      case "NUEVO":
        badgeColor = Colors.red;
        break;
      case "SERIE":
        badgeColor = Colors.blue;
        break;
      case "PELÍCULA":
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = Colors.green;
    }
    
    // Extraer el año de la fecha de lanzamiento
    String year = '';
    if (item.releaseDate.length >= 4) {
      year = item.releaseDate.substring(0, 4);
    }
    
    // Calcular las estrellas basado en la puntuación media (de 0 a 10)
    int stars = (item.voteAverage / 2).round();
    
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poster con etiqueta
          Container(
            height: 180,
            width: 160,
            child: Stack(
              clipBehavior: Clip.none, // Evitar recortes
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.posterPath.isEmpty
                      ? Image.asset(
                          'images/movie_poster.png',
                          height: 180,
                          width: 160,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          imageUrl,
                          height: 180,
                          width: 160,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              width: 160,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: 160,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(Icons.error, color: Colors.white),
                              ),
                            );
                          },
                        ),
                ),
                // Etiqueta en la esquina superior
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Estrellas de puntuación
                if (item.voteAverage > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 2),
                          Text(
                            item.voteAverage.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Título
          Container(
            width: 160,
            child: Text(
              item.title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2),
          // Año o info adicional
          Text(
            year.isNotEmpty ? "Año: $year" : "Próximamente",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
          // Espacio adicional al final para evitar desbordamientos
          SizedBox(height: 8),
        ],
      ),
    );
  }
  
  // Método para construir botones de filtro
  Widget _buildFilterButton(String label, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected 
            ? isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue : isDark ? Colors.white30 : Colors.black12,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected 
              ? Colors.blue 
              : isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
