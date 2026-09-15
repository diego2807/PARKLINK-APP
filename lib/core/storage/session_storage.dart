/// ParkLink - Almacenamiento de la sesión activa en memoria.
///
/// El proyecto sólo declara `http` como dependencia en `pubspec.yaml`, por lo
/// que la sesión se conserva en memoria durante la ejecución de la app.
/// Si más adelante agregas `shared_preferences` o `flutter_secure_storage`,
/// basta con persistir/rehidratar desde [guardarSesion] y [limpiar] sin tocar
/// ningún servicio ni pantalla.
class SessionStorage {
  SessionStorage._();

  /// Instancia única accesible desde toda la aplicación.
  static final SessionStorage instance = SessionStorage._();

  String? _token;
  Map<String, dynamic>? _usuarioJson;

  /// Token JWT emitido por `POST /api/auth/login`.
  String? get token => _token;

  /// Representación cruda del usuario autenticado (`usuario.to_dict()`).
  Map<String, dynamic>? get usuarioJson =>
      _usuarioJson == null ? null : Map<String, dynamic>.from(_usuarioJson!);

  /// `true` cuando existe un token vigente en memoria.
  bool get estaAutenticado => _token != null && _token!.isNotEmpty;

  /// Identificador del usuario en sesión.
  int? get usuarioId {
    final dynamic valor = _usuarioJson?['id'];
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }

  /// Rol en texto plano: `usuario`, `vigilante` o `administrador`.
  String? get rol {
    final dynamic valor = _usuarioJson?['rol'];
    return valor is String ? valor.toLowerCase().trim() : null;
  }

  /// Nombre completo del usuario en sesión.
  String? get nombreCompleto {
    final dynamic valor = _usuarioJson?['nombre_completo'];
    return valor is String ? valor : null;
  }

  /// Correo corporativo del usuario en sesión.
  String? get correo {
    final dynamic valor = _usuarioJson?['correo'];
    return valor is String ? valor : null;
  }

  /// Atajos de rol para decidir navegación y permisos en la UI.
  bool get esAdministrador => rol == 'administrador';
  bool get esVigilante => rol == 'vigilante';
  bool get esUsuario => rol == 'usuario';

  /// Guarda el token y los datos del usuario tras un login exitoso.
  void guardarSesion({
    required String token,
    Map<String, dynamic>? usuario,
  }) {
    _token = token;
    _usuarioJson = usuario == null ? null : Map<String, dynamic>.from(usuario);
  }

  /// Actualiza únicamente el token (por ejemplo, tras un refresh).
  void actualizarToken(String token) {
    _token = token;
  }

  /// Actualiza únicamente los datos del usuario.
  void actualizarUsuario(Map<String, dynamic> usuario) {
    _usuarioJson = Map<String, dynamic>.from(usuario);
  }

  /// Borra la sesión completa (cierre de sesión o token expirado).
  void limpiar() {
    _token = null;
    _usuarioJson = null;
  }
}
