import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamhub/Models/media_item.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'fa4912f208d8c9000b8d8d009c28e2b5';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Método para obtener la URL completa de las imágenes
  static String getImageUrl(String path) {
    if (path.isEmpty) return '';
    return '$_imageBaseUrl$path';
  }

  // Método para obtener contenido popular (películas o series)
  static Future<List<MediaItem>> getPopularContent({required bool isMovie, int page = 1}) async {
    final contentType = isMovie ? 'movie' : 'tv';
    final url = '$_baseUrl/$contentType/popular?api_key=$_apiKey&language=es-ES&page=$page';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results.map((item) => MediaItem.fromJson(item, isMovie: isMovie)).toList();
      } else {
        throw Exception('Error al cargar contenido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para obtener contenido en tendencia
  static Future<List<MediaItem>> getTrendingContent({required bool isMovie}) async {
    final contentType = isMovie ? 'movie' : 'tv';
    final url = '$_baseUrl/trending/$contentType/week?api_key=$_apiKey&language=es-ES';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results.map((item) => MediaItem.fromJson(item, isMovie: isMovie)).toList();
      } else {
        throw Exception('Error al cargar contenido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para buscar películas o series
  static Future<List<MediaItem>> searchContent(String query, {required bool isMovie}) async {
    final contentType = isMovie ? 'movie' : 'tv';
    final url = '$_baseUrl/search/$contentType?api_key=$_apiKey&language=es-ES&query=$query';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results.map((item) => MediaItem.fromJson(item, isMovie: isMovie)).toList();
      } else {
        throw Exception('Error al buscar contenido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para obtener detalles de una película o serie específica
  static Future<MediaItem> getContentDetails(int id, {required bool isMovie}) async {
    final contentType = isMovie ? 'movie' : 'tv';
    final url = '$_baseUrl/$contentType/$id?api_key=$_apiKey&language=es-ES';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MediaItem.fromJson(data, isMovie: isMovie);
      } else {
        throw Exception('Error al cargar detalles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 