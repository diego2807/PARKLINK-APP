import 'celda_model.dart';

/// Resumen de ocupación agrupado por zona del parqueadero.
///
/// Este modelo no proviene de un endpoint: se calcula en el cliente a partir
/// del listado de `GET /api/admin/celdas` para alimentar las pantallas de
/// semáforo y panel de control, que muestran "ocupadas / total" por zona.
class ResumenZonaModel {
  /// Prefijo de la zona (`A`, `B`, `S1`, `VIP`, `EL`...).
  final String zona;

  /// Celdas ocupadas en la zona.
  final int ocupadas;

  /// Celdas totales de la zona.
  final int total;

  /// Celdas concretas que componen la zona.
  final List<CeldaModel> celdas;

  const ResumenZonaModel({
    required this.zona,
    required this.ocupadas,
    required this.total,
    required this.celdas,
  });

  /// Agrupa una lista de celdas por su prefijo de zona.
  ///
  /// El resultado viene ordenado alfabéticamente por nombre de zona.
  static List<ResumenZonaModel> agrupar(List<CeldaModel> celdas) {
    final Map<String, List<CeldaModel>> agrupadas = <String, List<CeldaModel>>{};

    for (final CeldaModel celda in celdas) {
      agrupadas.putIfAbsent(celda.zona, () => <CeldaModel>[]).add(celda);
    }

    final List<ResumenZonaModel> resultado = agrupadas.entries.map(
      (MapEntry<String, List<CeldaModel>> entrada) {
        final List<CeldaModel> lista = entrada.value;
        return ResumenZonaModel(
          zona: entrada.key,
          ocupadas: lista.where((CeldaModel c) => c.ocupada).length,
          total: lista.length,
          celdas: lista,
        );
      },
    ).toList();

    resultado.sort((ResumenZonaModel a, ResumenZonaModel b) =>
        a.zona.compareTo(b.zona));
    return resultado;
  }

  /// Celdas libres en la zona.
  int get disponibles => total - ocupadas;

  /// Porcentaje de ocupación de 0 a 100.
  double get porcentajeOcupacion {
    if (total <= 0) return 0;
    return (ocupadas / total) * 100;
  }

  /// Porcentaje redondeado, listo para mostrar.
  int get porcentajeRedondeado => porcentajeOcupacion.round();

  /// Fracción de 0.0 a 1.0 para barras de progreso.
  double get fraccionOcupacion {
    if (total <= 0) return 0;
    return (ocupadas / total).clamp(0.0, 1.0);
  }

  /// Nivel del semáforo: "libre", "medio" u "ocupado".
  ///
  /// - < 60 %  -> libre
  /// - 60-89 % -> medio
  /// - >= 90 % -> ocupado
  String get nivelSemaforo {
    final double porcentaje = porcentajeOcupacion;
    if (porcentaje >= 90) return 'ocupado';
    if (porcentaje >= 60) return 'medio';
    return 'libre';
  }

  /// Etiqueta lista para mostrar: "7 / 25".
  String get ocupacionTexto => '$ocupadas / $total';

  /// `true` cuando la zona no admite más vehículos.
  bool get estaLlena => disponibles <= 0;

  @override
  String toString() =>
      'ResumenZonaModel(zona: $zona, ocupacion: $ocupacionTexto)';
}
