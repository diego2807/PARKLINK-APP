import '../../../../core/utils/json_utils.dart';

/// Movimiento histórico de los vehículos del usuario autenticado.
///
/// Contrato: `obtener_historial()` en `app/services/usuario_service.py`
/// (`GET /api/usuario/historial`).
///
/// ```json
/// {
///   "fecha": "2026-09-14",
///   "hora": "08:30",
///   "placa": "ABC123",
///   "movimiento": "Entrada"
/// }
/// ```
///
/// Esta ruta no devuelve `id`, por lo que el modelo no lo expone.
class HistorialAccesoModel {
  /// Fecha en formato `yyyy-MM-dd` tal como la envía el servidor.
  final String fecha;

  /// Hora en formato `HH:mm` tal como la envía el servidor.
  final String hora;

  final String placa;

  /// "Entrada" o "Salida".
  final String movimiento;

  const HistorialAccesoModel({
    required this.fecha,
    required this.hora,
    required this.placa,
    required this.movimiento,
  });

  factory HistorialAccesoModel.fromJson(Map<String, dynamic> json) {
    return HistorialAccesoModel(
      fecha: JsonUtils.parseString(json['fecha']),
      hora: JsonUtils.parseString(json['hora']),
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      movimiento: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['movimiento', 'tipo_movimiento']),
        porDefecto: 'Entrada',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fecha': fecha,
      'hora': hora,
      'placa': placa,
      'movimiento': movimiento,
    };
  }

  bool get esEntrada => movimiento.toLowerCase().trim() == 'entrada';
  bool get esSalida => movimiento.toLowerCase().trim() == 'salida';

  /// Combina `fecha` + `hora` en un [DateTime] utilizable para ordenar.
  DateTime? get fechaHora => JsonUtils.parseFecha('$fecha $hora:00');

  /// Hora en formato de 12 horas: "08:30 AM".
  String get horaAmPm {
    final int? minutosTotales = JsonUtils.parseHoraEnMinutos(hora);
    if (minutosTotales == null) return hora;
    final int hora24 = minutosTotales ~/ 60;
    final int minuto = minutosTotales % 60;
    final int hora12 = hora24 % 12 == 0 ? 12 : hora24 % 12;
    final String periodo = hora24 < 12 ? 'AM' : 'PM';
    return '${hora12.toString().padLeft(2, '0')}:'
        '${minuto.toString().padLeft(2, '0')} $periodo';
  }

  /// Etiqueta lista para tarjetas: "Entrada • 08:30".
  String get resumen => '$movimiento • $hora';

  /// Filtros de la pantalla `Historial.dart`.
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todos' || limpio == 'todas') return true;
    if (limpio == 'entrada' || limpio == 'entradas') return esEntrada;
    if (limpio == 'salida' || limpio == 'salidas') return esSalida;
    return true;
  }

  /// Búsqueda por placa o fecha.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) || fecha.contains(limpio);
  }

  @override
  String toString() =>
      'HistorialAccesoModel($placa, $movimiento, $fecha $hora)';
}
