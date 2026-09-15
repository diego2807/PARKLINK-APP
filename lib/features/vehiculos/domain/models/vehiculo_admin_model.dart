import '../../../../core/utils/json_utils.dart';

/// Vehículo en la vista global del administrador.
///
/// Contrato: `listar_vehiculos()` en `app/routes/admin.py`
/// (`GET /api/admin/vehiculos`).
///
/// ```json
/// {
///   "id": 1,
///   "placa": "ABC123",
///   "nombre_funcionario": "Carlos Mendoza",
///   "area": "Tecnología",
///   "tipo_vehiculo": "Automóvil"
/// }
/// ```
///
/// La respuesta de `POST /api/admin/vehiculos` reutiliza este mismo modelo,
/// aunque no incluye `tipo_vehiculo`.
class VehiculoAdminModel {
  final int id;
  final String placa;

  /// Nombre del funcionario dueño del vehículo.
  final String nombreFuncionario;

  /// Área corporativa asignada.
  final String area;

  /// "Automóvil", "Camioneta" o "Motocicleta".
  final String tipoVehiculo;

  const VehiculoAdminModel({
    required this.id,
    required this.placa,
    required this.nombreFuncionario,
    required this.area,
    required this.tipoVehiculo,
  });

  factory VehiculoAdminModel.fromJson(Map<String, dynamic> json) {
    return VehiculoAdminModel(
      id: JsonUtils.parseInt(json['id']),
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      nombreFuncionario: JsonUtils.parseString(
        JsonUtils.primeraLlave(
          json,
          <String>['nombre_funcionario', 'funcionario', 'nombre'],
        ),
        porDefecto: 'Funcionario Desconocido',
      ),
      area: JsonUtils.parseString(json['area'], porDefecto: 'Área Operativa'),
      tipoVehiculo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_vehiculo', 'tipo']),
        porDefecto: 'Automóvil',
      ),
    );
  }

  /// Payload aceptado por `POST /api/admin/vehiculos`.
  ///
  /// El Back-End exige `nombre_funcionario` (o `nombre`) y `placa`;
  /// `tipo_vehiculo` y `area` tienen valores por defecto en el servidor.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre_funcionario': nombreFuncionario,
      'placa': placa.toUpperCase(),
      'tipo_vehiculo': tipoVehiculo,
      'area': area,
    };
  }

  bool get esMoto => tipoVehiculo.toLowerCase().contains('moto');
  bool get esCarro => !esMoto;

  /// Etiqueta corta usada en las tablas: "Carro" o "Moto".
  String get tipoCorto => esMoto ? 'Moto' : 'Carro';

  /// Iniciales del funcionario para avatares de la tabla.
  String get inicialesFuncionario {
    final List<String> partes = nombreFuncionario
        .trim()
        .split(RegExp(r'\s+'))
        .where((String parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'PL';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1)).toUpperCase();
  }

  /// Filtros de `Vehiculos.dart`: "Todos", "Motos", "Carros".
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todos' || limpio == 'todas') return true;
    if (limpio == 'motos' || limpio == 'moto') return esMoto;
    if (limpio == 'carros' || limpio == 'carro') return esCarro;
    return tipoVehiculo.toLowerCase() == limpio;
  }

  /// Búsqueda por placa, funcionario o área.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) ||
        nombreFuncionario.toLowerCase().contains(limpio) ||
        area.toLowerCase().contains(limpio);
  }

  VehiculoAdminModel copyWith({
    int? id,
    String? placa,
    String? nombreFuncionario,
    String? area,
    String? tipoVehiculo,
  }) {
    return VehiculoAdminModel(
      id: id ?? this.id,
      placa: placa ?? this.placa,
      nombreFuncionario: nombreFuncionario ?? this.nombreFuncionario,
      area: area ?? this.area,
      tipoVehiculo: tipoVehiculo ?? this.tipoVehiculo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VehiculoAdminModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VehiculoAdminModel(id: $id, placa: $placa, funcionario: $nombreFuncionario)';
}
