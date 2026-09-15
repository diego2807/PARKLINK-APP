import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/api_exception.dart';
import '../storage/session_storage.dart';
import 'api_config.dart';

/// ParkLink - Cliente HTTP único para toda la aplicación.
///
/// Centraliza:
/// - Cabeceras (`Content-Type: application/json` y `Authorization: Bearer`).
/// - Serialización/deserialización JSON en UTF-8.
/// - Traducción de códigos HTTP (200, 201, 400, 401, 403, 404, 409, 5xx)
///   a excepciones tipadas de [ApiException].
/// - Timeout y errores de conectividad.
class ApiClient {
  ApiClient._();

  /// Instancia única compartida por todos los servicios.
  static final ApiClient instance = ApiClient._();

  /// Cliente subyacente reutilizable (mantiene las conexiones vivas).
  final http.Client _cliente = http.Client();

  /// Sesión activa desde la que se obtiene el token JWT.
  SessionStorage get _sesion => SessionStorage.instance;

  /// Construye las cabeceras de cada petición.
  Map<String, String> construirCabeceras({
    bool requiereAuth = true,
    bool conCuerpo = true,
  }) {
    final Map<String, String> cabeceras = <String, String>{
      'Accept': 'application/json',
    };

    if (conCuerpo) {
      cabeceras['Content-Type'] = 'application/json';
    }

    if (requiereAuth && _sesion.estaAutenticado) {
      cabeceras['Authorization'] = 'Bearer ${_sesion.token}';
    }

    return cabeceras;
  }

  /// Arma la URI final agregando los parámetros de consulta no nulos.
  Uri construirUri(String url, [Map<String, dynamic>? parametros]) {
    final Uri base = Uri.parse(url);
    if (parametros == null || parametros.isEmpty) return base;

    final Map<String, String> query = <String, String>{};
    parametros.forEach((String llave, dynamic valor) {
      if (valor != null) query[llave] = valor.toString();
    });

    if (query.isEmpty) return base;
    return base.replace(queryParameters: <String, String>{
      ...base.queryParameters,
      ...query,
    });
  }

  /// Petición `GET`.
  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? parametros,
    bool requiereAuth = true,
  }) async {
    return _ejecutar(
      () => _cliente
          .get(
            construirUri(url, parametros),
            headers: construirCabeceras(requiereAuth: requiereAuth, conCuerpo: false),
          )
          .timeout(ApiConfig.timeout),
    );
  }

  /// Petición `POST`.
  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? cuerpo,
    Map<String, dynamic>? parametros,
    bool requiereAuth = true,
  }) async {
    return _ejecutar(
      () => _cliente
          .post(
            construirUri(url, parametros),
            headers: construirCabeceras(requiereAuth: requiereAuth),
            body: jsonEncode(cuerpo ?? <String, dynamic>{}),
          )
          .timeout(ApiConfig.timeout),
    );
  }

  /// Petición `PUT`.
  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? cuerpo,
    Map<String, dynamic>? parametros,
    bool requiereAuth = true,
  }) async {
    return _ejecutar(
      () => _cliente
          .put(
            construirUri(url, parametros),
            headers: construirCabeceras(requiereAuth: requiereAuth),
            body: jsonEncode(cuerpo ?? <String, dynamic>{}),
          )
          .timeout(ApiConfig.timeout),
    );
  }

  /// Petición `PATCH`.
  Future<dynamic> patch(
    String url, {
    Map<String, dynamic>? cuerpo,
    Map<String, dynamic>? parametros,
    bool requiereAuth = true,
  }) async {
    return _ejecutar(
      () => _cliente
          .patch(
            construirUri(url, parametros),
            headers: construirCabeceras(requiereAuth: requiereAuth),
            body: jsonEncode(cuerpo ?? <String, dynamic>{}),
          )
          .timeout(ApiConfig.timeout),
    );
  }

  /// Petición `DELETE`.
  Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? cuerpo,
    Map<String, dynamic>? parametros,
    bool requiereAuth = true,
  }) async {
    return _ejecutar(
      () => _cliente
          .delete(
            construirUri(url, parametros),
            headers: construirCabeceras(requiereAuth: requiereAuth),
            body: cuerpo == null ? null : jsonEncode(cuerpo),
          )
          .timeout(ApiConfig.timeout),
    );
  }

  /// Ejecuta la petición y traduce cualquier fallo de transporte.
  Future<dynamic> _ejecutar(Future<http.Response> Function() peticion) async {
    try {
      final http.Response respuesta = await peticion();
      return _procesarRespuesta(respuesta);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException(
        'El servidor de ParkLink tardó demasiado en responder. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const NetworkException(
        'No se pudo conectar con el servidor de ParkLink. '
        'Verifica tu conexión y que el Back-End esté en ejecución.',
      );
    } on FormatException {
      throw const ParseException(
        'El servidor devolvió una respuesta con un formato inesperado.',
      );
    } catch (e) {
      // Cubre SocketException/HandshakeException sin importar `dart:io`,
      // de modo que la capa de red también compile en Flutter Web.
      throw NetworkException(
        'No se pudo establecer comunicación con el servidor de ParkLink. '
        'Detalle: ${e.runtimeType}',
      );
    }
  }

  /// Decodifica el cuerpo y aplica las reglas de estado HTTP.
  dynamic _procesarRespuesta(http.Response respuesta) {
    final int codigo = respuesta.statusCode;
    final dynamic cuerpo = _decodificarCuerpo(respuesta);

    if (codigo >= 200 && codigo < 300) {
      return cuerpo;
    }

    final String mensaje = _extraerMensajeError(cuerpo, codigo);

    switch (codigo) {
      case 400:
        throw BadRequestException(mensaje, data: cuerpo);
      case 401:
        // El token dejó de ser válido: se limpia la sesión en memoria.
        _sesion.limpiar();
        throw UnauthorizedException(mensaje, data: cuerpo);
      case 403:
        throw ForbiddenException(mensaje, data: cuerpo);
      case 404:
        throw NotFoundException(mensaje, data: cuerpo);
      case 409:
        throw ConflictException(mensaje, data: cuerpo);
      case 422:
        throw BadRequestException(mensaje, data: cuerpo);
      default:
        if (codigo >= 500) {
          throw ServerException(mensaje, statusCode: codigo, data: cuerpo);
        }
        throw ApiException(mensaje, statusCode: codigo, data: cuerpo);
    }
  }

  /// Decodifica el cuerpo en UTF-8 (indispensable por las tildes del Back-End).
  dynamic _decodificarCuerpo(http.Response respuesta) {
    if (respuesta.bodyBytes.isEmpty) return null;

    final String texto = utf8.decode(respuesta.bodyBytes, allowMalformed: true);
    if (texto.trim().isEmpty) return null;

    try {
      return jsonDecode(texto);
    } on FormatException {
      // Algunas trazas de error de Flask viajan como HTML/texto plano.
      return <String, dynamic>{'error': texto};
    }
  }

  /// Extrae el mensaje de error respetando las llaves que usa el Back-End:
  /// `error`, `mensaje` y `message`.
  String _extraerMensajeError(dynamic cuerpo, int codigo) {
    if (cuerpo is Map) {
      for (final String llave in <String>['error', 'mensaje', 'message']) {
        final dynamic valor = cuerpo[llave];
        if (valor is String && valor.trim().isNotEmpty) {
          return valor.trim();
        }
      }
    }

    if (cuerpo is String && cuerpo.trim().isNotEmpty) {
      return cuerpo.trim();
    }

    switch (codigo) {
      case 400:
        return 'La solicitud contiene datos inválidos o incompletos.';
      case 401:
        return 'Tu sesión expiró. Inicia sesión nuevamente.';
      case 403:
        return 'No cuentas con los permisos necesarios para esta acción.';
      case 404:
        return 'El recurso solicitado no existe.';
      case 409:
        return 'El registro ya existe o entra en conflicto con otro.';
      default:
        return 'Error interno del servidor de ParkLink (código $codigo).';
    }
  }

  /// Libera el cliente HTTP. Úsalo al cerrar la aplicación si lo necesitas.
  void cerrar() => _cliente.close();
}
