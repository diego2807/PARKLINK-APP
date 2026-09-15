import '../../../../core/utils/json_utils.dart';

/// Vehículo del usuario autenticado.
///
/// Contrato: `obtener_mis_vehiculos()` en `app/services/usuario_service.py`,
/// consumido por `GET /api/usuario/vehiculos`.
///
/// ```json
/// {
///   "id": 1,
///   "placa": "ABC123",
///   "tipo_vehiculo": "Automóvil",
///   "marca": "Mazda 3",
///   "color": "Gris",
///   "area": "Funcionario"
/// }
/// ```
class VehiculoModel {
  final int id;
  final String placa;

  /// "Automóvil", "Camioneta" o "Motocicleta".
  final String tipoVehiculo;

  /// `marca` y `color` son `nullable=True` en `app/models/vehiculo.py`.
  final String? marca;
  final String? color;

  /// Área o dependencia de la empresa.
  final String area;

  const VehiculoModel({
    required this.id,
    required this.placa,
    required this.tipoVehiculo,
    required this.area,
    this.marca,
    this.color,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: JsonUtils.parseInt(json['id']),
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      tipoVehiculo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_vehiculo', 'tipo']),
        porDefecto: 'Automóvil',
      ),
      marca: JsonUtils.parseStringOrNull(json['marca']),
      color: JsonUtils.parseStringOrNull(json['color']),
      area: JsonUtils.parseString(json['area'], porDefecto: 'Funcionario'),
    );
  }

  /// Payload aceptado por `POST /api/usuario/vehiculos`.
  ///
  /// El Back-End exige `placa` y `tipo_vehiculo`; `marca` y `color` son
  /// opcionales y `area` se fuerza a "Funcionario" del lado del servidor.
  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'placa': placa.toUpperCase(),
      'tipo_vehiculo': tipoVehiculo,
      'marca': marca,
      'color': color,
    });
  }

  /// Payload completo incluyendo `id` y `area` (útil para caché local).
  Map<String, dynamic> toJsonCompleto() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'id': id,
      'placa': placa,
      'tipo_vehiculo': tipoVehiculo,
      'marca': marca,
      'color': color,
      'area': area,
    });
  }

  /// `true` cuando el tipo corresponde a una motocicleta.
  bool get esMoto => tipoVehiculo.toLowerCase().contains('moto');

  /// `true` para automóviles, camionetas y cualquier tipo no motocicleta.
  bool get esCarro => !esMoto;

  /// Etiqueta corta usada por las pantallas: "Carro" o "Moto".
  String get tipoCorto => esMoto ? 'Moto' : 'Carro';

  /// Descripción comercial: "Mazda 3 - Gris".
  /// Si no hay marca ni color devuelve el tipo de vehículo.
  String get descripcion {
    final List<String> partes = <String>[
      if (marca != null && marca!.isNotEmpty) marca!,
      if (color != null && color!.isNotEmpty) color!,
    ];
    if (partes.isEmpty) return tipoVehiculo;
    return partes.join(' - ');
  }

  /// Placa con formato visual `ABC-123` cuando tiene 6 caracteres.
  String get placaFormateada {
    final String limpia = placa.replaceAll('-', '').toUpperCase();
    if (limpia.length == 6) {
      return '${limpia.substring(0, 3)}-${limpia.substring(3)}';
    }
    return placa.toUpperCase();
  }

  /// Evalúa los filtros que usan las pantallas de vehículos
  /// ("Todos", "Carros", "Motos").
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todos' || limpio == 'todas') return true;
    if (limpio == 'motos' || limpio == 'moto') return esMoto;
    if (limpio == 'carros' || limpio == 'carro') return esCarro;
    return tipoVehiculo.toLowerCase() == limpio;
  }

  /// Búsqueda por placa, marca, color o área.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) ||
        (marca ?? '').toLowerCase().contains(limpio) ||
        (color ?? '').toLowerCase().contains(limpio) ||
        area.toLowerCase().contains(limpio);
  }

  VehiculoModel copyWith({
    int? id,
    String? placa,
    String? tipoVehiculo,
    String? marca,
    String? color,
    String? area,
  }) {
    return VehiculoModel(
      id: id ?? this.id,
      placa: placa ?? this.placa,
      tipoVehiculo: tipoVehiculo ?? this.tipoVehiculo,
      marca: marca ?? this.marca,
      color: color ?? this.color,
      area: area ?? this.area,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VehiculoModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VehiculoModel(id: $id, placa: $placa)';
}
