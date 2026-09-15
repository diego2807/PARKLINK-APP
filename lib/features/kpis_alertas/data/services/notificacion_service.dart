import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/notificacion_model.dart';

/// ParkLink - Servicio de notificaciones del usuario final.
///
/// Endpoint cubierto (Blueprint `usuario_bp`):
/// - `GET /api/usuario/notificaciones`
///
/// La fuente son las novedades registradas por los vigilantes, ordenadas de
/// la más reciente a la más antigua.
class NotificacionService {
  NotificacionService({ApiClient? cliente})
      : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Lista las notificaciones del usuario en sesión.
  Future<List<NotificacionModel>> obtenerNotificaciones() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.usuario}/notificaciones');
    return JsonUtils.parseLista<NotificacionModel>(
      respuesta,
      NotificacionModel.fromJson,
    );
  }

  /// Notificaciones publicadas el día de hoy.
  Future<List<NotificacionModel>> obtenerNotificacionesDeHoy() async {
    final List<NotificacionModel> notificaciones = await obtenerNotificaciones();
    return notificaciones
        .where((NotificacionModel notificacion) => notificacion.esDeHoy)
        .toList();
  }

  /// Cantidad de notificaciones disponibles (para el badge del ícono).
  Future<int> contarNotificaciones() async {
    final List<NotificacionModel> notificaciones = await obtenerNotificaciones();
    return notificaciones.length;
  }
}
