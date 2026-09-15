import '../../../../core/utils/json_utils.dart';

/// Rangos aceptados por `GET /api/admin/tendencias?rango=`.
enum RangoTendencia {
  hoy('hoy', 'Hoy'),
  semana('semana', 'Última semana'),
  mes('mes', 'Último mes');

  const RangoTendencia(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static RangoTendencia desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final RangoTendencia rango in RangoTendencia.values) {
      if (rango.valor == texto) return rango;
    }
    return RangoTendencia.semana;
  }
}

/// Ingresos acumulados por día de la semana.
///
/// Contrato: cada elemento de `dias_pico`.
/// ```json
/// { "dia": "Lunes", "ingresos": 12 }
/// ```
class DiaPicoModel {
  final String dia;
  final int ingresos;

  const DiaPicoModel({
    required this.dia,
    required this.ingresos,
  });

  factory DiaPicoModel.fromJson(Map<String, dynamic> json) {
    return DiaPicoModel(
      dia: JsonUtils.parseString(json['dia']),
      ingresos: JsonUtils.parseInt(json['ingresos']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'dia': dia, 'ingresos': ingresos};
  }

  /// Abreviatura de tres letras para los ejes de las gráficas: "Lun".
  String get diaCorto => dia.length <= 3 ? dia : dia.substring(0, 3);

  /// Altura relativa (0.0-1.0) respecto al [maximo] de la serie.
  double alturaRelativa(int maximo) {
    if (maximo <= 0) return 0;
    return (ingresos / maximo).clamp(0.0, 1.0);
  }

  @override
  String toString() => 'DiaPicoModel($dia: $ingresos)';
}

/// Flujo de vehículos por franja horaria.
///
/// Contrato: cada elemento de `horas_pico`.
/// ```json
/// { "hora": "06:00 - 11:59 (Mañana)", "flujo": "12 Ingresos" }
/// ```
///
/// `flujo` es texto libre: puede ser "N Ingresos" o "Flujo Estable".
class HoraPicoModel {
  /// Etiqueta completa de la franja.
  final String hora;

  /// Descripción del flujo tal como la envía el servidor.
  final String flujo;

  const HoraPicoModel({
    required this.hora,
    required this.flujo,
  });

  factory HoraPicoModel.fromJson(Map<String, dynamic> json) {
    return HoraPicoModel(
      hora: JsonUtils.parseString(json['hora']),
      flujo: JsonUtils.parseString(json['flujo'], porDefecto: 'Flujo Estable'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'hora': hora, 'flujo': flujo};
  }

  /// Extrae el número de ingresos del texto de [flujo]. Devuelve 0 cuando
  /// el servidor envió "Flujo Estable".
  int get cantidadIngresos {
    final RegExpMatch? coincidencia = RegExp(r'(\d+)').firstMatch(flujo);
    if (coincidencia == null) return 0;
    return int.tryParse(coincidencia.group(1)!) ?? 0;
  }

  /// `true` cuando no hubo movimiento registrado en la franja.
  bool get esFlujoEstable => cantidadIngresos == 0;

  /// Rango horario sin la etiqueta descriptiva: "06:00 - 11:59".
  String get rangoHorario {
    final int parentesis = hora.indexOf('(');
    if (parentesis <= 0) return hora.trim();
    return hora.substring(0, parentesis).trim();
  }

  /// Nombre de la franja: "Mañana", "Mediodía", "Tarde / Salida", "Nocturno".
  String get nombreFranja {
    final int inicio = hora.indexOf('(');
    final int fin = hora.indexOf(')');
    if (inicio < 0 || fin <= inicio) return hora.trim();
    return hora.substring(inicio + 1, fin).trim();
  }

  @override
  String toString() => 'HoraPicoModel($hora: $flujo)';
}

/// Métricas derivadas del análisis de tendencias.
///
/// Contrato: `metricas_prediccion`.
/// ```json
/// { "tiempo_promedio": "4.8 Horas", "perfil_predominante": "Personal Corporativo" }
/// ```
class MetricasPrediccionModel {
  /// Texto ya formateado por el servidor, p. ej. "4.8 Horas".
  final String tiempoPromedio;

  final String perfilPredominante;

  const MetricasPrediccionModel({
    required this.tiempoPromedio,
    required this.perfilPredominante,
  });

  factory MetricasPrediccionModel.fromJson(Map<String, dynamic> json) {
    return MetricasPrediccionModel(
      tiempoPromedio:
          JsonUtils.parseString(json['tiempo_promedio'], porDefecto: '0 Horas'),
      perfilPredominante: JsonUtils.parseString(
        json['perfil_predominante'],
        porDefecto: 'Personal Corporativo',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tiempo_promedio': tiempoPromedio,
      'perfil_predominante': perfilPredominante,
    };
  }

  /// Valor numérico extraído de [tiempoPromedio] ("4.8 Horas" -> 4.8).
  double get horasPromedio {
    final RegExpMatch? coincidencia =
        RegExp(r'(\d+([.,]\d+)?)').firstMatch(tiempoPromedio);
    if (coincidencia == null) return 0;
    return double.tryParse(coincidencia.group(1)!.replaceAll(',', '.')) ?? 0;
  }

  @override
  String toString() =>
      'MetricasPrediccionModel($tiempoPromedio, $perfilPredominante)';
}

/// Respuesta completa de `GET /api/admin/tendencias`.
///
/// Contrato: `obtener_tendencias_parqueo_reales()` en
/// `app/routes/tendencias.py`.
///
/// ```json
/// {
///   "status": "success",
///   "dias_pico": [ { "dia": "Lunes", "ingresos": 12 }, ... ],
///   "horas_pico": [ { "hora": "...", "flujo": "..." }, ... ],
///   "metricas_prediccion": { "tiempo_promedio": "...", "perfil_predominante": "..." }
/// }
/// ```
class TendenciaModel {
  final String status;
  final List<DiaPicoModel> diasPico;
  final List<HoraPicoModel> horasPico;
  final MetricasPrediccionModel metricasPrediccion;

  const TendenciaModel({
    required this.status,
    required this.diasPico,
    required this.horasPico,
    required this.metricasPrediccion,
  });

  factory TendenciaModel.fromJson(Map<String, dynamic> json) {
    return TendenciaModel(
      status: JsonUtils.parseString(json['status'], porDefecto: 'success'),
      diasPico: JsonUtils.parseLista<DiaPicoModel>(
        json['dias_pico'],
        DiaPicoModel.fromJson,
      ),
      horasPico: JsonUtils.parseLista<HoraPicoModel>(
        json['horas_pico'],
        HoraPicoModel.fromJson,
      ),
      metricasPrediccion: MetricasPrediccionModel.fromJson(
        JsonUtils.parseMapa(json['metricas_prediccion']),
      ),
    );
  }

  /// Instancia vacía para el estado inicial de las pantallas.
  factory TendenciaModel.vacio() {
    return const TendenciaModel(
      status: 'success',
      diasPico: <DiaPicoModel>[],
      horasPico: <HoraPicoModel>[],
      metricasPrediccion: MetricasPrediccionModel(
        tiempoPromedio: '0 Horas',
        perfilPredominante: 'Personal Corporativo',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'dias_pico': diasPico.map((DiaPicoModel d) => d.toJson()).toList(),
      'horas_pico': horasPico.map((HoraPicoModel h) => h.toJson()).toList(),
      'metricas_prediccion': metricasPrediccion.toJson(),
    };
  }

  bool get exitoso => status.toLowerCase() == 'success';

  /// Total de ingresos del periodo analizado.
  int get totalIngresos =>
      diasPico.fold<int>(0, (int suma, DiaPicoModel dia) => suma + dia.ingresos);

  /// Mayor cantidad de ingresos en un solo día (para escalar las gráficas).
  int get maximoIngresosDia {
    if (diasPico.isEmpty) return 0;
    return diasPico
        .map((DiaPicoModel dia) => dia.ingresos)
        .reduce((int a, int b) => a > b ? a : b);
  }

  /// Día con mayor afluencia. `null` si no hay datos.
  DiaPicoModel? get diaMasConcurrido {
    if (diasPico.isEmpty) return null;
    return diasPico.reduce(
      (DiaPicoModel a, DiaPicoModel b) => a.ingresos >= b.ingresos ? a : b,
    );
  }

  /// Franja horaria con mayor flujo. `null` si no hay datos.
  HoraPicoModel? get franjaMasConcurrida {
    if (horasPico.isEmpty) return null;
    return horasPico.reduce(
      (HoraPicoModel a, HoraPicoModel b) =>
          a.cantidadIngresos >= b.cantidadIngresos ? a : b,
    );
  }

  /// `true` cuando no hubo ningún movimiento en el rango consultado.
  bool get sinDatos => totalIngresos == 0;

  @override
  String toString() =>
      'TendenciaModel(status: $status, totalIngresos: $totalIngresos)';
}
