/// ParkLink - Utilidades de parseo defensivo de JSON.
///
/// El Back-End de ParkLink serializa manualmente en cada ruta, por lo que
/// un mismo campo puede llegar como `int`, `String`, `null` o incluso con
/// textos de relleno ("N/A", "Sin fecha", "Reciente"). Estas utilidades
/// normalizan esos casos y evitan `type cast` en tiempo de ejecución.
class JsonUtils {
  const JsonUtils._();

  /// Textos que el Back-End usa como marcador de "sin dato".
  static const List<String> marcadoresVacios = <String>[
    '',
    'n/a',
    'na',
    'null',
    'none',
    'sin fecha',
    'sin dato',
    'reciente',
    '--',
  ];

  /// Indica si un valor debe tratarse como ausente.
  static bool esVacio(dynamic valor) {
    if (valor == null) return true;
    if (valor is String) {
      return marcadoresVacios.contains(valor.trim().toLowerCase());
    }
    return false;
  }

  /// Convierte cualquier valor a `String?` sin lanzar excepciones.
  static String? parseStringOrNull(dynamic valor) {
    if (esVacio(valor)) return null;
    if (valor is String) return valor.trim();
    return valor.toString().trim();
  }

  /// Convierte cualquier valor a `String`, usando [porDefecto] si no hay dato.
  static String parseString(dynamic valor, {String porDefecto = ''}) {
    return parseStringOrNull(valor) ?? porDefecto;
  }

  /// Convierte a `int?` aceptando `int`, `double`, `num` y `String` numérico.
  static int? parseIntOrNull(dynamic valor) {
    if (esVacio(valor)) return null;
    if (valor is int) return valor;
    if (valor is double) return valor.round();
    if (valor is num) return valor.toInt();
    if (valor is bool) return valor ? 1 : 0;
    if (valor is String) {
      final String limpio = valor.trim().replaceAll('%', '');
      return int.tryParse(limpio) ?? double.tryParse(limpio)?.round();
    }
    return null;
  }

  /// Convierte a `int`, usando [porDefecto] si el valor no es numérico.
  static int parseInt(dynamic valor, {int porDefecto = 0}) {
    return parseIntOrNull(valor) ?? porDefecto;
  }

  /// Convierte a `double?` aceptando `int`, `double`, `num` y `String`.
  static double? parseDoubleOrNull(dynamic valor) {
    if (esVacio(valor)) return null;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();
    if (valor is num) return valor.toDouble();
    if (valor is String) {
      final String limpio = valor.trim().replaceAll('%', '').replaceAll(',', '.');
      return double.tryParse(limpio);
    }
    return null;
  }

  /// Convierte a `double`, usando [porDefecto] si el valor no es numérico.
  static double parseDouble(dynamic valor, {double porDefecto = 0.0}) {
    return parseDoubleOrNull(valor) ?? porDefecto;
  }

  /// Convierte a `bool?` aceptando `bool`, `int` (0/1) y `String`
  /// ("true", "false", "1", "0", "si", "no").
  static bool? parseBoolOrNull(dynamic valor) {
    if (valor == null) return null;
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      final String limpio = valor.trim().toLowerCase();
      if (limpio.isEmpty) return null;
      if (<String>['true', '1', 'si', 'sí', 'yes', 'ocupada', 'ocupado']
          .contains(limpio)) {
        return true;
      }
      if (<String>['false', '0', 'no', 'libre', 'disponible'].contains(limpio)) {
        return false;
      }
    }
    return null;
  }

  /// Convierte a `bool`, usando [porDefecto] si el valor es ambiguo.
  static bool parseBool(dynamic valor, {bool porDefecto = false}) {
    return parseBoolOrNull(valor) ?? porDefecto;
  }

  /// Parsea fechas provenientes del Back-End.
  ///
  /// Formatos soportados:
  /// - ISO-8601 (`2026-09-14T08:30:00`)
  /// - `%Y-%m-%d %H:%M:%S` (usado por casi todas las rutas Flask)
  /// - `%Y-%m-%d` (fechas puras, p. ej. reservas)
  /// - `%d/%m/%Y %H:%M` (usado por `/api/usuario/notificaciones`)
  /// - Timestamp UNIX en segundos o milisegundos
  static DateTime? parseFecha(dynamic valor) {
    if (esVacio(valor)) return null;

    if (valor is DateTime) return valor;

    if (valor is num) {
      final int entero = valor.toInt();
      // Heurística: más de 10 dígitos implica milisegundos.
      return entero > 99999999999
          ? DateTime.fromMillisecondsSinceEpoch(entero)
          : DateTime.fromMillisecondsSinceEpoch(entero * 1000);
    }

    final String texto = valor.toString().trim();
    if (texto.isEmpty) return null;

    // 1. Intento directo (ISO-8601 y "yyyy-MM-dd HH:mm:ss").
    final DateTime? directo = DateTime.tryParse(texto);
    if (directo != null) return directo;

    // 2. Formato "dd/MM/yyyy HH:mm" o "dd/MM/yyyy".
    final RegExp patronBarras = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?$',
    );
    final RegExpMatch? coincidencia = patronBarras.firstMatch(texto);
    if (coincidencia != null) {
      return DateTime(
        int.parse(coincidencia.group(3)!),
        int.parse(coincidencia.group(2)!),
        int.parse(coincidencia.group(1)!),
        int.tryParse(coincidencia.group(4) ?? '0') ?? 0,
        int.tryParse(coincidencia.group(5) ?? '0') ?? 0,
        int.tryParse(coincidencia.group(6) ?? '0') ?? 0,
      );
    }

    // 3. Timestamp UNIX enviado como texto.
    final int? epoch = int.tryParse(texto);
    if (epoch != null) {
      return epoch > 99999999999
          ? DateTime.fromMillisecondsSinceEpoch(epoch)
          : DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    }

    return null;
  }

  /// Parsea una hora en formato `HH:mm` o `HH:mm:ss` y la devuelve como
  /// cantidad de minutos desde medianoche. Retorna `null` si no aplica.
  static int? parseHoraEnMinutos(dynamic valor) {
    final String? texto = parseStringOrNull(valor);
    if (texto == null) return null;

    final RegExpMatch? coincidencia =
        RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(texto);
    if (coincidencia == null) return null;

    final int horas = int.parse(coincidencia.group(1)!);
    final int minutos = int.parse(coincidencia.group(2)!);
    return (horas * 60) + minutos;
  }

  /// Convierte una lista dinámica en `List<T>` tipada aplicando [constructor].
  static List<T> parseLista<T>(
    dynamic valor,
    T Function(Map<String, dynamic> json) constructor,
  ) {
    if (valor is! List) return <T>[];
    return valor
        .whereType<Map>()
        .map((Map item) => constructor(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Convierte una lista dinámica en `List<String>` limpia.
  static List<String> parseListaTexto(dynamic valor) {
    if (valor is! List) return <String>[];
    return valor
        .map(parseStringOrNull)
        .whereType<String>()
        .where((String item) => item.isNotEmpty)
        .toList();
  }

  /// Normaliza un `Map<dynamic, dynamic>` a `Map<String, dynamic>`.
  static Map<String, dynamic> parseMapa(dynamic valor) {
    if (valor is Map) return Map<String, dynamic>.from(valor);
    return <String, dynamic>{};
  }

  /// Devuelve el primer valor no vacío entre las [llaves] indicadas.
  ///
  /// Útil porque varias rutas del Back-End aceptan o devuelven alias
  /// (`nombre` / `nombre_completo`, `correo` / `email`, etc.).
  static dynamic primeraLlave(
    Map<String, dynamic> json,
    List<String> llaves,
  ) {
    for (final String llave in llaves) {
      if (json.containsKey(llave) && !esVacio(json[llave])) {
        return json[llave];
      }
    }
    return null;
  }

  /// Formatea un [DateTime] como `yyyy-MM-dd` (formato que espera Flask).
  static String formatearFecha(DateTime fecha) {
    final String mes = fecha.month.toString().padLeft(2, '0');
    final String dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  /// Formatea un [DateTime] como `HH:mm` (formato que espera Flask).
  static String formatearHora(DateTime fecha) {
    final String hora = fecha.hour.toString().padLeft(2, '0');
    final String minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Formatea un [DateTime] como `yyyy-MM-dd HH:mm:ss`.
  static String formatearFechaHora(DateTime fecha) {
    final String segundo = fecha.second.toString().padLeft(2, '0');
    return '${formatearFecha(fecha)} ${formatearHora(fecha)}:$segundo';
  }

  /// Elimina las llaves con valor `null` de un payload antes de enviarlo.
  static Map<String, dynamic> limpiarNulos(Map<String, dynamic> payload) {
    final Map<String, dynamic> resultado = <String, dynamic>{};
    payload.forEach((String llave, dynamic valor) {
      if (valor != null) resultado[llave] = valor;
    });
    return resultado;
  }
}
