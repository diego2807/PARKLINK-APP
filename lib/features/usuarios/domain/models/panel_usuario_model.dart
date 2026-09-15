import '../../../../core/utils/json_utils.dart';
import 'actividad_reciente_model.dart';

/// Datos del panel principal del usuario.
///
/// Contrato: `panel()` en `app/routes/usuario.py` (`GET /api/usuario/panel`).
///
/// ```json
/// {
///   "usuario_id": "2",
///   "totalVehiculos": 12,
///   "cuposDisponibles": 27,
///   "cuposOcupados": 18,
///   "estadoParqueadero": "Disponible",
///   "ocupacion": 40,
///   "actividad": [ { "hora": "08:30", "evento": "Entrada - ABC123", "estado": "Correcto" } ]
/// }
/// ```
///
/// Atención: esta ruta mezcla convenciones. `usuario_id` viene en snake_case
/// y el resto de llaves en camelCase (`totalVehiculos`, `cuposDisponibles`...),
/// tal como las escribió el Back-End. El modelo las respeta exactamente.
class PanelUsuarioModel {
  /// Identificador del usuario. El JWT guarda el `sub` como texto, por lo que
  /// el servidor puede devolverlo como `String`.
  final int usuarioId;

  /// Total de vehículos registrados en el sistema (conteo global).
  final int totalVehiculos;

  final int cuposDisponibles;
  final int cuposOcupados;

  /// "Disponible" o "Lleno".
  final String estadoParqueadero;

  /// Porcentaje de ocupación de 0 a 100 (entero, ya redondeado).
  final int ocupacion;

  /// Últimos 5 movimientos del parqueadero.
  final List<ActividadRecienteModel> actividad;

  const PanelUsuarioModel({
    required this.usuarioId,
    required this.totalVehiculos,
    required this.cuposDisponibles,
    required this.cuposOcupados,
    required this.estadoParqueadero,
    required this.ocupacion,
    required this.actividad,
  });

  factory PanelUsuarioModel.fromJson(Map<String, dynamic> json) {
    return PanelUsuarioModel(
      usuarioId: JsonUtils.parseInt(json['usuario_id']),
      totalVehiculos: JsonUtils.parseInt(
        JsonUtils.primeraLlave(
          json,
          <String>['totalVehiculos', 'total_vehiculos'],
        ),
      ),
      cuposDisponibles: JsonUtils.parseInt(
        JsonUtils.primeraLlave(
          json,
          <String>['cuposDisponibles', 'cupos_disponibles'],
        ),
      ),
      cuposOcupados: JsonUtils.parseInt(
        JsonUtils.primeraLlave(
          json,
          <String>['cuposOcupados', 'cupos_ocupados'],
        ),
      ),
      estadoParqueadero: JsonUtils.parseString(
        JsonUtils.primeraLlave(
          json,
          <String>['estadoParqueadero', 'estado_parqueadero'],
        ),
        porDefecto: 'Disponible',
      ),
      ocupacion: JsonUtils.parseInt(json['ocupacion']),
      actividad: JsonUtils.parseLista<ActividadRecienteModel>(
        json['actividad'],
        ActividadRecienteModel.fromJson,
      ),
    );
  }

  /// Instancia vacía para el estado inicial de las pantallas.
  factory PanelUsuarioModel.vacio() {
    return const PanelUsuarioModel(
      usuarioId: 0,
      totalVehiculos: 0,
      cuposDisponibles: 0,
      cuposOcupados: 0,
      estadoParqueadero: 'Disponible',
      ocupacion: 0,
      actividad: <ActividadRecienteModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'usuario_id': usuarioId,
      'totalVehiculos': totalVehiculos,
      'cuposDisponibles': cuposDisponibles,
      'cuposOcupados': cuposOcupados,
      'estadoParqueadero': estadoParqueadero,
      'ocupacion': ocupacion,
      'actividad':
          actividad.map((ActividadRecienteModel a) => a.toJson()).toList(),
    };
  }

  /// Total de celdas del parqueadero.
  int get totalCeldas => cuposDisponibles + cuposOcupados;

  /// Fracción 0.0-1.0 para barras de progreso.
  double get fraccionOcupacion => (ocupacion / 100).clamp(0.0, 1.0);

  /// Porcentaje formateado: "40%".
  String get ocupacionTexto => '$ocupacion%';

  /// Cupos listos para mostrar: "18 / 45".
  String get cuposTexto => '$cuposOcupados / $totalCeldas';

  /// `true` cuando no quedan celdas libres.
  bool get estaLleno => cuposDisponibles <= 0;

  /// `true` cuando el parqueadero admite más vehículos.
  bool get hayDisponibilidad => cuposDisponibles > 0;

  /// Nivel del semáforo: "libre", "medio" u "ocupado".
  String get nivelSemaforo {
    if (ocupacion >= 90) return 'ocupado';
    if (ocupacion >= 60) return 'medio';
    return 'libre';
  }

  /// Mensaje corto para el encabezado del dashboard.
  String get mensajeEstado => hayDisponibilidad
      ? 'Hay $cuposDisponibles cupos disponibles'
      : 'El parqueadero está lleno';

  @override
  String toString() =>
      'PanelUsuarioModel(ocupacion: $ocupacionTexto, cupos: $cuposTexto)';
}
