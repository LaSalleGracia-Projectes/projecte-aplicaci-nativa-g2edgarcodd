import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Variables para almacenar información del usuario
  String? _token;
  int? _userId;
  
  // Getters
  String? get token => _token;
  int? get userId => _userId;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => _token != null;

  // Método para establecer el token después del login
  void setToken(String token) {
    _token = token;
  }

  // Método para establecer el userId
  void setUserId(int userId) {
    _userId = userId;
  }

  // Método para limpiar los datos del usuario al cerrar sesión
  void logout() {
    _token = null;
    _userId = null;
  }

  // Método para obtener datos del usuario usando solo el token
  Future<Map<String, dynamic>?> getUserData() async {
    if (_token == null) {
      print('No hay token disponible');
      return null;
    }

    try {
      print('Obteniendo datos del usuario con token: $_token');
      final response = await http.get(
        Uri.parse('http://25.17.74.119:8000/api/getUserByToken'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Guardamos el ID del usuario si no lo teníamos
          if (jsonResponse['data']['id'] != null && _userId == null) {
            _userId = jsonResponse['data']['id'];
            print('ID de usuario guardado: $_userId');
          }
          return jsonResponse['data'];
        }
      }
      
      print('Error o respuesta inválida del servidor');
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }
} 