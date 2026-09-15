import '../../../../core/utils/json_utils.dart';

/// Notificación mostrada al usuario final.
///
/// Contrato: `obtener_notificaciones()` en `app/services/usuario_service.py`
/// (`GET /api/usuario/notificaciones`). Proviene de la tabla
/// `novedades_vigilante`.
///
/// ```json
/// {
///   "id": 7,
///   "descripcion": "Portón automático con retraso al cerrar",
///   "fecha": "14/09/2026 09:15"
/// }
/// ```
///
/// Ojo: esta ruta usa el formato `dd/MM/yyyy HH:mm`, distinto al resto de
/// la API. [JsonUtils.parseFecha] lo contempla explícitamente.
class NotificacionModel {
  final int id;
  final String descripcion;
  final DateTime? fecha;

  /// Estado local de lectura. El Back-End no persiste este dato todavía,
  /// por lo que se maneja en memoria desde la UI mediante [copyWith].
  final bool leida;

  const NotificacionModel({
    required this.id,
    required this.descripcion,
    this.fecha,
    this.leida = false,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: JsonUtils.parseInt(json['id']),
      descripcion: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['descripcion', 'mensaje']),
      ),
      fecha: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(json, <String>['fecha', 'fecha_hora']),
      ),
      leida: JsonUtils.parseBool(json['leida']),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'id': id,
      'descripcion': descripcion,
      'fecha': fecha == null ? null : JsonUtils.formatearFechaHora(fecha!),
      'leida': leida,
    });
  }

  /// Título corto derivado de la descripción (primera oración, máx. 40
  /// caracteres), para encabezar la tarjeta de notificación.
  String get titulo {
    final String limpio = descripcion.trim();
    if (limpio.isEmpty) return 'Novedad del parqueadero';

    final int fin = limpio.indexOf('.');
    final String base = fin > 0 ? limpio.substring(0, fin) : limpio;
    if (base.length <= 40) return base;
    return '${base.substring(0, 40).trimRight()}...';
  }

  String get fechaTexto =>
      fecha == null ? 'Sin fecha' : JsonUtils.formatearFecha(fecha!);

  String get horaTexto =>
      fecha == null ? '--:--' : JsonUtils.formatearHora(fecha!);

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

  NotificacionModel copyWith({
    int? id,
    String? descripcion,
    DateTime? fecha,
    bool? leida,
  }) {
    return NotificacionModel(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      leida: leida ?? this.leida,
    );
  }

  /// Devuelve una copia marcada como leída.
  NotificacionModel marcarComoLeida() => copyWith(leida: true);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NotificacionModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NotificacionModel(id: $id, leida: $leida)';
}
