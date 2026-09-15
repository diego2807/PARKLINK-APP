import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/celda_model.dart';
import '../../domain/models/resumen_zona_model.dart';
import '../../domain/models/validacion_cupo_model.dart';

/// ParkLink - Servicio del mapa y la gestión de celdas.
///
/// Endpoints cubiertos:
/// - `GET  /api/admin/celdas`                 (mapa completo)
/// - `POST /api/admin/celdas`                 (alta de celda)
/// - `PUT  /api/admin/celdas/<id>/estado`     (ocupar / liberar)
/// - `POST /api/admin/ingresos/validar-cupo`  (validación de cupo por perfil)
class CeldaService {
  CeldaService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Obtiene todas las celdas ordenadas por código.
  Future<List<CeldaModel>> obtenerCeldas() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.admin}/celdas');
    return JsonUtils.parseLista<CeldaModel>(respuesta, CeldaModel.fromJson);
  }

  /// Obtiene las celdas ya agrupadas por zona, listas para el semáforo
  /// y el panel de control.
  Future<List<ResumenZonaModel>> obtenerResumenPorZona() async {
    final List<CeldaModel> celdas = await obtenerCeldas();
    return ResumenZonaModel.agrupar(celdas);
  }

  /// Sólo las celdas libres.
  Future<List<CeldaModel>> obtenerCeldasDisponibles() async {
    final List<CeldaModel> celdas = await obtenerCeldas();
    return celdas.where((CeldaModel celda) => celda.disponible).toList();
  }

  /// Registra una nueva celda en el sistema.
  ///
  /// Lanza [BadRequestException] (400) si el código ya existe o si falta
  /// alguno de los dos campos obligatorios.
  Future<CeldaModel> registrarCelda({
    required String codigoCelda,
    required String tipoCelda,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.admin}/celdas',
      cuerpo: <String, dynamic>{
        'codigo_celda': codigoCelda.trim().toUpperCase(),
        'tipo_celda': tipoCelda.trim().toLowerCase(),
      },
    );

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
    final Map<String, dynamic> celdaJson = JsonUtils.parseMapa(mapa['celda']);

    // La respuesta de creación no incluye `ocupada`: toda celda nueva
    // nace disponible según `registrar_celda()` en el Back-End.
    return CeldaModel.fromJson(<String, dynamic>{
      ...celdaJson,
      'ocupada': celdaJson['ocupada'] ?? false,
    });
  }

  /// Cambia el estado de ocupación de una celda.
  ///
  /// Devuelve la celda actualizada. La respuesta del Back-End sólo incluye
  /// `id`, `codigo_celda` y `ocupada`, por lo que [tipoCelda] puede pasarse
  /// para conservar el tipo en el modelo resultante.
  ///
  /// Lanza [NotFoundException] (404) si la celda no existe.
  Future<CeldaModel> cambiarEstadoCelda({
    required int celdaId,
    required bool ocupada,
    String tipoCelda = 'operativas',
  }) async {
    final dynamic respuesta = await _cliente.put(
      '${ApiConfig.admin}/celdas/$celdaId/estado',
      cuerpo: <String, dynamic>{'ocupada': ocupada},
    );

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
    final Map<String, dynamic> celdaJson = JsonUtils.parseMapa(mapa['celda']);

    return CeldaModel.fromJson(<String, dynamic>{
      ...celdaJson,
      'tipo_celda': celdaJson['tipo_celda'] ?? tipoCelda,
    });
  }

  /// Atajo para liberar una celda.
  Future<CeldaModel> liberarCelda(int celdaId, {String tipoCelda = 'operativas'}) {
    return cambiarEstadoCelda(
      celdaId: celdaId,
      ocupada: false,
      tipoCelda: tipoCelda,
    );
  }

  /// Atajo para ocupar/bloquear una celda manualmente.
  Future<CeldaModel> ocuparCelda(int celdaId, {String tipoCelda = 'operativas'}) {
    return cambiarEstadoCelda(
      celdaId: celdaId,
      ocupada: true,
      tipoCelda: tipoCelda,
    );
  }

  /// Verifica si queda cupo para el perfil indicado antes de autorizar
  /// un ingreso.
  ///
  /// Un 403 del servidor significa "cupos agotados", no un error de
  /// permisos, por lo que se traduce a un resultado con `autorizado = false`.
  Future<ValidacionCupoModel> validarCupo(PerfilCupo perfil) async {
    try {
      final dynamic respuesta = await _cliente.post(
        '${ApiConfig.admin}/ingresos/validar-cupo',
        cuerpo: <String, dynamic>{'tipo_usuario': perfil.valor},
      );
      return ValidacionCupoModel.fromJson(
        JsonUtils.parseMapa(respuesta),
        perfil: perfil,
      );
    } on ForbiddenException catch (e) {
      return ValidacionCupoModel(
        status: 'denegado',
        mensaje: e.mensaje,
        perfil: perfil,
      );
    }
  }
}
