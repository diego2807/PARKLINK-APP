import '../../../../core/utils/json_utils.dart';

/// Estados del ciclo de vida de una reserva.
///
/// Transiciones que aplica el Back-End:
/// - Se crea como `Pendiente`.
/// - Pasa a `Activa` cuando el vigilante registra la entrada del vehículo.
/// - Pasa a `Finalizada` cuando se registra la salida.
enum EstadoReserva {
  pendiente('Pendiente'),
  activa('Activa'),
  finalizada('Finalizada'),
  cancelada('Cancelada');

  const EstadoReserva(this.valor);

  final String valor;

  static EstadoReserva desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final EstadoReserva estado in EstadoReserva.values) {
      if (estado.valor.toLowerCase() == texto) return estado;
    }
    return EstadoReserva.pendiente;
  }
}

/// Reserva de celda del usuario.
///
/// Contrato: `obtener_mis_reservas()` en `app/services/reserva_service.py`
/// (`GET /api/usuario/reservas`).
///
/// ```json
/// {
///   "id": 9,
///   "placa": "ABC123",
///   "fecha": "2026-09-15",
///   "hora": "08:00",
///   "estado": "Pendiente"
/// }
/// ```
///
/// Nota: la respuesta del listado devuelve la `placa`, no el `vehiculo_id`;
/// en cambio la creación exige `vehiculo_id`.
class ReservaModel {
  final int id;

  /// Placa del vehículo reservado (sólo en el listado).
  final String placa;

  /// Fecha en formato `yyyy-MM-dd`.
  final String fecha;

  /// Hora en formato `HH:mm`.
  final String hora;

  final EstadoReserva estado;

  /// Identificador del vehículo. Sólo se conoce al crear la reserva.
  final int? vehiculoId;

  const ReservaModel({
    required this.id,
    required this.placa,
    required this.fecha,
    required this.hora,
    required this.estado,
    this.vehiculoId,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: JsonUtils.parseInt(json['id']),
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      fecha: JsonUtils.parseString(json['fecha']),
      hora: JsonUtils.parseString(json['hora']),
      estado: EstadoReserva.desdeTexto(json['estado']),
      vehiculoId: JsonUtils.parseIntOrNull(json['vehiculo_id']),
    );
  }

  /// Payload aceptado por `POST /api/usuario/reservas`.
  ///
  /// El Back-End exige las tres llaves y valida:
  /// - La fecha no puede ser pasada ni superior a 7 días.
  /// - La hora debe estar entre las 06:00 y las 20:00.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'vehiculo_id': vehiculoId,
      'fecha': fecha,
      'hora': hora,
    };
  }

  bool get estaPendiente => estado == EstadoReserva.pendiente;
  bool get estaActiva => estado == EstadoReserva.activa;
  bool get estaFinalizada => estado == EstadoReserva.finalizada;
  bool get estaCancelada => estado == EstadoReserva.cancelada;

  /// Estado textual para badges.
  String get estadoTexto => estado.valor;

  /// Combina `fecha` + `hora` en un [DateTime].
  DateTime? get fechaHora => JsonUtils.parseFecha('$fecha $hora:00');

  /// Sólo la fecha como [DateTime].
  DateTime? get fechaComoDateTime => JsonUtils.parseFecha(fecha);

  /// Hora en formato de 12 horas: "08:00 AM".
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

  /// Etiqueta completa: "2026-09-15 • 08:00 AM".
  String get fechaHoraTexto => '$fecha • $horaAmPm';

  /// `true` si la reserva es para el día de hoy.
  bool get esDeHoy {
    final DateTime? fechaReserva = fechaComoDateTime;
    if (fechaReserva == null) return false;
    final DateTime ahora = DateTime.now();
    return fechaReserva.year == ahora.year &&
        fechaReserva.month == ahora.month &&
        fechaReserva.day == ahora.day;
  }

  /// `true` si la fecha y hora de la reserva ya pasaron.
  bool get yaPaso {
    final DateTime? momento = fechaHora;
    if (momento == null) return false;
    return momento.isBefore(DateTime.now());
  }

  /// Días que faltan para la reserva (0 si es hoy, negativo si ya pasó).
  int get diasRestantes {
    final DateTime? fechaReserva = fechaComoDateTime;
    if (fechaReserva == null) return 0;
    final DateTime hoy = DateTime.now();
    final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return fechaReserva.difference(inicioHoy).inDays;
  }

  /// `true` cuando la reserva sigue vigente (pendiente o activa y sin vencer).
  bool get esVigente => (estaPendiente || estaActiva) && !yaPaso;

  /// Filtros de la pantalla de reservas.
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todas' || limpio == 'todos') return true;
    return estado.valor.toLowerCase() == limpio;
  }

  /// Búsqueda por placa o fecha.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) || fecha.contains(limpio);
  }

  ReservaModel copyWith({
    int? id,
    String? placa,
    String? fecha,
    String? hora,
    EstadoReserva? estado,
    int? vehiculoId,
  }) {
    return ReservaModel(
      id: id ?? this.id,
      placa: placa ?? this.placa,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      estado: estado ?? this.estado,
      vehiculoId: vehiculoId ?? this.vehiculoId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReservaModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReservaModel(id: $id, placa: $placa, $fecha $hora, ${estado.valor})';
}
