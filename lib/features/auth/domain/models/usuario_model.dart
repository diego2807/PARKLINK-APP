import '../../../../core/utils/json_utils.dart';

/// Roles válidos del sistema. Espejo exacto de `RolEnum` en
/// `app/models/usuario.py` (valores en texto plano y minúsculas).
enum RolUsuario {
  usuario('usuario'),
  vigilante('vigilante'),
  administrador('administrador');

  const RolUsuario(this.valor);

  /// Texto plano que viaja en el JSON (`rol`).
  final String valor;

  /// Convierte el texto del Back-End al enum. Si el valor es desconocido
  /// o nulo se asume el rol estándar [RolUsuario.usuario].
  static RolUsuario desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final RolUsuario rol in RolUsuario.values) {
      if (rol.valor == texto || rol.name.toLowerCase() == texto) {
        return rol;
      }
    }
    return RolUsuario.usuario;
  }

  /// Etiqueta lista para mostrar en pantalla.
  String get etiqueta {
    switch (this) {
      case RolUsuario.usuario:
        return 'Usuario';
      case RolUsuario.vigilante:
        return 'Vigilante';
      case RolUsuario.administrador:
        return 'Administrador';
    }
  }

  /// Ruta inicial de navegación asociada al rol (ver `main.dart`).
  String get rutaInicial {
    switch (this) {
      case RolUsuario.usuario:
        return '/user/dashboard';
      case RolUsuario.vigilante:
        return '/vigilante/dashboard';
      case RolUsuario.administrador:
        return '/admin/dashboard';
    }
  }
}

/// Usuario del sistema.
///
/// Contrato: `Usuario.to_dict()` en `app/models/usuario.py`, devuelto por
/// `POST /api/auth/login`, `GET /api/auth/perfil` y
/// `POST /api/admin/registrar-usuario`.
///
/// ```json
/// {
///   "id": 1,
///   "nombre_completo": "Carlos Mendoza",
///   "correo": "carlos@redeban.com",
///   "rol": "usuario",
///   "activo": true,
///   "created_at": "2026-09-14 08:30:00"
/// }
/// ```
class UsuarioModel {
  final int id;
  final String nombreCompleto;
  final String correo;
  final RolUsuario rol;
  final bool activo;

  /// `created_at` llega como `"%Y-%m-%d %H:%M:%S"` o `null`.
  final DateTime? createdAt;

  const UsuarioModel({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.rol,
    required this.activo,
    this.createdAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: JsonUtils.parseInt(json['id']),
      nombreCompleto: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['nombre_completo', 'nombre']),
        porDefecto: 'Funcionario ParkLink',
      ),
      correo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['correo', 'email']),
      ),
      rol: RolUsuario.desdeTexto(json['rol']),
      activo: JsonUtils.parseBool(json['activo'], porDefecto: true),
      createdAt: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(json, <String>['created_at', 'fecha_creacion']),
      ),
    );
  }

  /// Payload con las llaves que acepta `POST /api/admin/registrar-usuario`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'rol': rol.valor,
      'activo': activo,
      if (createdAt != null) 'created_at': JsonUtils.formatearFechaHora(createdAt!),
    };
  }

  /// Iniciales para avatares (`Carlos Mendoza` -> `CM`).
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

  /// Primer nombre, útil para saludos en los dashboards.
  String get primerNombre {
    final List<String> partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? nombreCompleto : partes.first;
  }

  bool get esAdministrador => rol == RolUsuario.administrador;
  bool get esVigilante => rol == RolUsuario.vigilante;
  bool get esUsuarioEstandar => rol == RolUsuario.usuario;

  /// Texto de estado para badges ("Activo" / "Inactivo").
  String get estadoTexto => activo ? 'Activo' : 'Inactivo';

  UsuarioModel copyWith({
    int? id,
    String? nombreCompleto,
    String? correo,
    RolUsuario? rol,
    bool? activo,
    DateTime? createdAt,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsuarioModel && other.id == id && other.correo == correo);

  @override
  int get hashCode => Object.hash(id, correo);

  @override
  String toString() => 'UsuarioModel(id: $id, correo: $correo, rol: ${rol.valor})';
}
