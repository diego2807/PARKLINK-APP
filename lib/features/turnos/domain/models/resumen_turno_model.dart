import '../../../../core/utils/json_utils.dart';
import 'actividad_turno_model.dart';

/// Resumen del turno activo del vigilante.
///
/// Contrato: `resumen_turno()` en `app/services/vigilante_service.py`
/// (`GET /api/vigilante/resumen-turno`).
///
/// ```json
/// {
///   "entradas": 22,
///   "salidas": 20,
///   "vehiculos_activos": 2,
///   "celdas_ocupadas": 18,
///   "celdas_libres": 27,
///   "total_celdas": 45,
///   "visitantes": 3,
///   "novedades": 1,
///   "actividad": [ { "placa": "...", "movimiento": "...", "hora": "...", "celda": "..." } ]
/// }
/// ```
class ResumenTurnoModel {
  final int entradas;
  final int salidas;

  /// Vehículos que siguen dentro del parqueadero.
  final int vehiculosActivos;

  final int celdasOcupadas;
  final int celdasLibres;
  final int totalCeldas;

  final int visitantes;
  final int novedades;

  /// Últimos movimientos registrados (máximo 5 desde el servidor).
  final List<ActividadTurnoModel> actividad;

  const ResumenTurnoModel({
    required this.entradas,
    required this.salidas,
    required this.vehiculosActivos,
    required this.celdasOcupadas,
    required this.celdasLibres,
    required this.totalCeldas,
    required this.visitantes,
    required this.novedades,
    required this.actividad,
  });

  factory ResumenTurnoModel.fromJson(Map<String, dynamic> json) {
    return ResumenTurnoModel(
      entradas: JsonUtils.parseInt(json['entradas']),
      salidas: JsonUtils.parseInt(json['salidas']),
      vehiculosActivos: JsonUtils.parseInt(json['vehiculos_activos']),
      celdasOcupadas: JsonUtils.parseInt(json['celdas_ocupadas']),
      celdasLibres: JsonUtils.parseInt(json['celdas_libres']),
      totalCeldas: JsonUtils.parseInt(json['total_celdas']),
      visitantes: JsonUtils.parseInt(json['visitantes']),
      novedades: JsonUtils.parseInt(json['novedades']),
      actividad: JsonUtils.parseLista<ActividadTurnoModel>(
        json['actividad'],
        ActividadTurnoModel.fromJson,
      ),
    );
  }

  /// Instancia vacía para el estado inicial de las pantallas.
  factory ResumenTurnoModel.vacio() {
    return const ResumenTurnoModel(
      entradas: 0,
      salidas: 0,
      vehiculosActivos: 0,
      celdasOcupadas: 0,
      celdasLibres: 0,
      totalCeldas: 0,
      visitantes: 0,
      novedades: 0,
      actividad: <ActividadTurnoModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'entradas': entradas,
      'salidas': salidas,
      'vehiculos_activos': vehiculosActivos,
      'celdas_ocupadas': celdasOcupadas,
      'celdas_libres': celdasLibres,
      'total_celdas': totalCeldas,
      'visitantes': visitantes,
      'novedades': novedades,
      'actividad':
          actividad.map((ActividadTurnoModel a) => a.toJson()).toList(),
    };
  }

  /// Movimientos totales del turno.
  int get totalMovimientos => entradas + salidas;

  /// Porcentaje de ocupación del parqueadero, de 0 a 100.
  double get porcentajeOcupacion {
    if (totalCeldas <= 0) return 0;
    return (celdasOcupadas / totalCeldas) * 100;
  }

  /// Porcentaje redondeado, listo para mostrar.
  int get porcentajeRedondeado => porcentajeOcupacion.round();

  /// Fracción 0.0-1.0 para barras de progreso.
  double get fraccionOcupacion {
    if (totalCeldas <= 0) return 0;
    return (celdasOcupadas / totalCeldas).clamp(0.0, 1.0);
  }

  /// Ocupación lista para mostrar: "18 / 45".
  String get ocupacionTexto => '$celdasOcupadas / $totalCeldas';

  /// Estado del parqueadero: "Disponible" o "Lleno".
  String get estadoParqueadero => celdasLibres > 0 ? 'Disponible' : 'Lleno';

  /// Nivel del semáforo: "libre", "medio" u "ocupado".
  String get nivelOcupacion {
    final double porcentaje = porcentajeOcupacion;
    if (porcentaje >= 90) return 'ocupado';
    if (porcentaje >= 60) return 'medio';
    return 'libre';
  }

  /// `true` cuando no quedan celdas libres.
  bool get estaLleno => celdasLibres <= 0;

  /// Diferencia entre entradas y salidas del turno.
  int get diferenciaMovimientos => entradas - salidas;

  @override
  String toString() =>
      'ResumenTurnoModel(entradas: $entradas, salidas: $salidas, ocupacion: $ocupacionTexto)';
}
