import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/login_response_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  /// Método que ejecuta el inicio de sesión a través del servicio y Flask
  Future login({
    required String correo,
    required String password,
  }) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _authService.login(
        correo: correo,
        password: password,
      );
      _cargando = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _cargando = false;
      notifyListeners();
      rethrow; // Mantiene el error exacto para que el SnackBar de la pantalla lo muestre
    }
  }
}