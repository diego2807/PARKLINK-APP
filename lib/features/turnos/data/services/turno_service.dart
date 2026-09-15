import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/resultado_turno_model.dart';
import '../../domain/models/resumen_turno_model.dart';
import '../../domain/models/turno_model.dart';

/// ParkLink - Servicio de gestión de turnos de vigilancia.
///
/// Endpoints cubiertos (Blueprint `vigilante_bp`):
/// - `POST /api/vigilante/apertura-turno`
/// - `POST /api/vigilante/cierre-turno`
/// - `GET  /api/vigilante/turnos`
/// - `GET  /api/vigilante/resumen-turno`
class TurnoService {
  TurnoService({ApiClient? cliente, SessionStorage? sesion})
      : _cliente = cliente ?? ApiClient.instance,
        _sesion = sesion ?? SessionStorage.instance;

  final ApiClient _cliente;
  final SessionStorage _sesion;

  /// Abre un turno para el vigilante autenticado.
  ///
  /// El Back-End responde 201 tanto si crea el turno como si ya existía uno
  /// activo; [ResultadoTurnoModel.yaExistiaTurno] permite distinguirlo.
  Future<ResultadoTurnoModel> abrirTurno() async {
    final dynamic respuesta =
        await _cliente.post('${ApiConfig.vigilante}/apertura-turno');
    return ResultadoTurnoModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Cierra el turno activo del vigilante autenticado.
  ///
  /// Lanza [NotFoundException] (404) cuando no hay ningún turno abierto.
  Future<ResultadoTurnoModel> cerrarTurno() async {
    final dynamic respuesta =
        await _cliente.post('${ApiConfig.vigilante}/cierre-turno');
    return ResultadoTurnoModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Lista todos los turnos registrados en el sistema.
  Future<List<TurnoModel>> obtenerTurnos() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.vigilante}/turnos');
    return JsonUtils.parseLista<TurnoModel>(respuesta, TurnoModel.fromJson);
  }

  /// Turnos del vigilante en sesión, para la pantalla de historial.
  Future<List<TurnoModel>> obtenerMisTurnos() async {
    final List<TurnoModel> turnos = await obtenerTurnos();
    final int? usuarioId = _sesion.usuarioId;
    if (usuarioId == null) return turnos;
    return turnos.where((TurnoModel turno) => turno.usuarioId == usuarioId).toList();
  }

  /// Turno activo del vigilante en sesión, o `null` si no tiene ninguno.
  Future<TurnoModel?> obtenerTurnoActivo() async {
    final List<TurnoModel> turnos = await obtenerMisTurnos();
    for (final TurnoModel turno in turnos) {
      if (turno.estaActivo) return turno;
    }
    return null;
  }

  /// `true` si el vigilante tiene un turno abierto en este momento.
  Future<bool> tieneTurnoActivo() async {
    final TurnoModel? turno = await obtenerTurnoActivo();
    return turno != null;
  }

  /// Resumen completo del turno activo: entradas, salidas, ocupación,
  /// visitantes, novedades y actividad reciente.
  ///
  /// Lanza [NotFoundException] (404) cuando no hay turno abierto.
  Future<ResumenTurnoModel> obtenerResumenTurno() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.vigilante}/resumen-turno');
    return ResumenTurnoModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Igual que [obtenerResumenTurno] pero devuelve un resumen en ceros en
  /// lugar de lanzar excepción cuando no hay turno activo.
  Future<ResumenTurnoModel> obtenerResumenTurnoSeguro() async {
    try {
      return await obtenerResumenTurno();
    } on NotFoundException {
      return ResumenTurnoModel.vacio();
    }
  }
}
