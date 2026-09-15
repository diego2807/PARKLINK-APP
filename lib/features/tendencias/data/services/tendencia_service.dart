import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/tendencia_model.dart';

/// ParkLink - Servicio de analítica de tendencias.
///
/// Endpoint cubierto (Blueprint `tendencias_bp`, prefijo `/api/admin`):
/// - `GET /api/admin/tendencias?rango=hoy|semana|mes`
///
/// El servidor asume `semana` cuando el parámetro no llega o no es válido.
class TendenciaService {
  TendenciaService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Obtiene los días pico, las franjas horarias y las métricas de predicción
  /// del rango indicado.
  Future<TendenciaModel> obtenerTendencias({
    RangoTendencia rango = RangoTendencia.semana,
  }) async {
    final dynamic respuesta = await _cliente.get(
      '${ApiConfig.admin}/tendencias',
      parametros: <String, dynamic>{'rango': rango.valor},
    );
    return TendenciaModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Atajo para el rango "hoy".
  Future<TendenciaModel> obtenerTendenciasDeHoy() =>
      obtenerTendencias(rango: RangoTendencia.hoy);

  /// Atajo para el rango "semana".
  Future<TendenciaModel> obtenerTendenciasDeLaSemana() =>
      obtenerTendencias(rango: RangoTendencia.semana);

  /// Atajo para el rango "mes".
  Future<TendenciaModel> obtenerTendenciasDelMes() =>
      obtenerTendencias(rango: RangoTendencia.mes);
}
