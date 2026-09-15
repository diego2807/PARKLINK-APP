import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Para emulador Android usa 10.0.2.2. Si es dispositivo físico, usa tu IP local (ej. 192.168.x.x)
  static const String _baseUrl = 'http://10.0.2.2:5000/api/auth';

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Retorna el mapa completo con el token y el rol
        return {
          'token': data['access_token'] ?? data['token'],
          'rol': data['rol'] ?? data['usuario']?['rol'] ?? 'usuario',
        };
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }
}