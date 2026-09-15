import '../../../../core/utils/json_utils.dart';

/// Detalle de ocupación de un perfil concreto.
///
/// Contrato: cada entrada de `detalles_por_perfil` en
/// `GET /api/admin/kpis-ocupacion`.
///
/// ```json
/// { "dentro": 15, "maximo": 40, "porcentaje": 37.5 }
/// ```
class DetallePerfilOcupacion {
  /// Nombre del perfil: "administrativo", "operativo" o "movilidad".
  final String perfil;

  /// Vehículos de ese perfil actualmente dentro.
  final int dentro;

  /// Cupo máximo configurado para el perfil.
  final int maximo;

  /// Porcentaje de uso de 0 a 100.
  final double porcentaje;

  const DetallePerfilOcupacion({
    required this.perfil,
    required this.dentro,
    required this.maximo,
    required this.porcentaje,
  });

  factory DetallePerfilOcupacion.fromJson(
    Map<String, dynamic> json, {
    required String perfil,
  }) {
    return DetallePerfilOcupacion(
      perfil: perfil,
      dentro: JsonUtils.parseInt(json['dentro']),
      maximo: JsonUtils.parseInt(json['maximo']),
      porcentaje: JsonUtils.parseDouble(json['porcentaje']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dentro': dentro,
      'maximo': maximo,
      'porcentaje': porcentaje,
    };
  }

  /// Cupos libres del perfil.
  int get disponibles {
    final int libres = maximo - dentro;
    return libres < 0 ? 0 : libres;
  }

  /// Fracción 0.0-1.0 para barras de progreso.
  double get fraccion => (porcentaje / 100).clamp(0.0, 1.0);

  /// Etiqueta legible del perfil.
  String get etiqueta {
    switch (perfil) {
      case 'administrativo':
        return 'Administrativos';
      case 'operativo':
        return 'Operativos / Técnicos';
      case 'movilidad':
        return 'Movilidad Reducida / Eléctricos';
      default:
        return perfil.isEmpty
            ? 'General'
            : perfil[0].toUpperCase() + perfil.substring(1);
    }
  }

  /// Ocupación lista para mostrar: "15 / 40".
  String get ocupacionTexto => '$dentro / $maximo';

  /// Porcentaje formateado: "37.5%".
  String get porcentajeTexto => '${porcentaje.toStringAsFixed(1)}%';

  /// `true` cuando el perfil agotó sus cupos.
  bool get estaLleno => dentro >= maximo;

  @override
  String toString() =>
      'DetallePerfilOcupacion($perfil: $ocupacionTexto, $porcentajeTexto)';
}

/// Ocupación global y por perfil.
///
/// Contrato: `obtener_kpis_ocupacion()` en `app/routes/admin.py`
/// (`GET /api/admin/kpis-ocupacion`).
///
/// ```json
/// {
///   "status": "success",
///   "totales": {
///     "capacidad_maxima": 110,
///     "ocupacion_actual": 53,
///     "porcentaje_uso_global": 48.2
///   },
///   "detalles_por_perfil": {
///     "administrativo": { "dentro": 15, "maximo": 40, "porcentaje": 37.5 },
///     "operativo":      { "dentro": 35, "maximo": 60, "porcentaje": 58.3 },
///     "movilidad":      { "dentro": 3,  "maximo": 10, "porcentaje": 30.0 }
///   }
/// }
/// ```
class KpiOcupacionModel {
  final String status;

  /// Capacidad total configurada del parqueadero.
  final int capacidadMaxima;

  /// Vehículos actualmente dentro.
  final int ocupacionActual;

  /// Porcentaje global de uso, de 0 a 100.
  final double porcentajeUsoGlobal;

  final DetallePerfilOcupacion administrativo;
  final DetallePerfilOcupacion operativo;
  final DetallePerfilOcupacion movilidad;

  const KpiOcupacionModel({
    required this.status,
    required this.capacidadMaxima,
    required this.ocupacionActual,
    required this.porcentajeUsoGlobal,
    required this.administrativo,
    required this.operativo,
    required this.movilidad,
  });

  factory KpiOcupacionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> totales = JsonUtils.parseMapa(json['totales']);
    final Map<String, dynamic> detalles =
        JsonUtils.parseMapa(json['detalles_por_perfil']);

    return KpiOcupacionModel(
      status: JsonUtils.parseString(json['status'], porDefecto: 'success'),
      capacidadMaxima: JsonUtils.parseInt(totales['capacidad_maxima']),
      ocupacionActual: JsonUtils.parseInt(totales['ocupacion_actual']),
      porcentajeUsoGlobal: JsonUtils.parseDouble(totales['porcentaje_uso_global']),
      administrativo: DetallePerfilOcupacion.fromJson(
        JsonUtils.parseMapa(detalles['administrativo']),
        perfil: 'administrativo',
      ),
      operativo: DetallePerfilOcupacion.fromJson(
        JsonUtils.parseMapa(detalles['operativo']),
        perfil: 'operativo',
      ),
      movilidad: DetallePerfilOcupacion.fromJson(
        JsonUtils.parseMapa(detalles['movilidad']),
        perfil: 'movilidad',
      ),
    );
  }

  /// Instancia vacía para el estado inicial de las pantallas.
  factory KpiOcupacionModel.vacio() {
    return const KpiOcupacionModel(
      status: 'success',
      capacidadMaxima: 0,
      ocupacionActual: 0,
      porcentajeUsoGlobal: 0,
      administrativo: DetallePerfilOcupacion(
        perfil: 'administrativo',
        dentro: 0,
        maximo: 0,
        porcentaje: 0,
      ),
      operativo: DetallePerfilOcupacion(
        perfil: 'operativo',
        dentro: 0,
        maximo: 0,
        porcentaje: 0,
      ),
      movilidad: DetallePerfilOcupacion(
        perfil: 'movilidad',
        dentro: 0,
        maximo: 0,
        porcentaje: 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'totales': <String, dynamic>{
        'capacidad_maxima': capacidadMaxima,
        'ocupacion_actual': ocupacionActual,
        'porcentaje_uso_global': porcentajeUsoGlobal,
      },
      'detalles_por_perfil': <String, dynamic>{
        'administrativo': administrativo.toJson(),
        'operativo': operativo.toJson(),
        'movilidad': movilidad.toJson(),
      },
    };
  }

  /// Los tres perfiles como lista, útil para renderizar con `map`.
  List<DetallePerfilOcupacion> get perfiles => <DetallePerfilOcupacion>[
        administrativo,
        operativo,
        movilidad,
      ];

  /// Celdas libres a nivel global.
  int get celdasDisponibles {
    final int libres = capacidadMaxima - ocupacionActual;
    return libres < 0 ? 0 : libres;
  }

  /// Fracción 0.0-1.0 para barras de progreso.
  double get fraccionGlobal => (porcentajeUsoGlobal / 100).clamp(0.0, 1.0);

  /// Porcentaje formateado: "48.2%".
  String get porcentajeTexto => '${porcentajeUsoGlobal.toStringAsFixed(1)}%';

  /// Ocupación lista para mostrar: "53 / 110".
  String get ocupacionTexto => '$ocupacionActual / $capacidadMaxima';

  /// Nivel del semáforo global: "libre", "medio" u "ocupado".
  String get nivelOcupacion {
    if (porcentajeUsoGlobal >= 90) return 'ocupado';
    if (porcentajeUsoGlobal >= 60) return 'medio';
    return 'libre';
  }

  bool get exitoso => status.toLowerCase() == 'success';

  @override
  String toString() =>
      'KpiOcupacionModel($ocupacionTexto, $porcentajeTexto)';
}
