import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/kpi_model.dart';
import '../../domain/models/kpi_ocupacion_model.dart';

/// ParkLink - Servicio de indicadores del panel de control.
///
/// Endpoints cubiertos:
/// - `GET /api/admin/kpis`           (métricas + tabla de vehículos activos)
/// - `GET /api/admin/kpis-ocupacion` (ocupación global y por perfil)
///
/// Nota sobre `/api/admin/kpis`: la URL está registrada por dos Blueprints
/// (`admin_bp` y `kpis_bp`) con respuestas de forma distinta. [KpiModel]
/// interpreta ambas, de modo que este servicio funciona sin importar cuál
/// atienda la petición.
class KpiService {
  KpiService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Métricas principales del dashboard y listado de vehículos activos.
  Future<KpiModel> obtenerKpis() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.admin}/kpis');
    return KpiModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Ocupación global y desglosada por perfil (administrativo, operativo
  /// y movilidad reducida).
  Future<KpiOcupacionModel> obtenerOcupacion() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.admin}/kpis-ocupacion');
    return KpiOcupacionModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Carga ambos indicadores en paralelo, para pintar el dashboard completo
  /// con una sola espera.
  Future<({KpiModel kpis, KpiOcupacionModel ocupacion})> obtenerDashboard() async {
    final List<dynamic> resultados = await Future.wait(<Future<dynamic>>[
      obtenerKpis(),
      obtenerOcupacion(),
    ]);

    return (
      kpis: resultados[0] as KpiModel,
      ocupacion: resultados[1] as KpiOcupacionModel,
    );
  }
}
