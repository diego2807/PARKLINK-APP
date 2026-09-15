import '../../../../core/utils/json_utils.dart';

/// Resultado de abrir o cerrar un turno.
///
/// Contratos:
/// - `POST /api/vigilante/apertura-turno` -> 201 `{"mensaje": "..."}`
/// - `POST /api/vigilante/cierre-turno`   -> 200 `{"mensaje": "..."}`
///                                           404 `{"error": "..."}`
///
/// Importante: la apertura devuelve 201 incluso cuando ya existía un turno
/// activo, distinguiéndolo únicamente por el texto del mensaje. Por eso el
/// modelo expone [yaExistiaTurno], para que la UI no muestre un falso éxito.
class ResultadoTurnoModel {
  /// Mensaje devuelto por el servidor.
  final String mensaje;

  /// `true` cuando el servidor informó que ya había un turno abierto.
  final bool yaExistiaTurno;

  const ResultadoTurnoModel({
    required this.mensaje,
    this.yaExistiaTurno = false,
  });

  factory ResultadoTurnoModel.fromJson(Map<String, dynamic> json) {
    final String mensaje = JsonUtils.parseString(
      JsonUtils.primeraLlave(json, <String>['mensaje', 'message']),
      porDefecto: 'Operación completada.',
    );

    final String normalizado = mensaje.toLowerCase();
    final bool yaExistia =
        normalizado.contains('ya existe') && normalizado.contains('turno');

    return ResultadoTurnoModel(
      mensaje: mensaje,
      yaExistiaTurno: yaExistia,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'mensaje': mensaje};

  /// `true` cuando la operación cambió realmente el estado del turno.
  bool get exitoso => !yaExistiaTurno;

  @override
  String toString() =>
      'ResultadoTurnoModel($mensaje, yaExistia: $yaExistiaTurno)';
}
