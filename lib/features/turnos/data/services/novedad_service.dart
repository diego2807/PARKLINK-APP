import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/novedad_model.dart';

/// ParkLink - Servicio de novedades del vigilante.
///
/// Endpoints cubiertos (Blueprint `vigilante_bp`):
/// - `POST /api/vigilante/novedades`
/// - `GET  /api/vigilante/novedades`
///
/// Cada novedad registrada genera además una traza de nivel "advertencia"
/// en la bitácora de auditoría.
class NovedadService {
  NovedadService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Lista las novedades de la más reciente a la más antigua.
  Future<List<NovedadModel>> obtenerNovedades() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.vigilante}/novedades');
    return JsonUtils.parseLista<NovedadModel>(respuesta, NovedadModel.fromJson);
  }

  /// Novedades registradas el día de hoy.
  Future<List<NovedadModel>> obtenerNovedadesDeHoy() async {
    final List<NovedadModel> novedades = await obtenerNovedades();
    return novedades.where((NovedadModel novedad) => novedad.esDeHoy).toList();
  }

  /// Registra una nueva novedad.
  ///
  /// Lanza BadRequestException (400) si la descripción viene vacía.
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> registrarNovedad(String descripcion) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.vigilante}/novedades',
      cuerpo: <String, dynamic>{'descripcion': descripcion.trim()},
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['mensaje', 'message'],
      ),
      porDefecto: 'Novedad registrada correctamente',
    );
  }

  /// Variante que recibe un [NovedadModel] ya construido.
  Future<String> registrarNovedadDesdeModelo(NovedadModel novedad) {
    return registrarNovedad(novedad.descripcion);
  }

  /// Cantidad de novedades registradas (para badges y contadores).
  Future<int> contarNovedades() async {
    final List<NovedadModel> novedades = await obtenerNovedades();
    return novedades.length;
  }
}
