import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/configuracion_model.dart';

/// ParkLink - Servicio de parámetros globales.
///
/// Endpoints cubiertos (Blueprint `config_bp`, prefijo `/api/admin`):
/// - `GET  /api/admin/config`
/// - `PUT  /api/admin/config`  (el Back-End también acepta `POST`)
///
/// Si la tabla está vacía, el `GET` crea automáticamente el registro con los
/// valores por defecto y lo devuelve.
class ConfiguracionService {
  ConfiguracionService({ApiClient? cliente})
      : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Obtiene la configuración vigente.
  Future<ConfiguracionModel> obtenerConfiguracion() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.admin}/config');
    return ConfiguracionModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Guarda la configuración completa y devuelve la versión ya persistida.
  ///
  /// Lanza BadRequestException (400) si algún cupo o tiempo no es numérico.
  Future<ConfiguracionModel> actualizarConfiguracion(
    ConfiguracionModel configuracion,
  ) async {
    final dynamic respuesta = await _cliente.put(
      '${ApiConfig.admin}/config',
      cuerpo: configuracion.toJson(),
    );

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
    final ConfiguracionModel actualizada = ConfiguracionModel.fromJson(mapa);

    // La respuesta de actualización no incluye `id`: se conserva el original.
    return actualizada.copyWith(id: configuracion.id);
  }

  /// Actualiza únicamente los campos indicados, conservando el resto.
  ///
  /// Hace primero un `GET` para no perder los valores no enviados.
  Future<ConfiguracionModel> actualizarParcial({
    String? horaApertura,
    String? horaCierre,
    bool? permitirFestivos,
    int? tiempoMaximo,
    AccionExceso? accionExceso,
    int? celdasAdmin,
    int? celdasOperativas,
    int? celdasMovilidad,
  }) async {
    final ConfiguracionModel actual = await obtenerConfiguracion();

    return actualizarConfiguracion(
      actual.copyWith(
        horaApertura: horaApertura,
        horaCierre: horaCierre,
        permitirFestivos: permitirFestivos,
        tiempoMaximo: tiempoMaximo,
        accionExceso: accionExceso,
        celdasAdmin: celdasAdmin,
        celdasOperativas: celdasOperativas,
        celdasMovilidad: celdasMovilidad,
      ),
    );
  }

  /// Mensaje de confirmación devuelto por la última actualización.
  ///
  /// Útil cuando la pantalla sólo necesita mostrar el aviso de éxito.
  Future<String> guardarYObtenerMensaje(
    ConfiguracionModel configuracion,
  ) async {
    final dynamic respuesta = await _cliente.put(
      '${ApiConfig.admin}/config',
      cuerpo: configuracion.toJson(),
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['message', 'mensaje'],
      ),
      porDefecto: 'Parámetros del sistema ParkLink actualizados con éxito',
    );
  }
}
