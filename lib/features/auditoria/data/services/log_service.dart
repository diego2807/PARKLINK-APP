import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/log_auditoria_model.dart';

/// ParkLink - Servicio de la bitácora de auditoría.
///
/// Endpoint cubierto (Blueprint `logs_bp`, prefijo `/api/admin`):
/// - `GET /api/admin/logs?termino=<texto>&severidad=<nivel>`
///
/// El filtrado ocurre del lado del servidor mediante `ilike`, por lo que la
/// búsqueda funciona letra por letra sobre placa, módulo y descripción.
class LogService {
  LogService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Obtiene la bitácora, opcionalmente filtrada.
  ///
  /// - [termino]: texto libre buscado en placa, módulo y descripción.
  /// - [severidad]: nivel exacto. Usa `null` o `'todos'` para no filtrar.
  Future<List<LogAuditoriaModel>> obtenerLogs({
    String? termino,
    NivelLog? severidad,
  }) async {
    final dynamic respuesta = await _cliente.get(
      '${ApiConfig.admin}/logs',
      parametros: <String, dynamic>{
        if (termino != null && termino.trim().isNotEmpty) 'termino': termino.trim(),
        'severidad': severidad?.valor ?? 'todos',
      },
    );

    return JsonUtils.parseLista<LogAuditoriaModel>(
      respuesta,
      LogAuditoriaModel.fromJson,
    );
  }

  /// Búsqueda directa por texto, sin filtro de severidad.
  Future<List<LogAuditoriaModel>> buscar(String termino) {
    return obtenerLogs(termino: termino);
  }

  /// Registros de un nivel concreto.
  Future<List<LogAuditoriaModel>> obtenerPorSeveridad(NivelLog severidad) {
    return obtenerLogs(severidad: severidad);
  }

  /// Últimos [limite] eventos de la bitácora (ya vienen ordenados de más
  /// reciente a más antiguo desde el servidor).
  Future<List<LogAuditoriaModel>> obtenerRecientes({int limite = 10}) async {
    final List<LogAuditoriaModel> logs = await obtenerLogs();
    if (logs.length <= limite) return logs;
    return logs.sublist(0, limite);
  }
}
