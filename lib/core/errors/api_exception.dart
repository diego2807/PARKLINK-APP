/// ParkLink - Jerarquía de excepciones de la capa de red.
///
/// Todos los servicios lanzan alguna de estas excepciones, nunca
/// errores genéricos, para que la UI pueda mostrar mensajes claros.
class ApiException implements Exception {
  /// Mensaje legible para el usuario final.
  final String mensaje;

  /// Código HTTP devuelto por el Back-End (null si el fallo fue de red).
  final int? statusCode;

  /// Cuerpo crudo de la respuesta, útil para depuración.
  final dynamic data;

  const ApiException(
    this.mensaje, {
    this.statusCode,
    this.data,
  });

  @override
  String toString() => statusCode == null
      ? 'ApiException: $mensaje'
      : 'ApiException($statusCode): $mensaje';
}

/// HTTP 400 - Datos inválidos o campos obligatorios faltantes.
class BadRequestException extends ApiException {
  const BadRequestException(String mensaje, {dynamic data})
      : super(mensaje, statusCode: 400, data: data);
}

/// HTTP 401 - Token ausente, inválido o expirado.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(String mensaje, {dynamic data})
      : super(mensaje, statusCode: 401, data: data);
}

/// HTTP 403 - El rol autenticado no tiene privilegios suficientes.
class ForbiddenException extends ApiException {
  const ForbiddenException(String mensaje, {dynamic data})
      : super(mensaje, statusCode: 403, data: data);
}

/// HTTP 404 - El recurso solicitado no existe.
class NotFoundException extends ApiException {
  const NotFoundException(String mensaje, {dynamic data})
      : super(mensaje, statusCode: 404, data: data);
}

/// HTTP 409 - Conflicto de estado (duplicados, reservas activas, etc.).
class ConflictException extends ApiException {
  const ConflictException(String mensaje, {dynamic data})
      : super(mensaje, statusCode: 409, data: data);
}

/// HTTP 5xx - Error interno del servidor Flask.
class ServerException extends ApiException {
  const ServerException(
    String mensaje, {
    int statusCode = 500,
    dynamic data,
  }) : super(mensaje, statusCode: statusCode, data: data);
}

/// Fallo de conectividad: host inalcanzable, timeout o DNS.
class NetworkException extends ApiException {
  const NetworkException(String mensaje) : super(mensaje);
}

/// La respuesta llegó, pero no es un JSON interpretable.
class ParseException extends ApiException {
  const ParseException(String mensaje, {dynamic data})
      : super(mensaje, data: data);
}
