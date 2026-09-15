/// ParkLink - Configuración central de red.
///
/// Fuente de verdad de las URLs expuestas por el Back-End Flask
/// (ver `app/__init__.py`, sección de registro de Blueprints).
class ApiConfig {
  const ApiConfig._();

  /// Host del servidor Flask.
  ///
  /// - Emulador Android: `http://10.0.2.2:5000`
  /// - Emulador iOS / Web / Desktop: `http://localhost:5000`
  /// - Dispositivo físico: `http://<IP_LOCAL_DEL_PC>:5000`
  static const String host = 'http://10.0.2.2:5000';

  /// Prefijo común de toda la API.
  static const String apiBase = '$host/api';

  /// Blueprint `auth_bp` -> url_prefix "/api/auth".
  static const String auth = '$apiBase/auth';

  /// Blueprints `admin_bp`, `accesos_bp`, `celdas_bp`, `alertas_bp`,
  /// `kpis_bp`, `logs_bp`, `config_bp` y `tendencias_bp` -> "/api/admin".
  static const String admin = '$apiBase/admin';

  /// Blueprint `vigilante_bp` -> url_prefix "/api/vigilante".
  static const String vigilante = '$apiBase/vigilante';

  /// Blueprint `usuario_bp` -> url_prefix "/api/usuario".
  static const String usuario = '$apiBase/usuario';

  /// Ruta de salud expuesta directamente por la app Flask.
  static const String health = '$host/health';

  /// Tiempo máximo de espera para cualquier petición HTTP.
  static const Duration timeout = Duration(seconds: 20);
}
