import '../../../../core/utils/json_utils.dart';
import 'usuario_model.dart';

/// Perfil resumido devuelto por `GET /api/usuario/perfil`
/// (`obtener_perfil()` en `app/services/usuario_service.py`).
///
/// ```json
/// {
///   "nombre_completo": "Carlos Mendoza",
///   "correo": "carlos@redeban.com",
///   "rol": "usuario",
///   "vehiculos": 2,
///   "reservas": 12
/// }
/// ```
class PerfilUsuarioModel {
  final String nombreCompleto;
  final String correo;
  final RolUsuario rol;

  /// Cantidad total de vehículos vinculados al usuario.
  final int totalVehiculos;

  /// Cantidad total de reservas históricas del usuario.
  final int totalReservas;

  const PerfilUsuarioModel({
    required this.nombreCompleto,
    required this.correo,
    required this.rol,
    required this.totalVehiculos,
    required this.totalReservas,
  });

  factory PerfilUsuarioModel.fromJson(Map<String, dynamic> json) {
    return PerfilUsuarioModel(
      nombreCompleto: JsonUtils.parseString(
        json['nombre_completo'],
        porDefecto: 'Funcionario ParkLink',
      ),
      correo: JsonUtils.parseString(json['correo']),
      rol: RolUsuario.desdeTexto(json['rol']),
      totalVehiculos: JsonUtils.parseInt(json['vehiculos']),
      totalReservas: JsonUtils.parseInt(json['reservas']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'rol': rol.valor,
      'vehiculos': totalVehiculos,
      'reservas': totalReservas,
    };
  }

  /// Iniciales para el avatar de la pantalla `Perfil.dart`.
  String get iniciales {
    final List<String> partes = nombreCompleto
        .trim()
        .split(RegExp(r'\s+'))
        .where((String parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'PL';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1)).toUpperCase();
  }

  /// Texto del badge institucional ("Empleado Redeban • Sede Principal").
  String get etiquetaRol => rol.etiqueta;

  /// Valores listos para las tarjetas de métricas del perfil.
  String get totalVehiculosTexto => totalVehiculos.toString();
  String get totalReservasTexto => totalReservas.toString();

  PerfilUsuarioModel copyWith({
    String? nombreCompleto,
    String? correo,
    RolUsuario? rol,
    int? totalVehiculos,
    int? totalReservas,
  }) {
    return PerfilUsuarioModel(
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      totalVehiculos: totalVehiculos ?? this.totalVehiculos,
      totalReservas: totalReservas ?? this.totalReservas,
    );
  }

  @override
  String toString() =>
      'PerfilUsuarioModel(correo: $correo, vehiculos: $totalVehiculos, reservas: $totalReservas)';
}
