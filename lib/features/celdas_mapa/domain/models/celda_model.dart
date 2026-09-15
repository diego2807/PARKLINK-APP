import '../../../../core/utils/json_utils.dart';

/// Celda del parqueadero.
///
/// Contrato: `obtener_mapa_celdas()` en `app/routes/celdas.py`
/// (`GET /api/admin/celdas`).
///
/// ```json
/// {
///   "id": 1,
///   "codigo_celda": "EL-01",
///   "tipo_celda": "eléctricos",
///   "ocupada": false
/// }
/// ```
///
/// El Back-End normaliza `codigo_celda` a mayúsculas y `tipo_celda` a
/// minúsculas al registrarla.
class CeldaModel {
  final int id;

  /// Código único: `A-01`, `EL-05`, `MR-02`...
  final String codigoCelda;

  /// "administrativas", "operativas", "movilidad" o "eléctricos".
  final String tipoCelda;

  final bool ocupada;

  const CeldaModel({
    required this.id,
    required this.codigoCelda,
    required this.tipoCelda,
    required this.ocupada,
  });

  factory CeldaModel.fromJson(Map<String, dynamic> json) {
    return CeldaModel(
      id: JsonUtils.parseInt(json['id']),
      codigoCelda: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['codigo_celda', 'codigo', 'celda']),
      ).toUpperCase(),
      tipoCelda: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['tipo_celda', 'tipo']),
        porDefecto: 'operativas',
      ).toLowerCase(),
      ocupada: JsonUtils.parseBool(json['ocupada']),
    );
  }

  /// Payload aceptado por `POST /api/admin/celdas`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'codigo_celda': codigoCelda.toUpperCase(),
      'tipo_celda': tipoCelda.toLowerCase(),
    };
  }

  /// Payload aceptado por `PUT /api/admin/celdas/<id>/estado`.
  Map<String, dynamic> toJsonEstado() {
    return <String, dynamic>{'ocupada': ocupada};
  }

  /// `true` cuando la celda está libre.
  bool get disponible => !ocupada;

  /// Estado textual que usan las pantallas: "Ocupado" / "Disponible".
  String get estadoTexto => ocupada ? 'Ocupado' : 'Disponible';

  /// Estado en minúsculas para el mapa gráfico: "ocupado" / "disponible".
  String get estadoClave => ocupada ? 'ocupado' : 'disponible';

  /// Zona deducida del prefijo del código (`A-01` -> `A`, `S1-02` -> `S1`).
  String get zona {
    final int separador = codigoCelda.indexOf('-');
    if (separador <= 0) return codigoCelda;
    return codigoCelda.substring(0, separador);
  }

  /// Número de la celda dentro de su zona (`A-01` -> `01`).
  String get numero {
    final int separador = codigoCelda.indexOf('-');
    if (separador < 0 || separador + 1 >= codigoCelda.length) return codigoCelda;
    return codigoCelda.substring(separador + 1);
  }

  bool get esElectrica => tipoCelda.contains('léctric') || tipoCelda.contains('electric');
  bool get esMovilidadReducida => tipoCelda.contains('movilidad');
  bool get esAdministrativa => tipoCelda.contains('administrativ');
  bool get esOperativa => tipoCelda.contains('operativ');

  /// `true` si la celda pertenece a una categoría prioritaria
  /// (eléctricos o movilidad reducida).
  bool get esPrioritaria => esElectrica || esMovilidadReducida;

  /// Etiqueta legible del tipo de celda.
  String get tipoEtiqueta {
    if (esElectrica) return 'Eléctricos';
    if (esMovilidadReducida) return 'Movilidad Reducida';
    if (esAdministrativa) return 'Administrativas';
    if (esOperativa) return 'Operativas';
    if (tipoCelda.isEmpty) return 'General';
    return tipoCelda[0].toUpperCase() + tipoCelda.substring(1);
  }

  /// Filtros de `Celdas.dart`: "Todas", "Disponible", "Ocupado".
  bool coincideConFiltro(String filtro) {
    final String limpio = filtro.toLowerCase().trim();
    if (limpio.isEmpty || limpio == 'todas' || limpio == 'todos') return true;
    if (limpio == 'disponible' || limpio == 'disponibles' || limpio == 'libre') {
      return disponible;
    }
    if (limpio == 'ocupado' || limpio == 'ocupadas' || limpio == 'ocupada') {
      return ocupada;
    }
    return tipoCelda == limpio;
  }

  /// Búsqueda por código, zona o tipo.
  bool coincideConBusqueda(String termino) {
    final String limpio = termino.toLowerCase().trim();
    if (limpio.isEmpty) return true;
    return codigoCelda.toLowerCase().contains(limpio) ||
        tipoCelda.contains(limpio);
  }

  CeldaModel copyWith({
    int? id,
    String? codigoCelda,
    String? tipoCelda,
    bool? ocupada,
  }) {
    return CeldaModel(
      id: id ?? this.id,
      codigoCelda: codigoCelda ?? this.codigoCelda,
      tipoCelda: tipoCelda ?? this.tipoCelda,
      ocupada: ocupada ?? this.ocupada,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CeldaModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CeldaModel(id: $id, codigo: $codigoCelda, ocupada: $ocupada)';
}
