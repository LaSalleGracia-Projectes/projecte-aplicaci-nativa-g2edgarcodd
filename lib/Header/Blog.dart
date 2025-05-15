import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewsArticle {
  final String title;
  final String content;
  final String? imageUrl;
  final String source;
  final String publishedAt;
  final String type; // 'movie' or 'tv'
  final List<Review> reviews;

  NewsArticle({
    required this.title,
    required this.content,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.type,
    required this.reviews,
  });
}

class Review {
  final String author;
  final String content;
  final String? avatarPath;
  final double rating;
  final String createdAt;
  final String mediaTitle;
  final String mediaType;

  Review({
    required this.author,
    required this.content,
    this.avatarPath,
    required this.rating,
    required this.createdAt,
    required this.mediaTitle,
    required this.mediaType,
  });
}

class Blog extends StatefulWidget {
  const Blog({super.key});

  @override
  _BlogState createState() => _BlogState();
}

class _BlogState extends State<Blog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _selectedCategory = 'Todas';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<NewsArticle> _newsArticles = [];
  List<Review> _allReviews = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreMovies = true;
  bool _hasMoreTV = true;
  bool _showReviews = false;

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
    _loadNews();
    _loadReviews();
  }

  Future<void> _loadNews({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Obtener noticias de películas
      final moviesResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/now_playing?language=es-ES&page=$_currentPage'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      // Obtener noticias de series
      final tvResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/tv/on_the_air?language=es-ES&page=$_currentPage'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      List<NewsArticle> newArticles = [];

      // Procesar películas
      final moviesData = json.decode(moviesResponse.body);
      if (moviesData['results'].isEmpty) {
        _hasMoreMovies = false;
      } else {
        for (var movie in moviesData['results']) {
          // Obtener reviews de la película
          final reviewsResponse = await http.get(
            Uri.parse('https://api.themoviedb.org/3/movie/${movie['id']}/reviews?language=es-ES'),
            headers: {
              'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
              'accept': 'application/json',
            },
          );

          List<Review> reviews = [];
          if (reviewsResponse.statusCode == 200) {
            final reviewsData = json.decode(reviewsResponse.body);
            reviews = (reviewsData['results'] as List)
                .map((review) => Review(
                      author: review['author'] ?? 'Anónimo',
                      content: review['content'] ?? 'Sin contenido',
                      avatarPath: review['author_details']?['avatar_path'],
                      rating: (review['author_details']?['rating'] ?? 0).toDouble(),
                      createdAt: review['created_at'] ?? '',
                      mediaTitle: movie['title'],
                      mediaType: 'Película',
                    ))
                .toList();
          }

          newArticles.add(NewsArticle(
            title: movie['title'],
            content: movie['overview'],
            imageUrl: movie['poster_path'],
            source: 'TMDB',
            publishedAt: movie['release_date'],
            type: 'movie',
            reviews: reviews,
          ));
        }
      }

      // Procesar series
      final tvData = json.decode(tvResponse.body);
      if (tvData['results'].isEmpty) {
        _hasMoreTV = false;
      } else {
        for (var tv in tvData['results']) {
          // Obtener reviews de la serie
          final reviewsResponse = await http.get(
            Uri.parse('https://api.themoviedb.org/3/tv/${tv['id']}/reviews?language=es-ES'),
            headers: {
              'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
              'accept': 'application/json',
            },
          );

          List<Review> reviews = [];
          if (reviewsResponse.statusCode == 200) {
            final reviewsData = json.decode(reviewsResponse.body);
            reviews = (reviewsData['results'] as List)
                .map((review) => Review(
                      author: review['author'] ?? 'Anónimo',
                      content: review['content'] ?? 'Sin contenido',
                      avatarPath: review['author_details']?['avatar_path'],
                      rating: (review['author_details']?['rating'] ?? 0).toDouble(),
                      createdAt: review['created_at'] ?? '',
                      mediaTitle: tv['name'],
                      mediaType: 'Serie',
                    ))
                .toList();
          }

          newArticles.add(NewsArticle(
            title: tv['name'],
            content: tv['overview'],
            imageUrl: tv['poster_path'],
            source: 'TMDB',
            publishedAt: tv['first_air_date'],
            type: 'tv',
            reviews: reviews,
          ));
        }
      }

      setState(() {
        if (loadMore) {
          _newsArticles.addAll(newArticles);
          _isLoadingMore = false;
        } else {
          _newsArticles = newArticles;
          _isLoading = false;
        }
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        if (loadMore) {
          _isLoadingMore = false;
        } else {
          _hasError = true;
          _isLoading = false;
        }
      });
      print("Error cargando noticias: $e");
    }
  }

  Future<void> _loadReviews() async {
    try {
      // Lista de nombres de usuarios ficticios para el blog
      final List<String> usernames = [
        'CinefiloPro', 'SeriesMaster', 'StreamingExpert', 'CriticoDeCine', 'FanDeSeries',
        'MovieLover', 'TVAddict', 'StreamingGuru', 'CineCritico', 'SeriesFanatic',
        'FilmEnthusiast', 'TVSeriesPro', 'MovieBuff', 'StreamingCritic', 'CinemaLover',
        'SeriesExpert', 'FilmCritic', 'TVEnthusiast', 'StreamingMaster', 'Cinephile'
      ];

      // Lista de comentarios ficticios
      final List<String> comments = [
        '¡Increíble experiencia! La trama me mantuvo enganchado de principio a fin.',
        'Una obra maestra del cine moderno. Los efectos visuales son impresionantes.',
        'La actuación del elenco principal es simplemente excepcional.',
        'Una serie que redefine el género. No puedo esperar a la próxima temporada.',
        'La dirección y la fotografía son de otro nivel. Una joya cinematográfica.',
        'Los personajes están tan bien desarrollados que parece que los conoces en persona.',
        'El guión es brillante, lleno de giros inesperados y momentos emotivos.',
        'Una producción que demuestra que el streaming puede competir con el cine tradicional.',
        'La banda sonora es perfecta y complementa cada escena de manera magistral.',
        'Una historia que te hace reflexionar y te deja pensando días después.'
      ];

      // Generar reviews aleatorias
      for (int i = 0; i < 20; i++) {
        final random = Random();
        final username = usernames[random.nextInt(usernames.length)];
        final comment = comments[random.nextInt(comments.length)];
        final rating = 3 + random.nextInt(2); // Rating entre 3 y 5
        final daysAgo = random.nextInt(7); // Hace 0-7 días

        _allReviews.add(Review(
          author: username,
          content: comment,
          avatarPath: null,
          rating: rating.toDouble(),
          createdAt: DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String(),
          mediaTitle: '',
          mediaType: '',
        ));
      }

      setState(() {
        _allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (e) {
      print("Error cargando reviews: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blog, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24)),
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
            image: AssetImage('images/fondo2.png'),
            opacity: isDark ? 0.10 : 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con imagen
              Container(
                width: double.infinity,
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'images/fondo1.png',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'StreamHub ${l10n.blog}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: screenSize.width * 0.6,
                              child: Text(
                                l10n.blogDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.5,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido Principal
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Barra de búsqueda centrada
                    Center(
                      child: Container(
                        width: 500,
                        margin: EdgeInsets.only(bottom: 30),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: l10n.searchBlog,
                            hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                            prefixIcon: Icon(Icons.search, color: isDark ? Colors.white60 : Colors.black54),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Contenido principal con sidebar y películas
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Panel Izquierdo (Categorías y Newsletter)
                        Container(
                          width: 300,
                          child: Column(
                            children: [
                              // Categorías
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.categories,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      l10n.selectFilters,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    _buildCategoryButton(l10n.all, Icons.all_inclusive),
                                    _buildCategoryButton(l10n.movies, Icons.play_circle_outline),
                                    _buildCategoryButton(l10n.series, Icons.devices),
                                    _buildCategoryButton(l10n.reviews, Icons.message),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              
                              // Newsletter
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.subscribeNewsletter,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      l10n.newsletterDescription,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: _emailController,
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                      decoration: InputDecoration(
                                        hintText: l10n.yourEmail,
                                        hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black38),
                                        filled: true,
                                        fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_emailController.text.isNotEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(l10n.thanksForSubscribing),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            _emailController.clear();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          l10n.subscribe,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: 40),
                        
                        // Contenido Central (Películas)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isLoading)
                                Center(
                                  child: CircularProgressIndicator(),
                                )
                              else if (_hasError)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                                      SizedBox(height: 16),
                                      Text(
                                        l10n.errorLoadingNews,
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadNews,
                                        child: Text(l10n.retry),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    ..._newsArticles.asMap().entries.map((entry) => _buildNewsCard(
                                          entry.value.title,
                                          entry.value.content,
                                          entry.value.imageUrl != null
                                              ? 'https://image.tmdb.org/t/p/w500${entry.value.imageUrl}'
                                              : 'images/movie_poster.png',
                                          entry.value.type == 'movie' ? l10n.movie : l10n.series,
                                          entry.value.publishedAt,
                                          entry.key,
                                          entry.value.reviews,
                                        )),
                                    if (_hasMoreMovies || _hasMoreTV) ...[
                                      SizedBox(height: 20),
                                      Center(
                                        child: _isLoadingMore
                                            ? CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: () => _loadNews(loadMore: true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.add, color: Colors.white),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      l10n.loadMoreNews,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: 40),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Sección de Reviews
                    _buildReviewsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final isSelected = _selectedCategory == category;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.blue : isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : isDark ? Colors.white70 : Colors.black54,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.blue : isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(String title, String description, String imageUrl, String type, String date, int index, List<Review> reviews) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    
    // Lista de nombres de usuarios ficticios para el blog
    final List<String> usernames = [
      'CinefiloPro',
      'SeriesMaster',
      'StreamingExpert',
      'CriticoDeCine',
      'FanDeSeries',
      'MovieLover',
      'TVAddict',
      'StreamingGuru',
      'CineCritico',
      'SeriesFanatic',
      'FilmEnthusiast',
      'TVSeriesPro',
      'MovieBuff',
      'StreamingCritic',
      'CinemaLover',
      'SeriesExpert',
      'FilmCritic',
      'TVEnthusiast',
      'StreamingMaster',
      'Cinephile'
    ];
    
    // Seleccionar un nombre de usuario basado en el índice
    final username = usernames[index % usernames.length];
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la noticia
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
              width: 150,
              height: 200,
              fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 200,
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                      ),
                    );
                  },
            ),
          ),
          SizedBox(width: 20),
              // Información de la noticia
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: type == 'Película' ? Colors.blue : Colors.purple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        SizedBox(width: 4),
                        Text(
                          username,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                    height: 1.5,
                  ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reviews.isNotEmpty) ...[
            SizedBox(height: 20),
            Text(
              'Comentarios Recientes',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...reviews.take(3).map((review) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundImage: review.avatarPath != null
                                ? NetworkImage('https://image.tmdb.org/t/p/w45${review.avatarPath}')
                                : null,
                            child: review.avatarPath == null
                                ? Icon(Icons.person, size: 15)
                                : null,
                          ),
                          SizedBox(width: 8),
                          Text(
                            review.author,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (review.rating > 0) ...[
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRatingColor(review.rating),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 14),
                                  SizedBox(width: 2),
                                  Text(
                                    review.rating.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        review.content,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateTime.parse(review.createdAt).toLocal().toString().split(' ')[0],
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentComments,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showReviews = !_showReviews;
                  });
                },
                child: Text(
                  _showReviews ? l10n.hideComments : l10n.viewAllComments,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_showReviews)
            Container(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    ..._allReviews.map((review) => Container(
                          width: 280,
                          margin: EdgeInsets.only(right: 20),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: review.avatarPath != null
                                        ? NetworkImage('https://image.tmdb.org/t/p/w45${review.avatarPath}')
                                        : null,
                                    radius: 18,
                                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      color: isDark ? Colors.white : Colors.black45,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.author,
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review.rating.toInt() ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 14,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  review.content,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  l10n.daysAgo(DateTime.now().difference(DateTime.parse(review.createdAt)).inDays),
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(width: 20),
                  ],
                ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) {
      return Colors.green;
    } else if (rating >= 3.0) {
      return Colors.yellow;
    } else if (rating >= 2.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
