import '../../../../core/utils/json_utils.dart';

/// Resultado de registrar una entrada o una salida en portería.
///
/// Contratos:
/// - `POST /api/vigilante/entrada` -> `{"mensaje": "...", "celda": "A-01"}`
/// - `POST /api/vigilante/salida`  -> `{"mensaje": "...", "celda_liberada": "A-01"}`
/// - `POST /api/admin/registrar-acceso` -> `{"message": "...", "acceso_id": 12}`
class ResultadoMovimientoModel {
  /// Mensaje de confirmación devuelto por el servidor.
  final String mensaje;

  /// Celda asignada (entrada) o liberada (salida). `null` si no aplica.
  final String? celda;

  /// Identificador del acceso creado por `/api/admin/registrar-acceso`.
  final int? accesoId;

  /// `true` cuando el movimiento corresponde a una salida.
  final bool esSalida;

  const ResultadoMovimientoModel({
    required this.mensaje,
    this.celda,
    this.accesoId,
    this.esSalida = false,
  });

  factory ResultadoMovimientoModel.fromJson(
    Map<String, dynamic> json, {
    bool esSalida = false,
  }) {
    return ResultadoMovimientoModel(
      mensaje: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['mensaje', 'message']),
        porDefecto: esSalida
            ? 'Salida registrada correctamente'
            : 'Entrada registrada correctamente',
      ),
      celda: JsonUtils.parseStringOrNull(
        JsonUtils.primeraLlave(
          json,
          <String>['celda', 'celda_liberada', 'celda_asignada'],
        ),
      ),
      accesoId: JsonUtils.parseIntOrNull(json['acceso_id']),
      esSalida: esSalida,
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'mensaje': mensaje,
      'celda': celda,
      'acceso_id': accesoId,
    });
  }

  /// Celda lista para mostrar en pantalla.
  String get celdaTexto => celda ?? 'N/A';

  /// `true` si el servidor devolvió una celda concreta.
  bool get tieneCelda => celda != null && celda!.isNotEmpty;

  /// Texto completo para el SnackBar de confirmación.
  String get detalle {
    if (!tieneCelda) return mensaje;
    return esSalida
        ? '$mensaje (celda $celdaTexto liberada)'
        : '$mensaje (celda $celdaTexto asignada)';
  }

  @override
  String toString() => 'ResultadoMovimientoModel($mensaje, celda: $celdaTexto)';
}
