import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/reserva_model.dart';

/// ParkLink - Servicio de reservas de celda.
///
/// Endpoints cubiertos (Blueprint `usuario_bp`):
/// - `GET  /api/usuario/reservas`
/// - `POST /api/usuario/reservas`
///
/// Reglas de negocio que valida el Back-End al crear (`crear_reserva()`):
/// - El vehículo debe pertenecer al usuario autenticado.
/// - La fecha no puede ser pasada ni exceder 7 días de anticipación.
/// - La hora debe estar entre las 06:00 y las 20:00.
/// - El usuario no puede tener más de una reserva pendiente.
/// - El vehículo no puede tener más de una reserva pendiente.
///
/// Cualquier incumplimiento produce 400 -> BadRequestException.
class ReservaService {
  ReservaService({ApiClient? cliente}) : _cliente = cliente ?? ApiClient.instance;

  final ApiClient _cliente;

  /// Ventana máxima de anticipación permitida, en días.
  static const int diasMaximosAnticipacion = 7;

  /// Hora mínima permitida para reservar (formato 24 h).
  static const int horaMinima = 6;

  /// Hora máxima permitida para reservar (formato 24 h).
  static const int horaMaxima = 20;

  /// Lista las reservas del usuario en sesión, de la más reciente
  /// a la más antigua.
  Future<List<ReservaModel>> obtenerMisReservas() async {
    final dynamic respuesta = await _cliente.get('${ApiConfig.usuario}/reservas');
    return JsonUtils.parseLista<ReservaModel>(respuesta, ReservaModel.fromJson);
  }

  /// Sólo las reservas vigentes (pendientes o activas sin vencer).
  Future<List<ReservaModel>> obtenerReservasVigentes() async {
    final List<ReservaModel> reservas = await obtenerMisReservas();
    return reservas.where((ReservaModel reserva) => reserva.esVigente).toList();
  }

  /// Reserva pendiente del usuario, si existe.
  ///
  /// El Back-End sólo permite una a la vez, así que devuelve la primera.
  Future<ReservaModel?> obtenerReservaPendiente() async {
    final List<ReservaModel> reservas = await obtenerMisReservas();
    for (final ReservaModel reserva in reservas) {
      if (reserva.estaPendiente) return reserva;
    }
    return null;
  }

  /// Crea una reserva.
  ///
  /// - [fecha] en formato `yyyy-MM-dd`.
  /// - [hora] en formato `HH:mm`.
  ///
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> crearReserva({
    required int vehiculoId,
    required String fecha,
    required String hora,
  }) async {
    final dynamic respuesta = await _cliente.post(
      '${ApiConfig.usuario}/reservas',
      cuerpo: <String, dynamic>{
        'vehiculo_id': vehiculoId,
        'fecha': fecha,
        'hora': hora,
      },
    );

    return JsonUtils.parseString(
      JsonUtils.primeraLlave(
        JsonUtils.parseMapa(respuesta),
        <String>['mensaje', 'message'],
      ),
      porDefecto: 'Reserva creada correctamente.',
    );
  }

  /// Variante que recibe objetos [DateTime] y los formatea al contrato
  /// esperado por el Back-End.
  Future<String> crearReservaConFecha({
    required int vehiculoId,
    required DateTime fecha,
    required int horaDelDia,
    int minutos = 0,
  }) {
    final String horaTexto = '${horaDelDia.toString().padLeft(2, '0')}:'
        '${minutos.toString().padLeft(2, '0')}';

    return crearReserva(
      vehiculoId: vehiculoId,
      fecha: JsonUtils.formatearFecha(fecha),
      hora: horaTexto,
    );
  }

  /// Valida localmente las reglas de negocio antes de llamar a la API.
  ///
  /// Devuelve `null` si los datos son válidos, o el mensaje de error
  /// correspondiente. Permite mostrar el aviso sin gastar una petición.
  String? validarReserva({
    required DateTime fecha,
    required int horaDelDia,
  }) {
    final DateTime hoy = DateTime.now();
    final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final DateTime fechaLimpia = DateTime(fecha.year, fecha.month, fecha.day);

    if (fechaLimpia.isBefore(inicioHoy)) {
      return 'No puedes reservar fechas pasadas.';
    }

    if (fechaLimpia.difference(inicioHoy).inDays > diasMaximosAnticipacion) {
      return 'Solo puedes reservar con máximo '
          '$diasMaximosAnticipacion días de anticipación.';
    }

    if (horaDelDia < horaMinima || horaDelDia > horaMaxima) {
      return 'Las reservas solo están disponibles entre las '
          '${horaMinima.toString().padLeft(2, '0')}:00 y las $horaMaxima:00.';
    }

    return null;
  }
}
