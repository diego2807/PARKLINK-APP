import '../../../../core/utils/json_utils.dart';

/// Novedad registrada por un vigilante.
///
/// Contrato: `listar_novedades()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/novedades`). Proviene de la tabla
/// `novedades_vigilante`.
///
/// ```json
/// { "id": 4, "descripcion": "Portón con retraso al cerrar", "fecha": "2026-09-14 09:15:00" }
/// ```
///
/// El registro (`POST /api/vigilante/novedades`) sólo acepta `descripcion`;
/// el `usuario_id` se toma del token JWT.
class NovedadModel {
  final int id;
  final String descripcion;
  final DateTime? fecha;

  const NovedadModel({
    required this.id,
    required this.descripcion,
    this.fecha,
  });

  factory NovedadModel.fromJson(Map<String, dynamic> json) {
    return NovedadModel(
      id: JsonUtils.parseInt(json['id']),
      descripcion: JsonUtils.parseString(json['descripcion']),
      fecha: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(json, <String>['fecha', 'fecha_hora']),
      ),
    );
  }

  /// Payload aceptado por `POST /api/vigilante/novedades`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'descripcion': descripcion.trim()};
  }

  /// Payload completo, útil para caché local.
  Map<String, dynamic> toJsonCompleto() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'id': id,
      'descripcion': descripcion,
      'fecha': fecha == null ? null : JsonUtils.formatearFechaHora(fecha!),
    });
  }

  String get fechaTexto =>
      fecha == null ? 'Sin fecha' : JsonUtils.formatearFecha(fecha!);

  String get horaTexto =>
      fecha == null ? '--:--' : JsonUtils.formatearHora(fecha!);

  /// Hora en formato de 12 horas: "09:15 AM".
  String get horaAmPm {
    if (fecha == null) return '--:--';
    final int hora24 = fecha!.hour;
    final int hora12 = hora24 % 12 == 0 ? 12 : hora24 % 12;
    final String minuto = fecha!.minute.toString().padLeft(2, '0');
    final String periodo = hora24 < 12 ? 'AM' : 'PM';
    return '${hora12.toString().padLeft(2, '0')}:$minuto $periodo';
  }

  /// Antigüedad legible: "Hace 10 min", "Ayer", "Hace 3 días".
  String get tiempoRelativo {
    if (fecha == null) return 'Sin fecha';

    final Duration diferencia = DateTime.now().difference(fecha!);
    if (diferencia.isNegative) return 'Programada';
    if (diferencia.inMinutes < 1) return 'Hace un momento';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} ${diferencia.inHours == 1 ? 'hora' : 'horas'}';
    }
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 30) return 'Hace ${diferencia.inDays} días';
    return fechaTexto;
  }

  bool get esDeHoy {
    if (fecha == null) return false;
    final DateTime ahora = DateTime.now();
    return fecha!.year == ahora.year &&
        fecha!.month == ahora.month &&
        fecha!.day == ahora.day;
  }

  /// Búsqueda por descripción.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return descripcion.toLowerCase().contains(limpio);
  }

  NovedadModel copyWith({
    int? id,
    String? descripcion,
    DateTime? fecha,
  }) {
    return NovedadModel(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NovedadModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NovedadModel(id: $id, fecha: $fechaTexto)';
}
