import '../../../../core/utils/json_utils.dart';

/// Línea de la actividad reciente del turno.
///
/// Contrato: llave `actividad` de `resumen_turno()` en
/// `app/services/vigilante_service.py` (`GET /api/vigilante/resumen-turno`).
///
/// ```json
/// { "placa": "ABC123", "movimiento": "Entrada", "hora": "08:30", "celda": "A-01" }
/// ```
class ActividadTurnoModel {
  final String placa;

  /// "Entrada" o "Salida".
  final String movimiento;

  /// Hora en formato `HH:mm` tal como la envía el servidor.
  final String hora;

  /// Celda involucrada. `null` cuando el movimiento no tenía celda.
  final String? celda;

  const ActividadTurnoModel({
    required this.placa,
    required this.movimiento,
    required this.hora,
    this.celda,
  });

  factory ActividadTurnoModel.fromJson(Map<String, dynamic> json) {
    return ActividadTurnoModel(
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      movimiento: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['movimiento', 'tipo_movimiento']),
        porDefecto: 'Entrada',
      ),
      hora: JsonUtils.parseString(json['hora'], porDefecto: '--:--'),
      celda: JsonUtils.parseStringOrNull(
        JsonUtils.primeraLlave(json, <String>['celda', 'celda_asignada']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'placa': placa,
      'movimiento': movimiento,
      'hora': hora,
      'celda': celda,
    });
  }

  bool get esEntrada => movimiento.toLowerCase().trim() == 'entrada';
  bool get esSalida => movimiento.toLowerCase().trim() == 'salida';

  String get celdaTexto => celda ?? 'N/A';

  /// Descripción lista para la lista de actividad: "Entrada - ABC123".
  String get evento => '$movimiento - $placa';

  /// Estado que la UI muestra junto a cada evento.
  String get estado => 'Correcto';

  /// Hora en formato de 12 horas: "08:30 AM".
  String get horaAmPm {
    final int? minutosTotales = JsonUtils.parseHoraEnMinutos(hora);
    if (minutosTotales == null) return hora;
    final int hora24 = minutosTotales ~/ 60;
    final int minuto = minutosTotales % 60;
    final int hora12 = hora24 % 12 == 0 ? 12 : hora24 % 12;
    final String periodo = hora24 < 12 ? 'AM' : 'PM';
    return '${hora12.toString().padLeft(2, '0')}:'
        '${minuto.toString().padLeft(2, '0')} $periodo';
  }

  @override
  String toString() => 'ActividadTurnoModel($evento a las $hora)';
}
