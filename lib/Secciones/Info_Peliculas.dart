import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/theme_provider.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Models/media_item.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Services/tmdb_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Review {
  final String author;
  final String content;
  final String? avatarPath;
  final double rating;
  final String createdAt;

  Review({
    required this.author,
    required this.content,
    this.avatarPath,
    required this.rating,
    required this.createdAt,
  });
}

class MovieDetails {
  final String overview;
  final List<String> genres;
  final String runtime;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final String tagline;
  final String status;
  final String originalLanguage;
  final double budget;
  final double revenue;
  final List<Review> reviews;

  MovieDetails({
    required this.overview,
    required this.genres,
    required this.runtime,
    required this.cast,
    required this.crew,
    required this.tagline,
    required this.status,
    required this.originalLanguage,
    required this.budget,
    required this.revenue,
    required this.reviews,
  });
}

class CastMember {
  final String name;
  final String character;
  final String? profilePath;

  CastMember({
    required this.name,
    required this.character,
    this.profilePath,
  });
}

class CrewMember {
  final String name;
  final String job;
  final String? profilePath;

  CrewMember({
    required this.name,
    required this.job,
    this.profilePath,
  });
}

class InfoPeliculasView extends StatefulWidget {
  final MediaItem movie;

  const InfoPeliculasView({super.key, required this.movie});

  @override
  _InfoPeliculasViewState createState() => _InfoPeliculasViewState();
}

class _InfoPeliculasViewState extends State<InfoPeliculasView> {
  MovieDetails? _movieDetails;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  List<Review> _allReviews = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isPositive = true;
  List<Review> _userReviews = [];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _loadSavedReviews();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/${widget.movie.id}?language=es-ES'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      final creditsResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/${widget.movie.id}/credits?language=es-ES'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      await _loadReviews();

      if (response.statusCode == 200 && creditsResponse.statusCode == 200) {
        final movieData = json.decode(response.body);
        final creditsData = json.decode(creditsResponse.body);

        setState(() {
          _movieDetails = MovieDetails(
            overview: movieData['overview'] ?? 'Sin descripción',
            genres: (movieData['genres'] as List)
                .map((genre) => genre['name'] as String)
                .toList(),
            runtime: '${movieData['runtime'] ?? 0} minutos',
            cast: (creditsData['cast'] as List)
                .take(10)
                .map((cast) => CastMember(
                      name: cast['name'] ?? 'Desconocido',
                      character: cast['character'] ?? 'Desconocido',
                      profilePath: cast['profile_path'],
                    ))
                .toList(),
            crew: (creditsData['crew'] as List)
                .where((crew) => ['Director', 'Screenplay', 'Story'].contains(crew['job']))
                .map((crew) => CrewMember(
                      name: crew['name'] ?? 'Desconocido',
                      job: crew['job'] ?? 'Desconocido',
                      profilePath: crew['profile_path'],
                    ))
                .toList(),
            tagline: movieData['tagline'] ?? '',
            status: movieData['status'] ?? 'Desconocido',
            originalLanguage: movieData['original_language'] ?? 'Desconocido',
            budget: (movieData['budget'] ?? 0).toDouble(),
            revenue: (movieData['revenue'] ?? 0).toDouble(),
            reviews: _allReviews,
          );
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar los detalles de la película');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print("Error cargando detalles de la película: $e");
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviewsResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/${widget.movie.id}/reviews?page=$_currentPage'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      if (reviewsResponse.statusCode == 200) {
        final reviewsData = json.decode(reviewsResponse.body);
        _totalPages = reviewsData['total_pages'] ?? 1;
        
        final newReviews = (reviewsData['results'] as List)
            .map((review) => Review(
                  author: review['author'] ?? 'Anónimo',
                  content: review['content'] ?? 'Sin contenido',
                  avatarPath: review['author_details']?['avatar_path'],
                  rating: (review['author_details']?['rating'] ?? 0).toDouble(),
                  createdAt: review['created_at'] ?? '',
                ))
            .toList();

        setState(() {
          if (_currentPage == 1) {
            _allReviews = newReviews;
          } else {
            _allReviews.addAll(newReviews);
          }
          _isLoadingMore = false;
        });

        if (_movieDetails != null) {
          setState(() {
            _movieDetails = MovieDetails(
              overview: _movieDetails!.overview,
              genres: _movieDetails!.genres,
              runtime: _movieDetails!.runtime,
              cast: _movieDetails!.cast,
              crew: _movieDetails!.crew,
              tagline: _movieDetails!.tagline,
              status: _movieDetails!.status,
              originalLanguage: _movieDetails!.originalLanguage,
              budget: _movieDetails!.budget,
              revenue: _movieDetails!.revenue,
              reviews: _allReviews,
            );
          });
        }
      }
    } catch (e) {
      print("Error cargando reseñas: $e");
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreReviews() async {
    if (!_isLoadingMore && _currentPage < _totalPages) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      await _loadReviews();
    }
  }

  Future<void> _loadSavedReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedReviews = prefs.getStringList('reviews_movie_${widget.movie.id}');
      
      if (savedReviews != null && savedReviews.isNotEmpty) {
        final reviews = savedReviews.map((reviewJson) {
          final data = json.decode(reviewJson);
          return Review(
            author: data['author'] ?? 'Tú',
            content: data['content'] ?? '',
            avatarPath: data['avatarPath'],
            rating: (data['rating'] ?? 0).toDouble(),
            createdAt: data['createdAt'] ?? DateTime.now().toIso8601String(),
          );
        }).toList();
        
        setState(() {
          _userReviews = reviews;
        });
      }
    } catch (e) {
      print('Error cargando reviews guardadas: $e');
    }
  }

  Future<void> _saveReview(Review review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedReviews = prefs.getStringList('reviews_movie_${widget.movie.id}') ?? [];
      
      final reviewMap = {
        'author': review.author,
        'content': review.content,
        'avatarPath': review.avatarPath,
        'rating': review.rating,
        'createdAt': review.createdAt,
      };
      
      savedReviews.add(json.encode(reviewMap));
      await prefs.setStringList('reviews_movie_${widget.movie.id}', savedReviews);
    } catch (e) {
      print('Error guardando review: $e');
    }
  }

  List<Review> get _combinedReviews {
    final List<Review> combinedList = [..._allReviews];
    
    if (_userReviews.isNotEmpty) {
      combinedList.insertAll(0, _userReviews);
    }
    
    return combinedList;
  }

  Future<String> _getUsername() async {
    try {
      final response = await http.get(
        Uri.parse('http://25.17.74.119:8000/api/getUser'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['username'] ?? 'Usuario';
        }
      }
      return 'Usuario';
    } catch (e) {
      print('Error obteniendo nombre de usuario: $e');
      return 'Usuario';
    }
  }

  Future<void> _createReview() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        
        return AlertDialog(
          backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
          title: Text(
            'Crear Review',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _bodyController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Contenido',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Valoración:',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    SizedBox(width: 16),
                    Switch(
                      value: _isPositive,
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() {
                          _isPositive = value;
                        });
                      },
                    ),
                    Text(
                      _isPositive ? 'Positiva' : 'Negativa',
                      style: TextStyle(
                        color: _isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, completa todos los campos'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final reviewTitle = _titleController.text;
                  final reviewBody = _bodyController.text;
                  final username = await _getUsername();
                  
                  final response = await http.post(
                    Uri.parse('http://25.17.74.119:8000/api/createReview'),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'title': reviewTitle,
                      'body': reviewBody,
                      'is_positive': _isPositive,
                      'user_id': 1,
                      'movie_id': widget.movie.id.toString(),
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    _titleController.clear();
                    _bodyController.clear();
                    Navigator.of(context).pop();
                    
                    final newReview = Review(
                      author: username,
                      content: reviewTitle + ": " + reviewBody,
                      avatarPath: null,
                      rating: _isPositive ? 10.0 : 3.0,
                      createdAt: DateTime.now().toIso8601String(),
                    );
                    
                    await _saveReview(newReview);
                    
                    setState(() {
                      _userReviews.insert(0, newReview);
                      
                      if (_movieDetails != null) {
                        _movieDetails = MovieDetails(
                          overview: _movieDetails!.overview,
                          genres: _movieDetails!.genres,
                          runtime: _movieDetails!.runtime,
                          cast: _movieDetails!.cast,
                          crew: _movieDetails!.crew,
                          tagline: _movieDetails!.tagline,
                          status: _movieDetails!.status,
                          originalLanguage: _movieDetails!.originalLanguage,
                          budget: _movieDetails!.budget,
                          revenue: _movieDetails!.revenue,
                          reviews: _combinedReviews,
                        );
                      }
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Review creada con éxito'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    print('Error response body: ${response.body}');
                    throw Exception('Error al crear la review: ${response.statusCode}');
                  }
                } catch (e) {
                  print('Error al crear la review: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear la review: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title ?? 'Detalles de la película',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review),
            tooltip: 'Crear Review',
            onPressed: _createReview,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF060D17) : Colors.white,
          image: DecorationImage(
            image: AssetImage('images/fondo2.png'),
            opacity: isDark ? 0.10 : 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar los detalles de la película',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMovieDetails,
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                TMDBService.getImageUrl(widget.movie.posterPath ?? ''),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Icon(Icons.movie, color: Colors.white, size: 50),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.movie.title ?? 'Sin título',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black38 : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 20),
                                          SizedBox(width: 4),
                                          Text(
                                            (widget.movie.voteAverage ?? 0.0).toStringAsFixed(1),
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_movieDetails!.tagline.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    _movieDetails!.tagline,
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildInfoChip(
                                      Icons.calendar_today,
                                      widget.movie.releaseDate ?? 'Sin fecha',
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.timer,
                                      _movieDetails!.runtime,
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.language,
                                      _movieDetails!.originalLanguage.toUpperCase(),
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.verified,
                                      _movieDetails!.status,
                                      isDark,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Géneros',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _movieDetails!.genres
                                      .map((genre) => Chip(
                                            label: Text(genre),
                                            backgroundColor: isDark ? Colors.black38 : Colors.grey[200],
                                          ))
                                      .toList(),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Sinopsis',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _movieDetails!.overview,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Directores',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ..._movieDetails!.crew
                                    .where((crew) => crew.job == 'Director')
                                    .map((director) => Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            director.name,
                                            style: TextStyle(
                                              color: isDark ? Colors.white70 : Colors.black54,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )),
                                SizedBox(height: 24),
                                Text(
                                  'Reparto Principal',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _movieDetails!.cast.length,
                                    itemBuilder: (context, index) {
                                      final cast = _movieDetails!.cast[index];
                                      return Container(
                                        width: 90,
                                        margin: EdgeInsets.only(right: 16),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage: cast.profilePath != null
                                                  ? NetworkImage(TMDBService.getImageUrl(cast.profilePath!))
                                                  : null,
                                              child: cast.profilePath == null
                                                  ? Icon(Icons.person, size: 25)
                                                  : null,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              cast.name,
                                              style: TextStyle(
                                                color: isDark ? Colors.white : Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              cast.character,
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                                fontSize: 9,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Equipo Técnico',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ..._movieDetails!.crew
                                    .where((crew) => crew.job != 'Director')
                                    .take(5)
                                    .map((crew) => Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${crew.job}: ',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                crew.name,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                SizedBox(height: 24),
                                Text(
                                  'Información Financiera',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black38 : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Presupuesto',
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '\$${_formatCurrency(_movieDetails!.budget)}',
                                              style: TextStyle(
                                                color: isDark ? Colors.white : Colors.black,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ingresos',
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '\$${_formatCurrency(_movieDetails!.revenue)}',
                                              style: TextStyle(
                                                color: isDark ? Colors.white : Colors.black,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Beneficio',
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '\$${_formatCurrency(_movieDetails!.revenue - _movieDetails!.budget)}',
                                              style: TextStyle(
                                                color: _movieDetails!.revenue > _movieDetails!.budget 
                                                    ? Colors.green 
                                                    : Colors.red,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 32),
                                if (_combinedReviews.isNotEmpty) ...[
                                  Text(
                                    'Mejores Reseñas',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total: ${_combinedReviews.length} reseñas',
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _createReview,
                                        icon: Icon(Icons.add),
                                        label: Text('Crear Review'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  ...(_combinedReviews.map((review) => Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        padding: EdgeInsets.all(16),
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
                                                  radius: 20,
                                                  backgroundImage: review.avatarPath != null
                                                      ? NetworkImage(TMDBService.getImageUrl(review.avatarPath!))
                                                      : null,
                                                  child: review.avatarPath == null
                                                      ? Icon(Icons.person, size: 20)
                                                      : null,
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        review.author,
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : Colors.black,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        DateTime.parse(review.createdAt)
                                                            .toLocal()
                                                            .toString()
                                                            .split(' ')[0],
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white70 : Colors.black54,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (review.rating > 0)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: _getRatingColor(review.rating),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.star,
                                                            color: Colors.white, size: 16),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          review.rating.toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              review.content,
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black87,
                                                fontSize: 14,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ))),
                                  SizedBox(height: 16),
                                  Center(
                                    child: _isLoadingMore
                                        ? CircularProgressIndicator()
                                        : _currentPage < _totalPages
                                            ? ElevatedButton(
                                                onPressed: _loadMoreReviews,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isDark ? Colors.blue : Colors.blue,
                                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Cargar más reseñas',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(Icons.refresh, color: Colors.white),
                                                  ],
                                                ),
                                              )
                                            : Text(
                                                'No hay más reseñas disponibles',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                  ),
                                ] else
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black38 : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'No hay reseñas disponibles',
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black54,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: _createReview,
                                          icon: Icon(Icons.add),
                                          label: Text('Crear Review'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) return '0';
    if (value < 1000) return value.toStringAsFixed(0);
    if (value < 1000000) return '${(value / 1000).toStringAsFixed(1)}K';
    if (value < 1000000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black38 : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.black54),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.orange;
    return Colors.red;
  }
}
