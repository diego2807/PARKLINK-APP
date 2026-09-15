import '../../../../core/utils/json_utils.dart';
import 'usuario_model.dart';

/// Respuesta de `POST /api/auth/login`.
///
/// Contrato exacto de `AuthController.login()`:
/// ```json
/// {
///   "mensaje": "Autenticación exitosa.",
///   "token": "<jwt>",
///   "usuario": { ...Usuario.to_dict() }
/// }
/// ```
class LoginResponseModel {
  final String mensaje;
  final String token;
  final UsuarioModel usuario;

  const LoginResponseModel({
    required this.mensaje,
    required this.token,
    required this.usuario,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      mensaje: JsonUtils.parseString(
        json['mensaje'],
        porDefecto: 'Autenticación exitosa.',
      ),
      token: JsonUtils.parseString(
        JsonUtils.primeraLlave(
          json,
          <String>['token', 'access_token', 'accessToken'],
        ),
      ),
      usuario: UsuarioModel.fromJson(JsonUtils.parseMapa(json['usuario'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mensaje': mensaje,
      'token': token,
      'usuario': usuario.toJson(),
    };
  }

  /// `true` si el Back-End entregó un JWT utilizable.
  bool get tieneToken => token.isNotEmpty;

  /// Ruta a la que debe navegar la app según el rol autenticado.
  String get rutaInicial => usuario.rol.rutaInicial;

  @override
  String toString() =>
      'LoginResponseModel(usuario: ${usuario.correo}, rol: ${usuario.rol.valor})';
}
