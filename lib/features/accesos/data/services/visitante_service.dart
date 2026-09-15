import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/visitante_model.dart';

/// ParkLink - Servicio de registro de visitantes.
///
/// Endpoints cubiertos (Blueprint `vigilante_bp`):
/// - `POST /api/vigilante/visitantes`
/// - `GET  /api/vigilante/visitantes`
class VisitanteService {
  VisitanteService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Lista los visitantes registrados, del más reciente al más antiguo.
  Future<List<VisitanteModel>> obtenerVisitantes() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.vigilante}/visitantes');
    return JsonUtils.parseLista<VisitanteModel>(
      respuesta,
      VisitanteModel.fromJson,
    );
  }

  /// Registra un visitante en portería.
  ///
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> registrarVisitante({
    required String nombreCompleto,
    required String documento,
    required String placaVehiculo,
    required String areaVisitada,
    required String motivoVisita,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.vigilante}/visitantes',
      cuerpo: <String, dynamic>{
        'nombre_completo': nombreCompleto.trim(),
        'documento': documento.trim(),
        'placa_vehiculo': placaVehiculo.trim().toUpperCase(),
        'area_visitada': areaVisitada.trim(),
        'motivo_visita': motivoVisita.trim(),
      },
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['mensaje', 'message'],
      ),
      porDefecto: 'Visitante registrado correctamente',
    );
  }

  /// Variante que recibe un [VisitanteModel] ya construido.
  Future<String> registrarVisitanteDesdeModelo(VisitanteModel visitante) {
    return registrarVisitante(
      nombreCompleto: visitante.nombreCompleto,
      documento: visitante.documento,
      placaVehiculo: visitante.placaVehiculo,
      areaVisitada: visitante.areaVisitada,
      motivoVisita: visitante.motivoVisita,
    );
  }
}
