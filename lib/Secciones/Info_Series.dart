import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/theme_provider.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Models/media_item.dart';
import 'package:projecte_aplicaci_nativa_g2edgarcodd/Services/tmdb_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadSeriesDetails();
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
    }
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
                          // Poster a la izquierda
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
                          // Información a la derecha
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título y rating
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
                                // Información básica
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
                                // Géneros
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
                                // Sinopsis
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
                                // Creadores
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
                                // Reparto principal
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
                                // Temporadas
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
