import '../../../../core/utils/json_utils.dart';

/// Acciones disponibles cuando un vehículo excede el tiempo máximo.
enum AccionExceso {
  notificar('notificar', 'Notificar al usuario'),
  bloquear('bloquear', 'Bloquear el acceso');

  const AccionExceso(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static AccionExceso desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final AccionExceso accion in AccionExceso.values) {
      if (accion.valor == texto) return accion;
    }
    return AccionExceso.notificar;
  }
}

/// Parámetros globales del sistema.
///
/// Contrato: `obtener_configuracion()` en `app/routes/configuraciones.py`
/// (`GET /api/admin/config`). La respuesta viene envuelta:
///
/// ```json
/// {
///   "status": "success",
///   "data": {
///     "id": 1,
///     "hora_apertura": "06:00",
///     "hora_cierre": "22:00",
///     "permitir_festivos": true,
///     "tiempo_maximo": 14,
///     "accion_exceso": "notificar",
///     "celdas_admin": 40,
///     "celdas_operativas": 60,
///     "celdas_movilidad": 10
///   }
/// }
/// ```
///
/// `PUT /api/admin/config` devuelve la misma estructura pero sin `id`.
class ConfiguracionModel {
  /// Identificador del registro único de configuración.
  /// Es `null` en la respuesta de actualización, que no lo incluye.
  final int? id;

  /// Hora de apertura en formato `HH:mm`.
  final String horaApertura;

  /// Hora de cierre en formato `HH:mm`.
  final String horaCierre;

  /// Permitir el ingreso en días festivos.
  final bool permitirFestivos;

  /// Tiempo máximo de permanencia, en horas.
  final int tiempoMaximo;

  /// Acción a ejecutar cuando se excede [tiempoMaximo].
  final AccionExceso accionExceso;

  /// Cupos configurados por categoría.
  final int celdasAdmin;
  final int celdasOperativas;
  final int celdasMovilidad;

  const ConfiguracionModel({
    required this.horaApertura,
    required this.horaCierre,
    required this.permitirFestivos,
    required this.tiempoMaximo,
    required this.accionExceso,
    required this.celdasAdmin,
    required this.celdasOperativas,
    required this.celdasMovilidad,
    this.id,
  });

  factory ConfiguracionModel.fromJson(Map<String, dynamic> json) {
    // Tolera recibir el sobre completo `{status, data:{...}}` o sólo `data`.
    final Map<String, dynamic> datos = json.containsKey('data')
        ? JsonUtils.parseMapa(json['data'])
        : json;

    return ConfiguracionModel(
      id: JsonUtils.parseIntOrNull(datos['id']),
      horaApertura:
          JsonUtils.parseString(datos['hora_apertura'], porDefecto: '06:00'),
      horaCierre: JsonUtils.parseString(datos['hora_cierre'], porDefecto: '22:00'),
      permitirFestivos:
          JsonUtils.parseBool(datos['permitir_festivos'], porDefecto: true),
      tiempoMaximo: JsonUtils.parseInt(datos['tiempo_maximo'], porDefecto: 14),
      accionExceso: AccionExceso.desdeTexto(datos['accion_exceso']),
      celdasAdmin: JsonUtils.parseInt(datos['celdas_admin'], porDefecto: 40),
      celdasOperativas:
          JsonUtils.parseInt(datos['celdas_operativas'], porDefecto: 60),
      celdasMovilidad:
          JsonUtils.parseInt(datos['celdas_movilidad'], porDefecto: 10),
    );
  }

  /// Valores por defecto idénticos a los del modelo SQLAlchemy.
  factory ConfiguracionModel.porDefecto() {
    return const ConfiguracionModel(
      horaApertura: '06:00',
      horaCierre: '22:00',
      permitirFestivos: true,
      tiempoMaximo: 14,
      accionExceso: AccionExceso.notificar,
      celdasAdmin: 40,
      celdasOperativas: 60,
      celdasMovilidad: 10,
    );
  }

  /// Payload aceptado por `PUT /api/admin/config`.
  ///
  /// El Back-End actualiza sólo las llaves presentes, por lo que se envían
  /// todas para mantener la configuración consistente.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hora_apertura': horaApertura,
      'hora_cierre': horaCierre,
      'permitir_festivos': permitirFestivos,
      'tiempo_maximo': tiempoMaximo,
      'accion_exceso': accionExceso.valor,
      'celdas_admin': celdasAdmin,
      'celdas_operativas': celdasOperativas,
      'celdas_movilidad': celdasMovilidad,
    };
  }

  /// Capacidad total del parqueadero según los cupos configurados.
  int get capacidadTotal => celdasAdmin + celdasOperativas + celdasMovilidad;

  /// Horario operativo listo para mostrar: "06:00 - 22:00".
  String get horarioTexto => '$horaApertura - $horaCierre';

  /// Tiempo máximo formateado: "14 horas".
  String get tiempoMaximoTexto =>
      '$tiempoMaximo ${tiempoMaximo == 1 ? 'hora' : 'horas'}';

  /// Hora de apertura expresada en minutos desde medianoche.
  int get aperturaEnMinutos => JsonUtils.parseHoraEnMinutos(horaApertura) ?? 360;

  /// Hora de cierre expresada en minutos desde medianoche.
  int get cierreEnMinutos => JsonUtils.parseHoraEnMinutos(horaCierre) ?? 1320;

  /// `true` si el parqueadero está dentro de su horario operativo ahora mismo.
  bool get estaAbiertoAhora {
    final DateTime ahora = DateTime.now();
    final int minutosActuales = (ahora.hour * 60) + ahora.minute;
    final int apertura = aperturaEnMinutos;
    final int cierre = cierreEnMinutos;

    // Horario que cruza la medianoche (p. ej. 22:00 - 06:00).
    if (cierre < apertura) {
      return minutosActuales >= apertura || minutosActuales < cierre;
    }
    return minutosActuales >= apertura && minutosActuales < cierre;
  }

  /// `true` si la acción configurada bloquea el acceso al exceder el tiempo.
  bool get bloqueaPorExceso => accionExceso == AccionExceso.bloquear;

  ConfiguracionModel copyWith({
    int? id,
    String? horaApertura,
    String? horaCierre,
    bool? permitirFestivos,
    int? tiempoMaximo,
    AccionExceso? accionExceso,
    int? celdasAdmin,
    int? celdasOperativas,
    int? celdasMovilidad,
  }) {
    return ConfiguracionModel(
      id: id ?? this.id,
      horaApertura: horaApertura ?? this.horaApertura,
      horaCierre: horaCierre ?? this.horaCierre,
      permitirFestivos: permitirFestivos ?? this.permitirFestivos,
      tiempoMaximo: tiempoMaximo ?? this.tiempoMaximo,
      accionExceso: accionExceso ?? this.accionExceso,
      celdasAdmin: celdasAdmin ?? this.celdasAdmin,
      celdasOperativas: celdasOperativas ?? this.celdasOperativas,
      celdasMovilidad: celdasMovilidad ?? this.celdasMovilidad,
    );
  }

  @override
  String toString() =>
      'ConfiguracionModel(horario: $horarioTexto, capacidad: $capacidadTotal)';
}
