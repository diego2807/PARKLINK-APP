import '../../../../core/utils/json_utils.dart';

/// Niveles de la bitácora de auditoría.
enum NivelLog {
  informativo('informativo', 'Informativo'),
  advertencia('advertencia', 'Advertencia'),
  critico('critico', 'Crítico');

  const NivelLog(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static NivelLog desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final NivelLog nivel in NivelLog.values) {
      if (nivel.valor == texto) return nivel;
    }
    if (texto.contains('critic') || texto.contains('error')) {
      return NivelLog.critico;
    }
    if (texto.contains('advert') || texto.contains('warn')) {
      return NivelLog.advertencia;
    }
    return NivelLog.informativo;
  }

  /// Prioridad numérica para ordenar (mayor = más grave).
  int get prioridad {
    switch (this) {
      case NivelLog.informativo:
        return 0;
      case NivelLog.advertencia:
        return 1;
      case NivelLog.critico:
        return 2;
    }
  }
}

/// Registro de la bitácora de auditoría.
///
/// Contrato: `obtener_historial_logs()` en `app/routes/logs.py`
/// (`GET /api/admin/logs`).
///
/// ```json
/// {
///   "id": 33,
///   "fecha_hora": "2026-09-14 08:30:00",
///   "modulo": "Accesos",
///   "nivel": "informativo",
///   "descripcion": "Ingreso autorizado para Funcionario en la celda A-01.",
///   "usuario_id": 2,
///   "placa": "ABC123"
/// }
/// ```
///
/// El Back-End fuerza `nivel` a minúsculas y sustituye la placa nula por
/// `"N/A"`, marcador que este modelo normaliza a `null`.
class LogAuditoriaModel {
  final int id;
  final DateTime? fechaHora;

  /// Módulo que generó el evento: "Accesos", "Turnos", "Novedades"...
  final String modulo;

  final NivelLog nivel;
  final String descripcion;

  /// Usuario responsable. Es `nullable` en la tabla (`ondelete="SET NULL"`).
  final int? usuarioId;

  /// Placa relacionada. `null` cuando el servidor envió "N/A".
  final String? placa;

  const LogAuditoriaModel({
    required this.id,
    required this.modulo,
    required this.nivel,
    required this.descripcion,
    this.fechaHora,
    this.usuarioId,
    this.placa,
  });

  factory LogAuditoriaModel.fromJson(Map<String, dynamic> json) {
    return LogAuditoriaModel(
      id: JsonUtils.parseInt(json['id']),
      fechaHora: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(json, <String>['fecha_hora', 'fecha']),
      ),
      modulo: JsonUtils.parseString(json['modulo'], porDefecto: 'Sistema'),
      nivel: NivelLog.desdeTexto(json['nivel']),
      descripcion: JsonUtils.parseString(json['descripcion']),
      usuarioId: JsonUtils.parseIntOrNull(json['usuario_id']),
      placa: JsonUtils.parseStringOrNull(json['placa']),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'id': id,
      'fecha_hora':
          fechaHora == null ? null : JsonUtils.formatearFechaHora(fechaHora!),
      'modulo': modulo,
      'nivel': nivel.valor,
      'descripcion': descripcion,
      'usuario_id': usuarioId,
      'placa': placa,
    });
  }

  bool get esCritico => nivel == NivelLog.critico;
  bool get esAdvertencia => nivel == NivelLog.advertencia;
  bool get esInformativo => nivel == NivelLog.informativo;

  /// Etiqueta del nivel lista para badges.
  String get nivelTexto => nivel.etiqueta;

  /// Placa lista para mostrar; devuelve "N/A" cuando no aplica.
  String get placaTexto => placa ?? 'N/A';

  /// `true` si el evento tiene una placa asociada.
  bool get tienePlaca => placa != null && placa!.isNotEmpty;

  String get fechaTexto =>
      fechaHora == null ? 'Sin fecha' : JsonUtils.formatearFecha(fechaHora!);

  String get horaTexto =>
      fechaHora == null ? '--:--' : JsonUtils.formatearHora(fechaHora!);

  String get fechaHoraTexto => fechaHora == null
      ? 'Sin fecha'
      : JsonUtils.formatearFechaHora(fechaHora!);

  /// Antigüedad legible: "Hace 10 min", "Ayer", "Hace 3 días".
  String get tiempoRelativo {
    if (fechaHora == null) return 'Sin fecha';

    final Duration diferencia = DateTime.now().difference(fechaHora!);
    if (diferencia.isNegative) return 'Programado';
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
    if (fechaHora == null) return false;
    final DateTime ahora = DateTime.now();
    return fechaHora!.year == ahora.year &&
        fechaHora!.month == ahora.month &&
        fechaHora!.day == ahora.day;
  }

  /// Filtro local por severidad ("todos", "informativo", "advertencia",
  /// "critico"). El endpoint ya soporta este filtro por query param, pero
  /// tenerlo en el modelo permite refiltrar sin volver a llamar a la API.
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty ||
        limpio == 'todos' ||
        limpio == 'todas' ||
        limpio == 'todos los eventos') {
      return true;
    }
    return nivel.valor == limpio;
  }

  /// Búsqueda local por placa, módulo o descripción (mismo criterio que el
  /// `ilike` del Back-End).
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placaTexto.toLowerCase().contains(limpio) ||
        modulo.toLowerCase().contains(limpio) ||
        descripcion.toLowerCase().contains(limpio);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LogAuditoriaModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LogAuditoriaModel(id: $id, modulo: $modulo, nivel: ${nivel.valor})';
}
