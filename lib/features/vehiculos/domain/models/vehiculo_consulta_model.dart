import '../../../../core/utils/json_utils.dart';

/// Resultado de la consulta de placa en portería.
///
/// Contrato: `consultar_vehiculo()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/vehiculo/<placa>`).
///
/// ```json
/// {
///   "placa": "ABC123",
///   "tipo": "Automóvil",
///   "marca": "Mazda 3",
///   "color": "Gris",
///   "area": "Tecnología",
///   "propietario": "Carlos Mendoza"
/// }
/// ```
///
/// Nota: esta ruta devuelve la llave `tipo`, no `tipo_vehiculo`.
class VehiculoConsultaModel {
  final String placa;

  /// Tipo de vehículo (llave `tipo` en esta ruta específica).
  final String tipo;

  final String? marca;
  final String? color;
  final String area;

  /// Nombre completo del funcionario propietario.
  final String propietario;

  const VehiculoConsultaModel({
    required this.placa,
    required this.tipo,
    required this.area,
    required this.propietario,
    this.marca,
    this.color,
  });

  factory VehiculoConsultaModel.fromJson(Map<String, dynamic> json) {
    return VehiculoConsultaModel(
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      tipo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo', 'tipo_vehiculo']),
        porDefecto: 'Automóvil',
      ),
      marca: JsonUtils.parseStringOrNull(json['marca']),
      color: JsonUtils.parseStringOrNull(json['color']),
      area: JsonUtils.parseString(json['area'], porDefecto: 'General'),
      propietario: JsonUtils.parseString(
        JsonUtils.primeraLlave(
          json,
          <String>['propietario', 'nombre_funcionario', 'funcionario'],
        ),
        porDefecto: 'Funcionario ParkLink',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'placa': placa,
      'tipo': tipo,
      'marca': marca,
      'color': color,
      'area': area,
      'propietario': propietario,
    });
  }

  bool get esMoto => tipo.toLowerCase().contains('moto');
  bool get esCarro => !esMoto;
  String get tipoCorto => esMoto ? 'Moto' : 'Carro';

  /// "Mazda 3 - Gris" o el tipo si no hay marca ni color.
  String get descripcion {
    final List<String> partes = <String>[
      if (marca != null && marca!.isNotEmpty) marca!,
      if (color != null && color!.isNotEmpty) color!,
    ];
    return partes.isEmpty ? tipo : partes.join(' - ');
  }

  @override
  String toString() =>
      'VehiculoConsultaModel(placa: $placa, propietario: $propietario)';
}
