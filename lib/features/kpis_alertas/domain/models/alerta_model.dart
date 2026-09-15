import '../../../../core/utils/json_utils.dart';

/// Niveles de severidad de una alerta.
///
/// Espejo de los valores que el Back-End guarda en minúsculas en
/// `app/models/alertas.py`.
enum SeveridadAlerta {
  informativo('informativo', 'Informativo'),
  advertencia('advertencia', 'Advertencia'),
  urgente('urgente', 'Urgente');

  const SeveridadAlerta(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static SeveridadAlerta desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final SeveridadAlerta severidad in SeveridadAlerta.values) {
      if (severidad.valor == texto) return severidad;
    }
    if (texto.contains('urgen') || texto.contains('critic')) {
      return SeveridadAlerta.urgente;
    }
    if (texto.contains('advert') || texto.contains('warning')) {
      return SeveridadAlerta.advertencia;
    }
    return SeveridadAlerta.informativo;
  }

  /// Prioridad numérica para ordenar (mayor = más grave).
  int get prioridad {
    switch (this) {
      case SeveridadAlerta.informativo:
        return 0;
      case SeveridadAlerta.advertencia:
        return 1;
      case SeveridadAlerta.urgente:
        return 2;
    }
  }
}

/// Alerta o comunicado corporativo.
///
/// Contrato: `obtener_alertas()` en `app/routes/alertas.py`
/// (`GET /api/admin/alertas`).
///
/// ```json
/// {
///   "id": 4,
///   "titulo": "Mantenimiento Programado",
///   "severidad": "advertencia",
///   "contenido": "Sótano 1 cerrado mañana.",
///   "fecha_publicacion": "2026-09-14 09:00:00"
/// }
/// ```
class AlertaModel {
  final int id;
  final String titulo;
  final SeveridadAlerta severidad;
  final String contenido;
  final DateTime? fechaPublicacion;

  const AlertaModel({
    required this.id,
    required this.titulo,
    required this.severidad,
    required this.contenido,
    this.fechaPublicacion,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    return AlertaModel(
      id: JsonUtils.parseInt(json['id']),
      titulo: JsonUtils.parseString(json['titulo'], porDefecto: 'Comunicado'),
      severidad: SeveridadAlerta.desdeTexto(json['severidad']),
      contenido: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['contenido', 'mensaje']),
      ),
      fechaPublicacion: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(
          json,
          <String>['fecha_publicacion', 'fecha', 'fecha_hora'],
        ),
      ),
    );
  }

  /// Payload aceptado por `POST /api/admin/alertas`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'titulo': titulo.trim(),
      'severidad': severidad.valor,
      'contenido': contenido.trim(),
    };
  }

  bool get esUrgente => severidad == SeveridadAlerta.urgente;
  bool get esAdvertencia => severidad == SeveridadAlerta.advertencia;
  bool get esInformativa => severidad == SeveridadAlerta.informativo;

  /// Etiqueta de severidad lista para badges.
  String get severidadTexto => severidad.etiqueta;

  String get fechaTexto => fechaPublicacion == null
      ? 'Sin fecha'
      : JsonUtils.formatearFecha(fechaPublicacion!);

  String get horaTexto => fechaPublicacion == null
      ? '--:--'
      : JsonUtils.formatearHora(fechaPublicacion!);

  /// Antigüedad legible: "Hace 10 min", "Ayer", "Hace 3 días".
  String get tiempoRelativo {
    if (fechaPublicacion == null) return 'Sin fecha';

    final Duration diferencia = DateTime.now().difference(fechaPublicacion!);
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

  /// `true` si la alerta se publicó hoy.
  bool get esDeHoy {
    if (fechaPublicacion == null) return false;
    final DateTime ahora = DateTime.now();
    return fechaPublicacion!.year == ahora.year &&
        fechaPublicacion!.month == ahora.month &&
        fechaPublicacion!.day == ahora.day;
  }

  /// Filtros de `Alertas.dart`: "todas", "informativo", "advertencia",
  /// "urgente".
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todas' || limpio == 'todos') return true;
    return severidad.valor == limpio;
  }

  /// Búsqueda por título o contenido.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return titulo.toLowerCase().contains(limpio) ||
        contenido.toLowerCase().contains(limpio);
  }

  AlertaModel copyWith({
    int? id,
    String? titulo,
    SeveridadAlerta? severidad,
    String? contenido,
    DateTime? fechaPublicacion,
  }) {
    return AlertaModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      severidad: severidad ?? this.severidad,
      contenido: contenido ?? this.contenido,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AlertaModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AlertaModel(id: $id, titulo: $titulo, severidad: ${severidad.valor})';
}
