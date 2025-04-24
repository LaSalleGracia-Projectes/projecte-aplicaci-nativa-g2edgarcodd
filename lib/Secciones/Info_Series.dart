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

class SeriesDetails {
  final String overview;
  final List<String> genres;
  final List<Season> seasons;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final String tagline;
  final String status;
  final String originalLanguage;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final String firstAirDate;
  final String lastAirDate;
  final List<Review> reviews;

  SeriesDetails({
    required this.overview,
    required this.genres,
    required this.seasons,
    required this.cast,
    required this.crew,
    required this.tagline,
    required this.status,
    required this.originalLanguage,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.reviews,
  });
}

class Season {
  final String name;
  final String overview;
  final String posterPath;
  final int seasonNumber;
  final int episodeCount;
  final String airDate;

  Season({
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.seasonNumber,
    required this.episodeCount,
    required this.airDate,
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

class InfoSeriesView extends StatefulWidget {
  final MediaItem series;

  const InfoSeriesView({super.key, required this.series});

  @override
  _InfoSeriesViewState createState() => _InfoSeriesViewState();
}

class _InfoSeriesViewState extends State<InfoSeriesView> {
  SeriesDetails? _seriesDetails;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  List<Review> _allReviews = [];
  List<Review> _userReviews = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isPositive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSeriesDetails();
    _loadSavedReviews();
  }

  Future<void> _loadSeriesDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/tv/${widget.series.id}?language=es-ES'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      final creditsResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/tv/${widget.series.id}/credits?language=es-ES'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTQ5MTJmMjA4ZDhjOTAwMGI4ZDhkMDA5YzI4ZTJiNSIsIm5iZiI6MTc0MzY5NTA2NS40ODcsInN1YiI6IjY3ZWVhY2Q5MTVmNmJhODZmMWUxYTcwMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.yACTJlfSWaWUvtN7Iak36-gIqxlsh1JKzoFBa0hxNDU',
          'accept': 'application/json',
        },
      );

      await _loadReviews();

      if (response.statusCode == 200 && creditsResponse.statusCode == 200) {
        final seriesData = json.decode(response.body);
        final creditsData = json.decode(creditsResponse.body);

        setState(() {
          _seriesDetails = SeriesDetails(
            overview: seriesData['overview'] ?? 'Sin descripción',
            genres: (seriesData['genres'] as List)
                .map((genre) => genre['name'] as String)
                .toList(),
            seasons: (seriesData['seasons'] as List)
                .map((season) => Season(
                      name: season['name'] ?? 'Sin nombre',
                      overview: season['overview'] ?? 'Sin descripción',
                      posterPath: season['poster_path'],
                      seasonNumber: season['season_number'] ?? 0,
                      episodeCount: season['episode_count'] ?? 0,
                      airDate: season['air_date'] ?? 'Sin fecha',
                    ))
                .toList(),
            cast: (creditsData['cast'] as List)
                .take(10)
                .map((cast) => CastMember(
                      name: cast['name'] ?? 'Desconocido',
                      character: cast['character'] ?? 'Desconocido',
                      profilePath: cast['profile_path'],
                    ))
                .toList(),
            crew: (creditsData['crew'] as List)
                .where((crew) => ['Creator', 'Executive Producer'].contains(crew['job']))
                .map((crew) => CrewMember(
                      name: crew['name'] ?? 'Desconocido',
                      job: crew['job'] ?? 'Desconocido',
                      profilePath: crew['profile_path'],
                    ))
                .toList(),
            tagline: seriesData['tagline'] ?? '',
            status: seriesData['status'] ?? 'Desconocido',
            originalLanguage: seriesData['original_language'] ?? 'Desconocido',
            numberOfEpisodes: seriesData['number_of_episodes'] ?? 0,
            numberOfSeasons: seriesData['number_of_seasons'] ?? 0,
            firstAirDate: seriesData['first_air_date'] ?? 'Sin fecha',
            lastAirDate: seriesData['last_air_date'] ?? 'Sin fecha',
            reviews: _allReviews,
          );
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar los detalles de la serie');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print("Error cargando detalles de la serie: $e");
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información no disponible'),
          content: Text('Los detalles de la serie no están disponibles en este momento.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Volver a la pantalla anterior
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadReviews() async {
    try {
      final reviewsResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/tv/${widget.series.id}/reviews?page=$_currentPage'),
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

        if (_seriesDetails != null) {
          setState(() {
            _seriesDetails = SeriesDetails(
              overview: _seriesDetails!.overview,
              genres: _seriesDetails!.genres,
              seasons: _seriesDetails!.seasons,
              cast: _seriesDetails!.cast,
              crew: _seriesDetails!.crew,
              tagline: _seriesDetails!.tagline,
              status: _seriesDetails!.status,
              originalLanguage: _seriesDetails!.originalLanguage,
              numberOfEpisodes: _seriesDetails!.numberOfEpisodes,
              numberOfSeasons: _seriesDetails!.numberOfSeasons,
              firstAirDate: _seriesDetails!.firstAirDate,
              lastAirDate: _seriesDetails!.lastAirDate,
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

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.orange;
    return Colors.red;
  }

  Future<void> _loadSavedReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedReviews = prefs.getStringList('reviews_series_${widget.series.id}');
      
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
      final savedReviews = prefs.getStringList('reviews_series_${widget.series.id}') ?? [];
      
      final reviewMap = {
        'author': review.author,
        'content': review.content,
        'avatarPath': review.avatarPath,
        'rating': review.rating,
        'createdAt': review.createdAt,
      };
      
      savedReviews.add(json.encode(reviewMap));
      await prefs.setStringList('reviews_series_${widget.series.id}', savedReviews);
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
                      'movie_id': widget.series.id.toString(),
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    _titleController.clear();
                    _bodyController.clear();
                    
                    Navigator.of(context).pop();
                    
                    final newReview = Review(
                      author: "Tú",
                      content: reviewTitle + ": " + reviewBody,
                      avatarPath: null,
                      rating: _isPositive ? 10.0 : 3.0,
                      createdAt: DateTime.now().toIso8601String(),
                    );
                    
                    await _saveReview(newReview);
                    
                    setState(() {
                      _userReviews.insert(0, newReview);
                      
                      if (_seriesDetails != null) {
                        _seriesDetails = SeriesDetails(
                          overview: _seriesDetails!.overview,
                          genres: _seriesDetails!.genres,
                          seasons: _seriesDetails!.seasons,
                          cast: _seriesDetails!.cast,
                          crew: _seriesDetails!.crew,
                          tagline: _seriesDetails!.tagline,
                          status: _seriesDetails!.status,
                          originalLanguage: _seriesDetails!.originalLanguage,
                          numberOfEpisodes: _seriesDetails!.numberOfEpisodes,
                          numberOfSeasons: _seriesDetails!.numberOfSeasons,
                          firstAirDate: _seriesDetails!.firstAirDate,
                          lastAirDate: _seriesDetails!.lastAirDate,
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
        title: Text(widget.series.title ?? 'Detalles de la serie',
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
                          'Error al cargar los detalles de la serie',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSeriesDetails,
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
                                TMDBService.getImageUrl(widget.series.posterPath ?? ''),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Icon(Icons.tv, color: Colors.white, size: 50),
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
                                        widget.series.title ?? 'Sin título',
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
                                            (widget.series.voteAverage ?? 0.0).toStringAsFixed(1),
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
                                if (_seriesDetails!.tagline.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    _seriesDetails!.tagline,
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
                                      _seriesDetails!.firstAirDate,
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.tv,
                                      '${_seriesDetails!.numberOfSeasons} Temporadas',
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.movie,
                                      '${_seriesDetails!.numberOfEpisodes} Episodios',
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.language,
                                      _seriesDetails!.originalLanguage.toUpperCase(),
                                      isDark,
                                    ),
                                    _buildInfoChip(
                                      Icons.verified,
                                      _seriesDetails!.status,
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
                                  children: _seriesDetails!.genres
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
                                  _seriesDetails!.overview,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Creadores',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ..._seriesDetails!.crew
                                    .where((crew) => crew.job == 'Creator')
                                    .map((creator) => Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            creator.name,
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
                                    itemCount: _seriesDetails!.cast.length,
                                    itemBuilder: (context, index) {
                                      final cast = _seriesDetails!.cast[index];
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
                                  'Temporadas',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ..._seriesDetails!.seasons.map((season) => Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black38 : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: season.posterPath != null
                                                  ? Image.network(
                                                      TMDBService.getImageUrl(season.posterPath),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      color: Colors.grey[800],
                                                      child: Center(
                                                        child: Icon(Icons.tv, color: Colors.white, size: 30),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  season.name,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white : Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  '${season.episodeCount} episodios',
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white70 : Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (season.airDate.isNotEmpty) ...[
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Estreno: ${season.airDate}',
                                                    style: TextStyle(
                                                      color: isDark ? Colors.white70 : Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                                if (season.overview.isNotEmpty) ...[
                                                  SizedBox(height: 8),
                                                  Text(
                                                    season.overview,
                                                    style: TextStyle(
                                                      color: isDark ? Colors.white70 : Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 32),
                                if (_combinedReviews.isNotEmpty) ...[
                                  SizedBox(height: 24),
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
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: _getRatingColor(review.rating),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.star, color: Colors.white, size: 16),
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
}
