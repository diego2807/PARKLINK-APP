import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/login_response_model.dart';
import '../../domain/models/perfil_usuario_model.dart';
import '../../domain/models/usuario_model.dart';

/// ParkLink - Servicio de autenticación.
///
/// Endpoints cubiertos (Blueprint `auth_bp`, prefijo `/api/auth`):
/// - `POST /api/auth/login`
/// - `GET  /api/auth/perfil`
///
/// Endpoints complementarios del usuario autenticado (`usuario_bp`):
/// - `GET  /api/usuario/perfil`
/// - `PUT  /api/usuario/cambiar-password`
class AuthService {
  AuthService({ApiClient? cliente, SessionStorage? sesion})
      : _cliente = cliente ?? ApiClient.instance,
        _sesion = sesion ?? SessionStorage.instance;

  final ApiClient _cliente;
  final SessionStorage _sesion;

  /// Usuario autenticado en la sesión actual (o `null` si no hay sesión).
  UsuarioModel? get usuarioActual {
    final Map<String, dynamic>? json = _sesion.usuarioJson;
    if (json == null) return null;
    return UsuarioModel.fromJson(json);
  }

  /// Token JWT vigente.
  String? get token => _sesion.token;

  /// `true` cuando hay un token guardado en memoria.
  bool get estaAutenticado => _sesion.estaAutenticado;

  /// Inicia sesión y guarda el token para el resto de servicios.
  ///
  /// El controlador acepta indistintamente `correo` o `email`; se envían
  /// ambos para máxima compatibilidad.
  ///
  /// Lanza [BadRequestException] (400) si faltan credenciales,
  /// [UnauthorizedException] (401) si son incorrectas y
  /// [ForbiddenException] (403) si la cuenta está inactiva.
  Future<LoginResponseModel> login({
    required String correo,
    required String password,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.auth}/login',
      requiereAuth: false,
      cuerpo: <String, dynamic>{
        'correo': correo.trim().toLowerCase(),
        'email': correo.trim().toLowerCase(),
        'password': password,
      },
    );

    final LoginResponseModel resultado =
        LoginResponseModel.fromJson(JsonUtils.parseMapa(respuesta));

    if (!resultado.tieneToken) {
      throw const ApiException(
        'El servidor no devolvió un token de acceso válido.',
      );
    }

    _sesion.guardarSesion(
      token: resultado.token,
      usuario: resultado.usuario.toJson(),
    );

    return resultado;
  }

  /// Recupera los datos del usuario autenticado desde `GET /api/auth/perfil`.
  ///
  /// La respuesta viene envuelta como `{"usuario": {...}}`.
  Future<UsuarioModel> obtenerPerfilAutenticado() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.auth}/perfil');

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
    final Map<String, dynamic> usuarioJson =
        mapa.containsKey('usuario') ? JsonUtils.parseMapa(mapa['usuario']) : mapa;

    final UsuarioModel usuario = UsuarioModel.fromJson(usuarioJson);
    _sesion.actualizarUsuario(usuario.toJson());
    return usuario;
  }

  /// Perfil extendido con contadores de vehículos y reservas
  /// (`GET /api/usuario/perfil`).
  Future<PerfilUsuarioModel> obtenerPerfilDetallado() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.usuario}/perfil');
    return PerfilUsuarioModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Cambia la contraseña del usuario en sesión
  /// (`PUT /api/usuario/cambiar-password`).
  ///
  /// Reglas validadas por el Back-End:
  /// - La contraseña actual debe coincidir.
  /// - La nueva debe tener mínimo 8 caracteres.
  /// - La nueva no puede ser igual a la actual.
  ///
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    final dynamic respuesta = await _cliente.put(
      '${ApiConfig.usuario}/cambiar-password',
      cuerpo: <String, dynamic>{
        'password_actual': passwordActual,
        'password_nueva': passwordNueva,
      },
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['mensaje', 'message'],
      ),
      porDefecto: 'Contraseña actualizada correctamente',
    );
  }

  /// Verifica que el Back-End esté en línea (`GET /health`).
  Future<bool> verificarConexion() async {
    try {
      final dynamic respuesta =
          await _cliente.get(ApiConfig.health, requiereAuth: false);
      final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
      return JsonUtils.parseString(mapa['status']).toLowerCase() == 'online';
    } on ApiException {
      return false;
    }
  }

  /// Cierra la sesión local eliminando el token y los datos del usuario.
  void cerrarSesion() => _sesion.limpiar();
}
