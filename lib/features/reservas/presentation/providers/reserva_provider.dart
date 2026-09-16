import 'package:flutter/material.dart';

import '../../data/services/reserva_service.dart';
import '../../domain/models/reserva_model.dart';

class ReservaProvider extends ChangeNotifier {
  final ReservaService _reservaService = ReservaService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  List<ReservaModel> _misReservas = [];
  List<ReservaModel> get misReservas => _misReservas;

  /// Carga las reservas del usuario autenticado.
  Future<void> cargarReservas() async {
    _setCargando(true);

    try {
      _misReservas = await _reservaService.obtenerMisReservas();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Registra una nueva reserva.
  Future<bool> registrarReserva({
    required int vehiculoId,
    required String fecha,
    required String hora,
  }) async {
    _setCargando(true);

    try {
      await _reservaService.crearReserva(
        vehiculoId: vehiculoId,
        fecha: fecha,
        hora: hora,
      );

      await cargarReservas();

      _error = '';
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  /// Registra una reserva usando DateTime e información de hora.
  Future<bool> registrarReservaConFecha({
    required int vehiculoId,
    required DateTime fecha,
    required int horaDelDia,
    int minutos = 0,
  }) async {
    _setCargando(true);

    try {
      final String? errorValidacion = _reservaService.validarReserva(
        fecha: fecha,
        horaDelDia: horaDelDia,
      );

      if (errorValidacion != null) {
        _error = errorValidacion;
        return false;
      }

      await _reservaService.crearReservaConFecha(
        vehiculoId: vehiculoId,
        fecha: fecha,
        horaDelDia: horaDelDia,
        minutos: minutos,
      );

      await cargarReservas();

      _error = '';
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  /// Obtiene únicamente las reservas vigentes.
  Future<void> cargarReservasVigentes() async {
    _setCargando(true);

    try {
      _misReservas = await _reservaService.obtenerReservasVigentes();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Obtiene la reserva pendiente del usuario.
  Future<ReservaModel?> obtenerReservaPendiente() async {
    try {
      return await _reservaService.obtenerReservaPendiente();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}