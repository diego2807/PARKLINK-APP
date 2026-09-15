import '../../../../core/utils/json_utils.dart';

/// Línea de la actividad reciente del panel del usuario.
///
/// Contrato: llave `actividad` de `panel()` en `app/routes/usuario.py`
/// (`GET /api/usuario/panel`).
///
/// ```json
/// { "hora": "08:30", "evento": "Entrada - ABC123", "estado": "Correcto" }
/// ```
class ActividadRecienteModel {
  /// Hora en formato `HH:mm`.
  final String hora;

  /// Descripción del evento: "Entrada - ABC123".
  final String evento;

  /// Estado del evento. El Back-End envía siempre "Correcto".
  final String estado;

  const ActividadRecienteModel({
    required this.hora,
    required this.evento,
    required this.estado,
  });

  factory ActividadRecienteModel.fromJson(Map<String, dynamic> json) {
    return ActividadRecienteModel(
      hora: JsonUtils.parseString(json['hora'], porDefecto: '--:--'),
      evento: JsonUtils.parseString(json['evento']),
      estado: JsonUtils.parseString(json['estado'], porDefecto: 'Correcto'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hora': hora,
      'evento': evento,
      'estado': estado,
    };
  }

  /// Tipo de movimiento extraído de [evento] ("Entrada - ABC123" -> "Entrada").
  String get movimiento {
    final int separador = evento.indexOf('-');
    if (separador <= 0) return evento.trim();
    return evento.substring(0, separador).trim();
  }

  /// Placa extraída de [evento] ("Entrada - ABC123" -> "ABC123").
  String get placa {
    final int separador = evento.indexOf('-');
    if (separador < 0 || separador + 1 >= evento.length) return '';
    return evento.substring(separador + 1).trim().toUpperCase();
  }

  bool get esEntrada => movimiento.toLowerCase() == 'entrada';
  bool get esSalida => movimiento.toLowerCase() == 'salida';

  /// `true` cuando el evento no presentó incidencias.
  bool get esCorrecto => estado.toLowerCase() == 'correcto';

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
  String toString() => 'ActividadRecienteModel($hora - $evento)';
}
