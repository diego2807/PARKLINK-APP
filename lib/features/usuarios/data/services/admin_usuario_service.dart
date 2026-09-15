import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../auth/domain/models/usuario_model.dart';

/// ParkLink - Servicio de administración de personal.
///
/// Endpoint cubierto (Blueprint `admin_bp`):
/// - `POST /api/admin/registrar-usuario`
///
/// El Back-End genera una contraseña temporal segura y la envía por correo
/// electrónico al usuario creado, por lo que la app nunca la manipula.
class AdminUsuarioService {
  AdminUsuarioService({ApiClient? cliente})
      : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Da de alta a un empleado (usuario o vigilante).
  ///
  /// Requiere rol `administrador`.
  ///
  /// Lanza:
  /// - ForbiddenException (403) si el rol autenticado no es administrador.
  /// - BadRequestException (400) si faltan campos, el rol no es válido
  ///   o el correo ya está registrado.
  Future<UsuarioModel> registrarUsuario({
    required String nombreCompleto,
    required String correo,
    RolUsuario rol = RolUsuario.usuario,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.admin}/registrar-usuario',
      cuerpo: <String, dynamic>{
        'nombre_completo': nombreCompleto.trim(),
        'nombre': nombreCompleto.trim(),
        'correo': correo.trim().toLowerCase(),
        'rol': rol.valor,
      },
    );

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
    return UsuarioModel.fromJson(JsonUtils.parseMapa(mapa['usuario']));
  }

  /// Igual que [registrarUsuario] pero devuelve también el mensaje del
  /// servidor, útil para confirmar el envío del correo de bienvenida.
  Future<({UsuarioModel usuario, String mensaje})> registrarUsuarioConMensaje({
    required String nombreCompleto,
    required String correo,
    RolUsuario rol = RolUsuario.usuario,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.admin}/registrar-usuario',
      cuerpo: <String, dynamic>{
        'nombre_completo': nombreCompleto.trim(),
        'nombre': nombreCompleto.trim(),
        'correo': correo.trim().toLowerCase(),
        'rol': rol.valor,
      },
    );

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);

    return (
      usuario: UsuarioModel.fromJson(JsonUtils.parseMapa(mapa['usuario'])),
      mensaje: JsonUtils.parseString(
        JsonUtils.primeraLlave(mapa, <String>['message', 'mensaje']),
        porDefecto:
            'Usuario creado con éxito y credenciales enviadas por correo.',
      ),
    );
  }
}
