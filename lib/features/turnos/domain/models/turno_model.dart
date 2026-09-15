import '../../../../core/utils/json_utils.dart';

/// Estados posibles de un turno de vigilancia.
enum EstadoTurno {
  activo('Activo'),
  cerrado('Cerrado');

  const EstadoTurno(this.valor);

  final String valor;

  static EstadoTurno desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    if (texto == 'cerrado') return EstadoTurno.cerrado;
    return EstadoTurno.activo;
  }
}

/// Jornadas de trabajo definidas en `app/models/turno.py`.
enum JornadaTurno {
  manana('Mañana', '06:00 - 14:00'),
  tarde('Tarde', '14:00 - 22:00'),
  noche('Noche', '22:00 - 06:00');

  const JornadaTurno(this.valor, this.horario);

  final String valor;
  final String horario;

  static JornadaTurno desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    if (texto.startsWith('tarde')) return JornadaTurno.tarde;
    if (texto.startsWith('noche')) return JornadaTurno.noche;
    return JornadaTurno.manana;
  }

  /// Etiqueta completa: "Mañana (06:00 - 14:00)".
  String get etiquetaCompleta => '$valor ($horario)';
}

/// Turno de vigilancia.
///
/// Contrato: `listar_turnos()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/turnos`).
///
/// ```json
/// { "id": 5, "usuario_id": 2, "jornada": "Mañana", "estado": "Activo" }
/// ```
///
/// Ojo: esta ruta devuelve una proyección reducida. Las fechas y los
/// acumulados existen en la tabla `turnos` pero no se serializan todavía,
/// por eso se modelan como opcionales.
class TurnoModel {
  final int id;
  final int usuarioId;
  final JornadaTurno jornada;
  final EstadoTurno estado;

  /// Campos presentes en la tabla pero no expuestos por el endpoint actual.
  /// Se mantienen opcionales para no romper si el Back-End los agrega.
  final DateTime? fechaApertura;
  final DateTime? fechaCierre;
  final int? totalEntradas;
  final int? totalSalidas;
  final int? totalVisitantes;
  final int? totalNovedades;
  final String? observacionesFinales;

  const TurnoModel({
    required this.id,
    required this.usuarioId,
    required this.jornada,
    required this.estado,
    this.fechaApertura,
    this.fechaCierre,
    this.totalEntradas,
    this.totalSalidas,
    this.totalVisitantes,
    this.totalNovedades,
    this.observacionesFinales,
  });

  factory TurnoModel.fromJson(Map<String, dynamic> json) {
    return TurnoModel(
      id: JsonUtils.parseInt(json['id']),
      usuarioId: JsonUtils.parseInt(json['usuario_id']),
      jornada: JornadaTurno.desdeTexto(json['jornada']),
      estado: EstadoTurno.desdeTexto(json['estado']),
      fechaApertura: JsonUtils.parseFecha(json['fecha_apertura']),
      fechaCierre: JsonUtils.parseFecha(json['fecha_cierre']),
      totalEntradas: JsonUtils.parseIntOrNull(json['total_entradas']),
      totalSalidas: JsonUtils.parseIntOrNull(json['total_salidas']),
      totalVisitantes: JsonUtils.parseIntOrNull(json['total_visitantes']),
      totalNovedades: JsonUtils.parseIntOrNull(json['total_novedades']),
      observacionesFinales:
          JsonUtils.parseStringOrNull(json['observaciones_finales']),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'id': id,
      'usuario_id': usuarioId,
      'jornada': jornada.valor,
      'estado': estado.valor,
      'fecha_apertura': fechaApertura == null
          ? null
          : JsonUtils.formatearFechaHora(fechaApertura!),
      'fecha_cierre': fechaCierre == null
          ? null
          : JsonUtils.formatearFechaHora(fechaCierre!),
      'total_entradas': totalEntradas,
      'total_salidas': totalSalidas,
      'total_visitantes': totalVisitantes,
      'total_novedades': totalNovedades,
      'observaciones_finales': observacionesFinales,
    });
  }

  bool get estaActivo => estado == EstadoTurno.activo;
  bool get estaCerrado => estado == EstadoTurno.cerrado;

  /// Etiqueta de jornada lista para mostrar: "Mañana (06:00 - 14:00)".
  String get jornadaTexto => jornada.etiquetaCompleta;

  /// Estado textual para badges.
  String get estadoTexto => estado.valor;

  String get fechaAperturaTexto => fechaApertura == null
      ? '--'
      : JsonUtils.formatearFechaHora(fechaApertura!);

  String get fechaCierreTexto => fechaCierre == null
      ? 'En curso'
      : JsonUtils.formatearFechaHora(fechaCierre!);

  /// Duración del turno. Si sigue abierto, mide hasta el momento actual.
  Duration? get duracion {
    if (fechaApertura == null) return null;
    final DateTime fin = fechaCierre ?? DateTime.now();
    final Duration diferencia = fin.difference(fechaApertura!);
    return diferencia.isNegative ? Duration.zero : diferencia;
  }

  /// Duración legible: "7h 45m".
  String get duracionTexto {
    final Duration? total = duracion;
    if (total == null) return '--';
    return '${total.inHours}h ${total.inMinutes.remainder(60)}m';
  }

  /// Suma de movimientos del turno, cuando el Back-End los expone.
  int get totalMovimientos => (totalEntradas ?? 0) + (totalSalidas ?? 0);

  TurnoModel copyWith({
    int? id,
    int? usuarioId,
    JornadaTurno? jornada,
    EstadoTurno? estado,
    DateTime? fechaApertura,
    DateTime? fechaCierre,
    int? totalEntradas,
    int? totalSalidas,
    int? totalVisitantes,
    int? totalNovedades,
    String? observacionesFinales,
  }) {
    return TurnoModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      jornada: jornada ?? this.jornada,
      estado: estado ?? this.estado,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      totalEntradas: totalEntradas ?? this.totalEntradas,
      totalSalidas: totalSalidas ?? this.totalSalidas,
      totalVisitantes: totalVisitantes ?? this.totalVisitantes,
      totalNovedades: totalNovedades ?? this.totalNovedades,
      observacionesFinales: observacionesFinales ?? this.observacionesFinales,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TurnoModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TurnoModel(id: $id, jornada: ${jornada.valor}, estado: ${estado.valor})';
}
