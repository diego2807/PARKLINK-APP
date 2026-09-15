import '../../../../core/utils/json_utils.dart';

/// Vehículo que permanece dentro del parqueadero durante el turno activo.
///
/// Contrato: `vehiculos_activos()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/vehiculos-activos`).
///
/// ```json
/// {
///   "placa": "ABC123",
///   "celda": "A-01",
///   "fecha_entrada": "2026-09-14 08:30:00",
///   "tipo_vehiculo": "Automóvil"
/// }
/// ```
class VehiculoActivoModel {
  final String placa;
  final String? celda;
  final DateTime? fechaEntrada;
  final String tipoVehiculo;

  const VehiculoActivoModel({
    required this.placa,
    required this.tipoVehiculo,
    this.celda,
    this.fechaEntrada,
  });

  factory VehiculoActivoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoActivoModel(
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      celda: JsonUtils.parseStringOrNull(
        JsonUtils.primeraLlave(json, <String>['celda', 'celda_asignada']),
      ),
      fechaEntrada: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(
          json,
          <String>['fecha_entrada', 'fecha_hora', 'hora_ingreso'],
        ),
      ),
      tipoVehiculo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_vehiculo', 'tipo']),
        porDefecto: 'Automóvil',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'placa': placa,
      'celda': celda,
      'fecha_entrada': fechaEntrada == null
          ? null
          : JsonUtils.formatearFechaHora(fechaEntrada!),
      'tipo_vehiculo': tipoVehiculo,
    });
  }

  bool get esMoto => tipoVehiculo.toLowerCase().contains('moto');
  bool get esCarro => !esMoto;

  /// Etiqueta corta: "Carro" o "Moto".
  String get tipoCorto => esMoto ? 'Moto' : 'Carro';

  String get celdaTexto => celda ?? 'N/A';

  /// Zona deducida del prefijo del código de celda (`A-01` -> `A`).
  String get zona {
    final String codigo = celdaTexto;
    final int separador = codigo.indexOf('-');
    if (separador <= 0) return codigo;
    return codigo.substring(0, separador);
  }

  /// Tiempo transcurrido desde el ingreso.
  Duration get tiempoDentro {
    if (fechaEntrada == null) return Duration.zero;
    final Duration transcurrido = DateTime.now().difference(fechaEntrada!);
    return transcurrido.isNegative ? Duration.zero : transcurrido;
  }

  /// Permanencia legible: "2h 15m" o "40m".
  String get tiempoDentroTexto {
    final Duration duracion = tiempoDentro;
    if (duracion == Duration.zero) return '--';
    final int horas = duracion.inHours;
    final int minutos = duracion.inMinutes.remainder(60);
    if (horas == 0) return '${minutos}m';
    return '${horas}h ${minutos}m';
  }

  /// Horas completas de permanencia (para validar el tiempo máximo global).
  double get horasDentro => tiempoDentro.inMinutes / 60.0;

  /// `true` si superó el tiempo máximo configurado por el administrador.
  bool excedeTiempoMaximo(int horasMaximas) => horasDentro > horasMaximas;

  /// Hora de ingreso en formato de 12 horas: "08:30 AM".
  String get horaIngresoAmPm {
    if (fechaEntrada == null) return '--:--';
    final int hora24 = fechaEntrada!.hour;
    final int hora12 = hora24 % 12 == 0 ? 12 : hora24 % 12;
    final String minuto = fechaEntrada!.minute.toString().padLeft(2, '0');
    final String periodo = hora24 < 12 ? 'AM' : 'PM';
    return '${hora12.toString().padLeft(2, '0')}:$minuto $periodo';
  }

  /// Hora de ingreso en formato 24 horas: "08:30".
  String get horaIngresoTexto => fechaEntrada == null
      ? '--:--'
      : JsonUtils.formatearHora(fechaEntrada!);

  /// Búsqueda por placa o celda.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) ||
        celdaTexto.toLowerCase().contains(limpio);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VehiculoActivoModel && other.placa == placa);

  @override
  int get hashCode => placa.hashCode;

  @override
  String toString() => 'VehiculoActivoModel(placa: $placa, celda: $celdaTexto)';
}
