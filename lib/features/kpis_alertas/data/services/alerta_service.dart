import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/alerta_model.dart';

/// ParkLink - Servicio de alertas y comunicados.
///
/// Endpoints cubiertos (Blueprint `alertas_bp`, prefijo `/api/admin`):
/// - `GET    /api/admin/alertas`
/// - `POST   /api/admin/alertas`
/// - `DELETE /api/admin/alertas/<id>`
class AlertaService {
  AlertaService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Lista las alertas de la más reciente a la más antigua.
  Future<List<AlertaModel>> obtenerAlertas() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.admin}/alertas');
    return JsonUtils.parseLista<AlertaModel>(respuesta, AlertaModel.fromJson);
  }

  /// Lista sólo las alertas de una severidad concreta (filtrado en cliente,
  /// porque el endpoint no acepta parámetros de consulta).
  Future<List<AlertaModel>> obtenerAlertasPorSeveridad(
    SeveridadAlerta severidad,
  ) async {
    final List<AlertaModel> alertas = await obtenerAlertas();
    return alertas
        .where((AlertaModel alerta) => alerta.severidad == severidad)
        .toList();
  }

  /// Publica un nuevo comunicado.
  ///
  /// El Back-End sólo devuelve `{"message": "..."}`, sin el objeto creado.
  /// Lanza BadRequestException (400) si falta el título o el contenido.
  Future<String> publicarAlerta({
    required String titulo,
    required String contenido,
    SeveridadAlerta severidad = SeveridadAlerta.informativo,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.admin}/alertas',
      cuerpo: <String, dynamic>{
        'titulo': titulo.trim(),
        'severidad': severidad.valor,
        'contenido': contenido.trim(),
      },
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['message', 'mensaje'],
      ),
      porDefecto: 'Comunicado publicado con éxito.',
    );
  }

  /// Variante que recibe un [AlertaModel] ya construido.
  Future<String> publicarAlertaDesdeModelo(AlertaModel alerta) {
    return publicarAlerta(
      titulo: alerta.titulo,
      contenido: alerta.contenido,
      severidad: alerta.severidad,
    );
  }

  /// Descarta una alerta del panel.
  ///
  /// Lanza NotFoundException (404) si la alerta ya no existe.
  Future<String> eliminarAlerta(int alertaId) async {
    final dynamic respuesta =
        await _cliente.delete('${ApiConfig.admin}/alertas/$alertaId');

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['message', 'mensaje'],
      ),
      porDefecto: 'La alerta ha sido descartada con éxito.',
    );
  }
}
