import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/acceso_model.dart';
import '../../domain/models/historial_acceso_model.dart';
import '../../domain/models/movimiento_turno_model.dart';
import '../../domain/models/resultado_movimiento_model.dart';
import '../../domain/models/vehiculo_activo_model.dart';

/// ParkLink - Servicio de control de accesos (entradas y salidas).
///
/// Endpoints cubiertos:
/// - `GET  /api/admin/historial`             (histórico global)
/// - `POST /api/admin/registrar-acceso`      (registro manual del admin)
/// - `POST /api/vigilante/entrada`           (ingreso con asignación de celda)
/// - `POST /api/vigilante/salida`            (salida con liberación de celda)
/// - `GET  /api/vigilante/historial-turno`   (movimientos del turno activo)
/// - `GET  /api/vigilante/vehiculos-activos` (vehículos aún dentro)
/// - `GET  /api/usuario/historial`           (histórico del usuario)
class AccesoService {
  AccesoService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  // ────────────────────────────────────────────────────────────────────
  // ADMINISTRADOR
  // ────────────────────────────────────────────────────────────────────

  /// Histórico cronológico completo de entradas y salidas.
  Future<List<AccesoModel>> obtenerHistorialGlobal() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.admin}/historial');
    return JsonUtils.parseLista<AccesoModel>(respuesta, AccesoModel.fromJson);
  }

  /// Registra manualmente un movimiento de portería y genera su traza
  /// en la bitácora de auditoría.
  ///
  /// Lanza [BadRequestException] (400) si falta la placa o el tipo de
  /// movimiento.
  Future<ResultadoMovimientoModel> registrarAcceso({
    required String placa,
    required String tipoMovimiento,
    String tipoVehiculo = 'Automóvil',
    String tipoUsuario = 'Funcionario',
    String? celdaAsignada,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.admin}/registrar-acceso',
      cuerpo: JsonUtils.limpiarNulos(<String, dynamic>{
        'placa': placa.trim().toUpperCase(),
        'tipo_movimiento': tipoMovimiento,
        'tipo_vehiculo': tipoVehiculo,
        'tipo_usuario': tipoUsuario,
        'celda_asignada': celdaAsignada,
      }),
    );

    return ResultadoMovimientoModel.fromJson(
      JsonUtils.parseMapa(respuesta),
      esSalida: tipoMovimiento.toLowerCase().trim() == 'salida',
    );
  }

  /// Variante que recibe un [AccesoModel] ya construido.
  Future<ResultadoMovimientoModel> registrarAccesoDesdeModelo(
    AccesoModel acceso,
  ) {
    return registrarAcceso(
      placa: acceso.placa,
      tipoMovimiento: acceso.tipoMovimiento,
      tipoVehiculo: acceso.tipoVehiculo,
      tipoUsuario: acceso.tipoUsuario,
      celdaAsignada: acceso.celdaAsignada,
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // VIGILANTE
  // ────────────────────────────────────────────────────────────────────

  /// Registra el ingreso de un vehículo y le asigna la primera celda libre.
  ///
  /// El Back-End valida, en este orden:
  /// 1. Que el vehículo exista.
  /// 2. Que exista un turno activo del vigilante.
  /// 3. Que haya celdas disponibles.
  /// 4. Que el vehículo no esté ya dentro del parqueadero.
  ///
  /// Cualquier incumplimiento produce 400 -> [BadRequestException].
  Future<ResultadoMovimientoModel> registrarEntrada(String placa) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.vigilante}/entrada',
      cuerpo: <String, dynamic>{'placa': placa.trim().toUpperCase()},
    );
    return ResultadoMovimientoModel.fromJson(JsonUtils.parseMapa(respuesta));
  }

  /// Registra la salida de un vehículo y libera su celda.
  ///
  /// Lanza [BadRequestException] (400) si el vehículo no existe, no hay turno
  /// activo, el vehículo nunca ingresó o ya había salido.
  Future<ResultadoMovimientoModel> registrarSalida(String placa) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.vigilante}/salida',
      cuerpo: <String, dynamic>{'placa': placa.trim().toUpperCase()},
    );
    return ResultadoMovimientoModel.fromJson(
      JsonUtils.parseMapa(respuesta),
      esSalida: true,
    );
  }

  /// Movimientos registrados durante el turno activo del vigilante.
  ///
  /// Lanza [NotFoundException] (404) cuando no hay turno abierto.
  Future<List<MovimientoTurnoModel>> obtenerHistorialTurno() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.vigilante}/historial-turno');
    return JsonUtils.parseLista<MovimientoTurnoModel>(
      respuesta,
      MovimientoTurnoModel.fromJson,
    );
  }

  /// Igual que [obtenerHistorialTurno] pero devuelve una lista vacía en lugar
  /// de lanzar excepción cuando no hay turno activo.
  Future<List<MovimientoTurnoModel>> obtenerHistorialTurnoSeguro() async {
    try {
      return await obtenerHistorialTurno();
    } on NotFoundException {
      return <MovimientoTurnoModel>[];
    }
  }

  /// Vehículos que siguen dentro del parqueadero en el turno activo.
  ///
  /// Lanza [NotFoundException] (404) cuando no hay turno abierto.
  Future<List<VehiculoActivoModel>> obtenerVehiculosActivos() async {
    final dynamic respuesta =
        await _cliente.get('${ApiConfig.vigilante}/vehiculos-activos');
    return JsonUtils.parseLista<VehiculoActivoModel>(
      respuesta,
      VehiculoActivoModel.fromJson,
    );
  }

  /// Igual que [obtenerVehiculosActivos] pero tolerante a la ausencia de turno.
  Future<List<VehiculoActivoModel>> obtenerVehiculosActivosSeguro() async {
    try {
      return await obtenerVehiculosActivos();
    } on NotFoundException {
      return <VehiculoActivoModel>[];
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // USUARIO AUTENTICADO
  // ────────────────────────────────────────────────────────────────────

  /// Histórico de movimientos de los vehículos del usuario en sesión.
  Future<List<HistorialAccesoModel>> obtenerMiHistorial() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.usuario}/historial');
    return JsonUtils.parseLista<HistorialAccesoModel>(
      respuesta,
      HistorialAccesoModel.fromJson,
    );
  }
}
