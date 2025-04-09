import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Services/tmdb_service.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Models/media_item.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/theme_provider.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Secciones/peliculas.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Secciones/series.dart';

class Explorar extends StatefulWidget {
  const Explorar({super.key});

  @override
  _ExplorarState createState() => _ExplorarState();
}

class _ExplorarState extends State<Explorar> {
  // Listas para almacenar los datos de la API
  List<MediaItem> _moviesList = [];
  List<MediaItem> _seriesList = [];
  bool _isLoadingMovies = true;
  bool _isLoadingSeries = true;
  bool _hasErrorMovies = false;
  bool _hasErrorSeries = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Método para cargar datos de la API
  Future<void> _loadData() async {
    // Aseguramos que estamos en estado de carga al iniciar
    if (mounted) {
      setState(() {
        _isLoadingMovies = true;
        _isLoadingSeries = true;
        _hasErrorMovies = false;
        _hasErrorSeries = false;
      });
    }
    
    // Cargamos las películas
    try {
      print("Cargando películas...");
      final movies = await TMDBService.getPopularContent(isMovie: true);
      print("Películas cargadas: ${movies.length}");
      if (mounted) {
        setState(() {
          _moviesList = movies;
          _isLoadingMovies = false;
          _hasErrorMovies = false;
        });
      }
    } catch (e) {
      print("Error cargando películas: $e");
      if (mounted) {
        setState(() {
          _isLoadingMovies = false;
          _hasErrorMovies = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar películas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Cargamos las series
    try {
      print("Cargando series...");
      final series = await TMDBService.getPopularContent(isMovie: false);
      print("Series cargadas: ${series.length}");
      if (mounted) {
        setState(() {
          _seriesList = series;
          _isLoadingSeries = false;
          _hasErrorSeries = false;
        });
      }
    } catch (e) {
      print("Error cargando series: $e");
      if (mounted) {
        setState(() {
          _isLoadingSeries = false;
          _hasErrorSeries = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar series: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24)),
        backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con imagen
              Container(
                width: double.infinity,
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'StreamHub Explorar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenSize.width < 600 ? 32 : 48,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: screenSize.width * (screenSize.width < 600 ? 0.8 : 0.6),
                              child: Text(
                                'Descubre las mejores películas, series y contenido exclusivo en nuestra plataforma',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize.width < 600 ? 14 : 18,
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

              // Sección de Películas
              Padding(
                padding: EdgeInsets.only(left: 20, right: 0, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Películas'),
                    SizedBox(height: 20),
                    Container(
                      height: 300,
                      child: _isLoadingMovies
                          ? _buildLoadingIndicator()
                          : _hasErrorMovies
                              ? _buildErrorMessage('No se pudieron cargar las películas')
                              : _moviesList.isEmpty
                                  ? _buildEmptyMessage('No hay películas disponibles')
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(right: 20),
                                      child: Row(
                                        children: [
                                          ..._moviesList.map((movie) => _buildMovieCardFromAPI(movie)),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                    ),
                    SizedBox(height: 40),

                    // Sección de Series
                    _buildSectionTitle('Series'),
                    SizedBox(height: 20),
                    Container(
                      height: 300,
                      child: _isLoadingSeries
                          ? _buildLoadingIndicator()
                          : _hasErrorSeries
                              ? _buildErrorMessage('No se pudieron cargar las series')
                              : _seriesList.isEmpty
                                  ? _buildEmptyMessage('No hay series disponibles')
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(right: 20),
                                      child: Row(
                                        children: [
                                          ..._seriesList.map((serie) => _buildSeriesCardFromAPI(serie)),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                    ),
                    SizedBox(height: 40),

                    // Sección de Comentarios
                    _buildSectionTitle('Reviews'),
                    SizedBox(height: 20),
                    Container(
                      height: 200,
                      child: _isLoadingMovies || _moviesList.isEmpty
                          ? _buildLoadingIndicator()
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(right: 20),
                              child: Row(
                                children: [
                                  ...List.generate(
                                    _moviesList.length > 0 ? 5 : 0,
                                    (index) {
                                      String username = "Usuario ${index + 1}";
                                      String movieTitle = '';
                                      if (index < _moviesList.length) {
                                        movieTitle = _moviesList[index].title ?? 'esta película';
                                      } else {
                                        int randomIndex = index % _moviesList.length;
                                        movieTitle = _moviesList[randomIndex].title ?? 'esta película';
                                      }
                                      
                                      String comment = "Me encantó $movieTitle. La recomiendo mucho...";
                                      int rating = 3 + (index % 3);
                                      
                                      return _buildCommentCard(
                                        username,
                                        'images/user_avatar.png',
                                        comment,
                                        rating,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 20),
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
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando...',
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoadingMovies = true;
                _isLoadingSeries = true;
                _hasErrorMovies = false;
                _hasErrorSeries = false;
              });
              _loadData();
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            color: isDark ? Colors.white54 : Colors.black38,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            if (title == 'Películas') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PeliculasView()),
              );
            } else if (title == 'Series') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SeriesView()),
              );
            }
          },
          child: Text(
            'Ver más',
            style: TextStyle(
              color: isDark ? Colors.blue[300] : Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(String title, String imagePath, String rating) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 250,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesCard(String title, String imagePath, String season) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 250,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      season,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(String username, String avatarPath, String comment, int rating) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
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
                backgroundImage: AssetImage(avatarPath),
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
                      username,
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
                          index < rating ? Icons.star : Icons.star_border,
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
              comment,
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
              'Hace 3 días',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCardFromAPI(MediaItem movie) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    String imageUrl = TMDBService.getImageUrl(movie.posterPath ?? '');
    String rating = (movie.voteAverage ?? 0.0).toStringAsFixed(1);
    String year = (movie.releaseDate != null && movie.releaseDate!.isNotEmpty && movie.releaseDate!.length >= 4)
        ? movie.releaseDate!.substring(0, 4)
        : "Sin fecha";
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has seleccionado: ${movie.title ?? "Sin título"}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Imagen
                  (movie.posterPath == null || movie.posterPath!.isEmpty)
                      ? Container(
                          height: 250,
                          width: 200,
                          color: Colors.grey[800],
                          child: Center(
                            child: Icon(
                              Icons.movie_creation_outlined,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          height: 250,
                          width: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 250,
                              width: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print("Error cargando imagen: $error");
                            return Container(
                              height: 250,
                              width: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(Icons.error, color: Colors.white),
                              ),
                            );
                          },
                        ),
                  // Rating
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Etiqueta de película
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'PELÍCULA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Año en la parte inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        year,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 200,
              child: Text(
                movie.title ?? 'Sin título',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesCardFromAPI(MediaItem serie) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    String imageUrl = TMDBService.getImageUrl(serie.posterPath ?? '');
    String year = (serie.releaseDate != null && serie.releaseDate!.isNotEmpty && serie.releaseDate!.length >= 4)
        ? serie.releaseDate!.substring(0, 4)
        : "Sin fecha";
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has seleccionado: ${serie.title ?? "Sin título"}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Imagen
                  (serie.posterPath == null || serie.posterPath!.isEmpty)
                      ? Container(
                          height: 250,
                          width: 200,
                          color: Colors.grey[800],
                          child: Center(
                            child: Icon(
                              Icons.tv_outlined,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          height: 250,
                          width: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 250,
                              width: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print("Error cargando imagen de serie: $error");
                            return Container(
                              height: 250,
                              width: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(Icons.error, color: Colors.white),
                              ),
                            );
                          },
                        ),
                  // Etiqueta superior de tipo
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'SERIE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Rating
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            (serie.voteAverage ?? 0.0).toStringAsFixed(1),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Información en la parte inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Desde $year",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'TV',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
            Container(
              width: 200,
              child: Text(
                serie.title ?? 'Sin título',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
