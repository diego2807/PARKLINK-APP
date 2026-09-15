import '../../../../core/utils/json_utils.dart';

/// Fila de la tabla "vehículos activos" del dashboard de KPIs.
///
/// Contrato: llave `vehiculos_activos` (en `app/routes/admin.py`) o `activos`
/// (en `app/routes/kpis.py`).
///
/// ```json
/// {
///   "placa": "ABC123",
///   "tipo_vehiculo": "Automóvil",
///   "funcionario": "Carlos Mendoza",
///   "area": "Tecnología",
///   "hora_ingreso": "08:12 AM",
///   "celda": "A-01"
/// }
/// ```
///
/// `hora_ingreso` puede llegar como texto libre ("Reciente", "08:12 AM"),
/// por eso se conserva como `String`.
class VehiculoActivoKpiModel {
  final String placa;
  final String tipoVehiculo;
  final String funcionario;
  final String area;
  final String horaIngreso;
  final String celda;

  const VehiculoActivoKpiModel({
    required this.placa,
    required this.tipoVehiculo,
    required this.funcionario,
    required this.area,
    required this.horaIngreso,
    required this.celda,
  });

  factory VehiculoActivoKpiModel.fromJson(Map<String, dynamic> json) {
    return VehiculoActivoKpiModel(
      placa: JsonUtils.parseString(json['placa'], porDefecto: 'S/P').toUpperCase(),
      tipoVehiculo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_vehiculo', 'tipo']),
        porDefecto: 'Automóvil',
      ),
      funcionario: JsonUtils.parseString(
        JsonUtils.primeraLlave(
          json,
          <String>['funcionario', 'nombre_funcionario', 'propietario'],
        ),
        porDefecto: 'Funcionario ParkLink',
      ),
      area: JsonUtils.parseString(json['area'], porDefecto: 'Área Operativa'),
      horaIngreso: JsonUtils.parseString(
        json['hora_ingreso'],
        porDefecto: 'Reciente',
      ),
      celda: JsonUtils.parseString(json['celda'], porDefecto: 'Asignada'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'placa': placa,
      'tipo_vehiculo': tipoVehiculo,
      'funcionario': funcionario,
      'area': area,
      'hora_ingreso': horaIngreso,
      'celda': celda,
    };
  }

  bool get esMoto => tipoVehiculo.toLowerCase().contains('moto');
  bool get esCarro => !esMoto;
  String get tipoCorto => esMoto ? 'Moto' : 'Carro';

  /// Búsqueda por placa, funcionario, área o celda.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) ||
        funcionario.toLowerCase().contains(limpio) ||
        area.toLowerCase().contains(limpio) ||
        celda.toLowerCase().contains(limpio);
  }

  @override
  String toString() => 'VehiculoActivoKpiModel(placa: $placa, celda: $celda)';
}

/// Indicadores del panel de control (`GET /api/admin/kpis`).
///
/// IMPORTANTE: esa URL está registrada por dos Blueprints distintos
/// (`admin_bp` y `kpis_bp`), cada uno con una forma de respuesta diferente:
///
/// 1. `app/routes/admin.py` -> estructura plana:
/// ```json
/// {
///   "ocupacion_total": 12,
///   "porcentaje_ocupacion": 10.9,
///   "total_carros": 9,
///   "total_motos": 3,
///   "celdas_especiales": 2,
///   "limite_admin": 40,
///   "limite_operativas": 60,
///   "limite_movilidad": 10,
///   "vehiculos_activos": [ ... ]
/// }
/// ```
///
/// 2. `app/routes/kpis.py` -> estructura anidada:
/// ```json
/// { "metricas": { ... }, "activos": [ ... ] }
/// ```
///
/// Este modelo interpreta ambas formas, de modo que la app sigue funcionando
/// sin importar cuál de los dos Blueprints atienda la petición.
class KpiModel {
  /// Celdas ocupadas actualmente.
  final int ocupacionTotal;

  /// Porcentaje de ocupación de 0 a 100.
  final double porcentajeOcupacion;

  final int totalCarros;
  final int totalMotos;

  /// Celdas especiales ocupadas (o total de alertas, según el Blueprint).
  final int celdasEspeciales;

  /// Límites configurados. Sólo los entrega la variante de `admin.py`;
  /// en la variante de `kpis.py` llegan como `null`.
  final int? limiteAdmin;
  final int? limiteOperativas;
  final int? limiteMovilidad;

  /// Vehículos listados en la tabla inferior del dashboard.
  final List<VehiculoActivoKpiModel> vehiculosActivos;

  const KpiModel({
    required this.ocupacionTotal,
    required this.porcentajeOcupacion,
    required this.totalCarros,
    required this.totalMotos,
    required this.celdasEspeciales,
    required this.vehiculosActivos,
    this.limiteAdmin,
    this.limiteOperativas,
    this.limiteMovilidad,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) {
    // Si viene la llave `metricas`, se trata de la respuesta de kpis.py.
    final Map<String, dynamic> metricas = json.containsKey('metricas')
        ? JsonUtils.parseMapa(json['metricas'])
        : json;

    final dynamic listaActivos = JsonUtils.primeraLlave(
      json,
      <String>['vehiculos_activos', 'activos'],
    );

    return KpiModel(
      ocupacionTotal: JsonUtils.parseInt(metricas['ocupacion_total']),
      porcentajeOcupacion: JsonUtils.parseDouble(metricas['porcentaje_ocupacion']),
      totalCarros: JsonUtils.parseInt(metricas['total_carros']),
      totalMotos: JsonUtils.parseInt(metricas['total_motos']),
      celdasEspeciales: JsonUtils.parseInt(metricas['celdas_especiales']),
      limiteAdmin: JsonUtils.parseIntOrNull(json['limite_admin']),
      limiteOperativas: JsonUtils.parseIntOrNull(json['limite_operativas']),
      limiteMovilidad: JsonUtils.parseIntOrNull(json['limite_movilidad']),
      vehiculosActivos: JsonUtils.parseLista<VehiculoActivoKpiModel>(
        listaActivos,
        VehiculoActivoKpiModel.fromJson,
      ),
    );
  }

  /// Instancia vacía para el estado inicial de las pantallas.
  factory KpiModel.vacio() {
    return const KpiModel(
      ocupacionTotal: 0,
      porcentajeOcupacion: 0,
      totalCarros: 0,
      totalMotos: 0,
      celdasEspeciales: 0,
      vehiculosActivos: <VehiculoActivoKpiModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'ocupacion_total': ocupacionTotal,
      'porcentaje_ocupacion': porcentajeOcupacion,
      'total_carros': totalCarros,
      'total_motos': totalMotos,
      'celdas_especiales': celdasEspeciales,
      'limite_admin': limiteAdmin,
      'limite_operativas': limiteOperativas,
      'limite_movilidad': limiteMovilidad,
      'vehiculos_activos': vehiculosActivos
          .map((VehiculoActivoKpiModel v) => v.toJson())
          .toList(),
    });
  }

  /// Total de vehículos registrados (carros + motos).
  int get totalVehiculos => totalCarros + totalMotos;

  /// Capacidad máxima si el Back-End entregó los límites; `null` si no.
  int? get capacidadMaxima {
    if (limiteAdmin == null && limiteOperativas == null && limiteMovilidad == null) {
      return null;
    }
    return (limiteAdmin ?? 0) + (limiteOperativas ?? 0) + (limiteMovilidad ?? 0);
  }

  /// Celdas libres, cuando se conoce la capacidad máxima.
  int? get celdasDisponibles {
    final int? capacidad = capacidadMaxima;
    if (capacidad == null) return null;
    final int libres = capacidad - ocupacionTotal;
    return libres < 0 ? 0 : libres;
  }

  /// Fracción 0.0-1.0 para barras de progreso.
  double get fraccionOcupacion => (porcentajeOcupacion / 100).clamp(0.0, 1.0);

  /// Porcentaje formateado: "10.9%".
  String get porcentajeTexto => '${porcentajeOcupacion.toStringAsFixed(1)}%';

  /// Nivel de saturación: "libre", "medio" u "ocupado".
  String get nivelOcupacion {
    if (porcentajeOcupacion >= 90) return 'ocupado';
    if (porcentajeOcupacion >= 60) return 'medio';
    return 'libre';
  }

  /// `true` si el parqueadero superó el 90 % de su capacidad.
  bool get estaCritico => porcentajeOcupacion >= 90;

  @override
  String toString() =>
      'KpiModel(ocupacion: $ocupacionTotal, porcentaje: $porcentajeTexto)';
}
