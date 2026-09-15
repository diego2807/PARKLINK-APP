import '../../../../core/utils/json_utils.dart';

/// Registro de entrada o salida del parqueadero.
///
/// Contrato: `obtener_historial()` en `app/routes/accesos.py`
/// (`GET /api/admin/historial`).
///
/// ```json
/// {
///   "id": 12,
///   "placa": "ABC123",
///   "tipo_movimiento": "Entrada",
///   "tipo_vehiculo": "Automóvil",
///   "tipo_usuario": "Funcionario",
///   "celda_asignada": "A-01",
///   "fecha_hora": "2026-09-14 08:30:00"
/// }
/// ```
///
/// El Back-End sustituye los nulos por `"N/A"` y `"Sin fecha"`, por lo que
/// esos marcadores se normalizan a `null` en el modelo.
class AccesoModel {
  final int id;
  final String placa;

  /// "Entrada" o "Salida".
  final String tipoMovimiento;

  /// "Automóvil", "Motocicleta" o "Camioneta".
  final String tipoVehiculo;

  /// "Funcionario" o "Invitado".
  final String tipoUsuario;

  /// Código de celda asignada. `null` cuando el servidor envió "N/A".
  final String? celdaAsignada;

  /// Fecha y hora del movimiento. `null` cuando el servidor envió "Sin fecha".
  final DateTime? fechaHora;

  const AccesoModel({
    required this.id,
    required this.placa,
    required this.tipoMovimiento,
    required this.tipoVehiculo,
    required this.tipoUsuario,
    this.celdaAsignada,
    this.fechaHora,
  });

  factory AccesoModel.fromJson(Map<String, dynamic> json) {
    return AccesoModel(
      id: JsonUtils.parseInt(json['id']),
      placa: JsonUtils.parseString(json['placa']).toUpperCase(),
      tipoMovimiento: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_movimiento', 'movimiento']),
        porDefecto: 'Entrada',
      ),
      tipoVehiculo: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_vehiculo', 'tipo']),
        porDefecto: 'Automóvil',
      ),
      tipoUsuario: JsonUtils.parseString(
        json['tipo_usuario'],
        porDefecto: 'Funcionario',
      ),
      celdaAsignada: JsonUtils.parseStringOrNull(
        JsonUtils.primeraLlave(json, <String>['celda_asignada', 'celda']),
      ),
      fechaHora: JsonUtils.parseFecha(
        JsonUtils.primeraLlave(json, <String>['fecha_hora', 'fecha']),
      ),
    );
  }

  /// Payload aceptado por `POST /api/admin/registrar-acceso`.
  Map<String, dynamic> toJson() {
    return JsonUtils.limpiarNulos(<String, dynamic>{
      'placa': placa.toUpperCase(),
      'tipo_movimiento': tipoMovimiento,
      'tipo_vehiculo': tipoVehiculo,
      'tipo_usuario': tipoUsuario,
      'celda_asignada': celdaAsignada,
    });
  }

  /// `true` cuando el movimiento es un ingreso.
  bool get esEntrada => tipoMovimiento.toLowerCase().trim() == 'entrada';

  /// `true` cuando el movimiento es una salida.
  bool get esSalida => tipoMovimiento.toLowerCase().trim() == 'salida';

  /// `true` si el vehículo pertenece a un visitante/invitado.
  bool get esInvitado => tipoUsuario.toLowerCase().contains('invitado');

  bool get esMoto => tipoVehiculo.toLowerCase().contains('moto');
  bool get esCarro => !esMoto;

  /// Etiqueta corta usada en las tablas: "Carro" o "Moto".
  String get tipoCorto => esMoto ? 'Moto' : 'Carro';

  /// Celda lista para mostrar; devuelve "N/A" si no hay asignación.
  String get celdaTexto => celdaAsignada ?? 'N/A';

  /// Fecha en formato `yyyy-MM-dd` o cadena vacía.
  String get fechaTexto =>
      fechaHora == null ? '' : JsonUtils.formatearFecha(fechaHora!);

  /// Hora en formato `HH:mm` o cadena vacía.
  String get horaTexto =>
      fechaHora == null ? '' : JsonUtils.formatearHora(fechaHora!);

  /// Texto completo `yyyy-MM-dd HH:mm:ss` o "Sin fecha".
  String get fechaHoraTexto => fechaHora == null
      ? 'Sin fecha'
      : JsonUtils.formatearFechaHora(fechaHora!);

  /// Hora en formato de 12 horas: "08:30 AM".
  String get horaAmPm {
    if (fechaHora == null) return '--:--';
    final int hora24 = fechaHora!.hour;
    final int hora12 = hora24 % 12 == 0 ? 12 : hora24 % 12;
    final String minuto = fechaHora!.minute.toString().padLeft(2, '0');
    final String periodo = hora24 < 12 ? 'AM' : 'PM';
    return '${hora12.toString().padLeft(2, '0')}:$minuto $periodo';
  }

  /// Descripción para las listas de actividad reciente:
  /// "Entrada - ABC123".
  String get resumen => '$tipoMovimiento - $placa';

  /// Filtros de la pantalla de historial ("Todos", "Entrada", "Salida").
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todos' || limpio == 'todas') return true;
    if (limpio == 'entrada' || limpio == 'entradas') return esEntrada;
    if (limpio == 'salida' || limpio == 'salidas') return esSalida;
    if (limpio == 'motos' || limpio == 'moto') return esMoto;
    if (limpio == 'carros' || limpio == 'carro') return esCarro;
    return true;
  }

  /// Búsqueda por placa o celda.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return placa.toLowerCase().contains(limpio) ||
        celdaTexto.toLowerCase().contains(limpio) ||
        tipoVehiculo.toLowerCase().contains(limpio);
  }

  AccesoModel copyWith({
    int? id,
    String? placa,
    String? tipoMovimiento,
    String? tipoVehiculo,
    String? tipoUsuario,
    String? celdaAsignada,
    DateTime? fechaHora,
  }) {
    return AccesoModel(
      id: id ?? this.id,
      placa: placa ?? this.placa,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      tipoVehiculo: tipoVehiculo ?? this.tipoVehiculo,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      celdaAsignada: celdaAsignada ?? this.celdaAsignada,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AccesoModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AccesoModel(id: $id, placa: $placa, movimiento: $tipoMovimiento)';
}
