import '../../../../core/utils/json_utils.dart';

/// Movimiento registrado dentro del turno activo del vigilante.
///
/// Contrato: `historial_turno()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/historial-turno`).
///
/// ```json
/// {
///   "id": 8,
///   "placa": "ABC123",
///   "movimiento": "Entrada",
///   "celda": "A-01",
///   "fecha_hora": "2026-09-14 08:30:00"
/// }
/// ```
///
/// A diferencia de `/api/admin/historial`, esta ruta usa las llaves
/// `movimiento` y `celda`.
class MovimientoTurnoModel {
  final int id;
  final String placa;

  /// "Entrada" o "Salida".
  final String movimiento;

  /// Código de la celda involucrada.
  final String? celda;

  final DateTime? fechaHora;

  const MovimientoTurnoModel({
    required this.id,
    required this.placa,
    required this.movimiento,
    this.celda,
    this.fechaHora,
  });

  factory MovimientoTurnoModel.fromJson(Map<String, dynamic> json) {
    return MovimientoTurnoModel(
      id: JsonUtils.parseInt(json['id']),
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      movimiento: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['movimiento', 'tipo_movimiento']),
        porDefecto: 'Entrada',
      ),
      celda: JsonUtils.parseStringOrNull(
        JsonUtils.primeraLlave(json, <String>['celda', 'celda_asignada']),
      ),
      fechaHora: JsonUtils.parseFecha(json['fecha_hora']),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'id': id,
      'placa': placa,
      'movimiento': movimiento,
      'celda': celda,
      'fecha_hora':
          fechaHora == null ? null : JsonUtils.formatearFechaHora(fechaHora!),
    });
  }

  bool get esEntrada => movimiento.toLowerCase().trim() == 'entrada';
  bool get esSalida => movimiento.toLowerCase().trim() == 'salida';

  String get celdaTexto => celda ?? 'N/A';

  String get horaTexto =>
      fechaHora == null ? '--:--' : JsonUtils.formatearHora(fechaHora!);

  String get fechaTexto =>
      fechaHora == null ? '' : JsonUtils.formatearFecha(fechaHora!);

  /// Hora en formato de 12 horas: "08:30 AM".
  String get horaAmPm {
    if (fechaHora == null) return '--:--';
    final int hora24 = fechaHora!.hour;
    final int hora12 = hora24 % 12 == 0 ? 12 : hora24 % 12;
    final String minuto = fechaHora!.minute.toString().padLeft(2, '0');
    final String periodo = hora24 < 12 ? 'AM' : 'PM';
    return '${hora12.toString().padLeft(2, '0')}:$minuto $periodo';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MovimientoTurnoModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MovimientoTurnoModel(placa: $placa, movimiento: $movimiento)';
}
