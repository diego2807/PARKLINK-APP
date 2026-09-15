import '../../../../core/utils/json_utils.dart';

/// Perfiles de cupo aceptados por `POST /api/admin/ingresos/validar-cupo`.
///
/// Son los tres valores que el Back-End reconoce en `tipo_usuario`.
enum PerfilCupo {
  administrativo('admin', 'Administrativos'),
  operativo('operativo', 'Operativos / Técnicos'),
  movilidad('movilidad', 'Movilidad Reducida / Eléctricos');

  const PerfilCupo(this.valor, this.etiqueta);

  /// Texto que espera el Back-End en el payload.
  final String valor;

  /// Nombre legible de la categoría.
  final String etiqueta;

  static PerfilCupo desdeTexto(dynamic valor) {
    final String texto = JsonUtils.parseString(valor).toLowerCase().trim();
    for (final PerfilCupo perfil in PerfilCupo.values) {
      if (perfil.valor == texto || perfil.name.toLowerCase() == texto) {
        return perfil;
      }
    }
    return PerfilCupo.operativo;
  }
}

/// Resultado de validar la disponibilidad de cupo antes de un ingreso.
///
/// Contrato: `validar_cupo_parqueo()` en `app/routes/admin.py`.
///
/// - 200 -> `{"status": "autorizado", "message": "..."}`
/// - 403 -> `{"status": "denegado",   "message": "..."}`
///
/// El servicio convierte el 403 en una instancia con [autorizado] en `false`
/// en lugar de lanzar excepción, porque la denegación es un resultado de
/// negocio esperado, no un error.
class ValidacionCupoModel {
  /// "autorizado" o "denegado".
  final String status;

  /// Mensaje explicativo devuelto por el servidor.
  final String mensaje;

  /// Perfil consultado.
  final PerfilCupo perfil;

  const ValidacionCupoModel({
    required this.status,
    required this.mensaje,
    required this.perfil,
  });

  factory ValidacionCupoModel.fromJson(
    Map<String, dynamic> json, {
    required PerfilCupo perfil,
  }) {
    return ValidacionCupoModel(
      status: JsonUtils.parseString(json['status'], porDefecto: 'denegado')
          .toLowerCase(),
      mensaje: JsonUtils.parseString(
        JsonUtils.primeraLlave(json, <String>['message', 'mensaje', 'error']),
        porDefecto: 'No fue posible validar el cupo disponible.',
      ),
      perfil: perfil,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'message': mensaje,
      'tipo_usuario': perfil.valor,
    };
  }

  /// `true` cuando hay cupo disponible para el perfil consultado.
  bool get autorizado => status == 'autorizado';

  /// `true` cuando los cupos de la categoría están agotados.
  bool get denegado => !autorizado;

  /// Etiqueta legible de la categoría evaluada.
  String get categoria => perfil.etiqueta;

  @override
  String toString() =>
      'ValidacionCupoModel(status: $status, perfil: ${perfil.valor})';
}
