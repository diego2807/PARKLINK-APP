import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/vehiculo_admin_model.dart';
import '../../domain/models/vehiculo_consulta_model.dart';
import '../../domain/models/vehiculo_model.dart';

/// ParkLink - Servicio del módulo de vehículos.
///
/// Endpoints cubiertos:
/// - `GET    /api/admin/vehiculos`            (listado global, sólo admin)
/// - `POST   /api/admin/vehiculos`            (vincular vehículo a funcionario)
/// - `DELETE /api/admin/vehiculos/<id>`       (dar de baja)
/// - `GET    /api/usuario/vehiculos`          (mis vehículos)
/// - `POST   /api/usuario/vehiculos`          (registrar mi vehículo)
/// - `GET    /api/vigilante/vehiculo/<placa>` (consulta de placa en portería)
class VehiculoService {
  VehiculoService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  // ────────────────────────────────────────────────────────────────────
  // ADMINISTRADOR
  // ────────────────────────────────────────────────────────────────────

  /// Lista todos los vehículos autorizados de la empresa.
  ///
  /// Requiere rol `administrador`; en caso contrario el Back-End responde
  /// 403 y se lanza [ForbiddenException].
  Future<List<VehiculoAdminModel>> obtenerVehiculosAdmin() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.admin}/vehiculos');
    return JsonUtils.parseLista<VehiculoAdminModel>(
      respuesta,
      VehiculoAdminModel.fromJson,
    );
  }

  /// Vincula un vehículo a un funcionario.
  ///
  /// Si el funcionario no existe, el Back-End lo crea automáticamente con un
  /// correo interno `@parklink.local`. Devuelve los datos del vehículo creado.
  ///
  /// Lanza [BadRequestException] (400) si la placa ya está registrada o si
  /// faltan campos obligatorios.
  Future<VehiculoAdminModel> vincularVehiculo({
    required String nombreFuncionario,
    required String placa,
    String tipoVehiculo = 'Automóvil',
    String area = 'Tecnología',
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.admin}/vehiculos',
      cuerpo: <String, dynamic>{
        'nombre_funcionario': nombreFuncionario.trim(),
        'placa': placa.trim().toUpperCase(),
        'tipo_vehiculo': tipoVehiculo,
        'area': area,
      },
    );

    final Map<String, dynamic> mapa = JsonUtils.parseMapa(respuesta);
    return VehiculoAdminModel.fromJson(JsonUtils.parseMapa(mapa['vehiculo']));
  }

  /// Da de baja un vehículo por su identificador.
  ///
  /// Devuelve el mensaje de confirmación del servidor.
  /// Lanza [NotFoundException] (404) si el vehículo no existe y
  /// [ForbiddenException] (403) si el rol no es administrador.
  Future<String> eliminarVehiculo(int vehiculoId) async {
    final dynamic respuesta =
        await _cliente.delete('${ApiConfig.admin}/vehiculos/$vehiculoId');

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['message', 'mensaje'],
      ),
      porDefecto: 'El vehículo ha sido dado de baja correctamente.',
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // USUARIO AUTENTICADO
  // ────────────────────────────────────────────────────────────────────

  /// Lista los vehículos del usuario en sesión.
  Future<List<VehiculoModel>> obtenerMisVehiculos() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.usuario}/vehiculos');
    return JsonUtils.parseLista<VehiculoModel>(respuesta, VehiculoModel.fromJson);
  }

  /// Registra un vehículo propio.
  ///
  /// El Back-End fuerza `area = "Funcionario"` y exige `placa` y
  /// `tipo_vehiculo`. Lanza [BadRequestException] (400) si la placa ya existe.
  ///
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> registrarMiVehiculo({
    required String placa,
    required String tipoVehiculo,
    String? marca,
    String? color,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.usuario}/vehiculos',
      cuerpo: JsonUtils.limpiarNulos(<String, dynamic>{
        'placa': placa.trim().toUpperCase(),
        'tipo_vehiculo': tipoVehiculo,
        'marca': marca?.trim(),
        'color': color?.trim(),
      }),
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['mensaje', 'message'],
      ),
      porDefecto: 'Vehículo registrado correctamente.',
    );
  }

  /// Variante que recibe directamente un [VehiculoModel] ya construido.
  Future<String> registrarMiVehiculoDesdeModelo(VehiculoModel vehiculo) {
    return registrarMiVehiculo(
      placa: vehiculo.placa,
      tipoVehiculo: vehiculo.tipoVehiculo,
      marca: vehiculo.marca,
      color: vehiculo.color,
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // VIGILANTE
  // ────────────────────────────────────────────────────────────────────

  /// Consulta una placa en portería.
  ///
  /// Lanza [NotFoundException] (404) cuando el vehículo no está registrado.
  Future<VehiculoConsultaModel> consultarPorPlaca(String placa) async {
    final String placaLimpia = placa.trim().toUpperCase();
    final dynamic respuesta = await _cliente.get(
      '${ApiConfig.vigilante}/vehiculo/${Uri.encodeComponent(placaLimpia)}',
    );
    return VehiculoConsultaModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Versión tolerante de [consultarPorPlaca]: devuelve `null` en lugar de
  /// lanzar excepción cuando la placa no existe (útil para búsquedas en vivo).
  Future<VehiculoConsultaModel?> buscarPorPlaca(String placa) async {
    try {
      return await consultarPorPlaca(placa);
    } on NotFoundException {
      return null;
    }
  }
}
