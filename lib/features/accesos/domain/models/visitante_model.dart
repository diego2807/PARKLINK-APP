import '../../../../core/utils/json_utils.dart';

/// Visitante registrado en portería.
///
/// Contrato: `listar_visitantes()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/visitantes`).
///
/// ```json
/// {
///   "id": 3,
///   "nombre_completo": "Ana Gómez",
///   "documento": "1020304050",
///   "placa_vehiculo": "XYZ789",
///   "area_visitada": "Tecnología",
///   "motivo_visita": "Reunión comercial",
///   "fecha_registro": "2026-09-14 09:15:00"
/// }
/// ```
class VisitanteModel {
  final int id;
  final String nombreCompleto;
  final String documento;
  final String placaVehiculo;

  /// Persona o área visitada.
  final String areaVisitada;

  final String motivoVisita;
  final DateTime? fechaRegistro;

  const VisitanteModel({
    required this.id,
    required this.nombreCompleto,
    required this.documento,
    required this.placaVehiculo,
    required this.areaVisitada,
    required this.motivoVisita,
    this.fechaRegistro,
  });

  factory VisitanteModel.fromJson(Map<String, dynamic> json) {
    return VisitanteModel(
      id: JsonUtils.parseInt(json['id']),
      nombreCompleto: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['nombre_completo', 'nombre']),
      ),
      documento: JsonUtils.parseString(json['documento']),
      placaVehiculo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['placa_vehiculo', 'placa']),
      ).toUpperCase(),
      areaVisitada: JsonUtils.parseString(json['area_visitada']),
      motivoVisita: JsonUtils.parseString(json['motivo_visita']),
      fechaRegistro: JsonUtils.parseFecha(json['fecha_registro']),
    );
  }

  /// Payload aceptado por `POST /api/vigilante/visitantes`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre_completo': nombreCompleto,
      'documento': documento,
      'placa_vehiculo': placaVehiculo.toUpperCase(),
      'area_visitada': areaVisitada,
      'motivo_visita': motivoVisita,
    };
  }

  /// Iniciales para el avatar de la lista de visitantes.
  String get iniciales {
    final List<String> partes = nombreCompleto
        .trim()
        .split(RegExp(r'\s+'))
        .where((String parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'V';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1)).toUpperCase();
  }

  String get fechaTexto =>
      fechaRegistro == null ? '' : JsonUtils.formatearFecha(fechaRegistro!);

  String get horaTexto =>
      fechaRegistro == null ? '--:--' : JsonUtils.formatearHora(fechaRegistro!);

  /// `true` si el registro corresponde al día de hoy.
  bool get esDeHoy {
    if (fechaRegistro == null) return false;
    final DateTime ahora = DateTime.now();
    return fechaRegistro!.year == ahora.year &&
        fechaRegistro!.month == ahora.month &&
        fechaRegistro!.day == ahora.day;
  }

  /// Búsqueda por nombre, documento o placa.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return nombreCompleto.toLowerCase().contains(limpio) ||
        documento.toLowerCase().contains(limpio) ||
        placaVehiculo.toLowerCase().contains(limpio) ||
        areaVisitada.toLowerCase().contains(limpio);
  }

  VisitanteModel copyWith({
    int? id,
    String? nombreCompleto,
    String? documento,
    String? placaVehiculo,
    String? areaVisitada,
    String? motivoVisita,
    DateTime? fechaRegistro,
  }) {
    return VisitanteModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      documento: documento ?? this.documento,
      placaVehiculo: placaVehiculo ?? this.placaVehiculo,
      areaVisitada: areaVisitada ?? this.areaVisitada,
      motivoVisita: motivoVisita ?? this.motivoVisita,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VisitanteModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VisitanteModel(id: $id, nombre: $nombreCompleto, placa: $placaVehiculo)';
}
