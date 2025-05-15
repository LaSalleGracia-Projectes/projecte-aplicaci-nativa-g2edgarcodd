class MediaItem {
  final int? id;
  final String? title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? releaseDate;
  final bool isMovie;

  MediaItem({
    this.id,
    this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    required this.isMovie,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, {required bool isMovie}) {
    return MediaItem(
      id: json['id'],
      // Para películas usamos 'title', para series 'name'
      title: isMovie ? json['title'] : json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble(),
      // Para películas usamos 'release_date', para series 'first_air_date'
      releaseDate: isMovie ? json['release_date'] : json['first_air_date'],
      isMovie: isMovie,
    );
  }

  // Método de utilidad para calcular qué tan reciente es el contenido
  bool get isRecent {
    if (releaseDate == null || releaseDate!.isEmpty) return false;
    
    try {
      final releaseDateTime = DateTime.parse(releaseDate!);
      final now = DateTime.now();
      final difference = now.difference(releaseDateTime);
      
      // Consideramos reciente si se lanzó en los últimos 90 días
      return difference.inDays <= 90;
    } catch (e) {
      return false;
    }
  }

  // Método para obtener la duración formateada (para la vista de "Continuar viendo")
  String getRemainingTime(int watchedMinutes, int totalMinutes) {
    final remaining = totalMinutes - watchedMinutes;
    
    if (remaining <= 0) return "Completado";
    
    if (isMovie) {
      return "$remaining min restantes";
    } else {
      // Para series, asumimos episodios de 40-60 minutos
      return "Continuar episodio";
    }
  }

  // Método para obtener el progreso de visualización (para la barra de progreso)
  double getWatchProgress(int watchedMinutes, int totalMinutes) {
    if (totalMinutes <= 0) return 0.0;
    double progress = watchedMinutes / totalMinutes;
    // Aseguramos que el valor esté entre 0 y 1
    return progress.clamp(0.0, 1.0);
  }
} 