import 'package:flutter/material.dart';

import '../../data/services/configuracion_service.dart';
import '../../domain/models/configuracion_model.dart';

class ConfiguracionProvider extends ChangeNotifier {
  final ConfiguracionService _configService = ConfiguracionService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  ConfiguracionModel? _configData;
  ConfiguracionModel? get configData => _configData;

  /// Carga la configuración global del sistema desde Flask.
  Future<void> cargarConfiguracion() async {
    _setCargando(true);

    try {
      _configData = await _configService.obtenerConfiguracion();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Actualiza la configuración completa del sistema.
  Future<bool> actualizarConfiguracion(
    ConfiguracionModel nuevosDatos,
  ) async {
    _setCargando(true);

    try {
      _configData =
          await _configService.actualizarConfiguracion(nuevosDatos);

      _error = '';

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setCargando(false);
    }
  }

  /// Actualiza únicamente los campos indicados.
  Future<bool> actualizarParcial({
    String? horaApertura,
    String? horaCierre,
    bool? permitirFestivos,
    int? tiempoMaximo,
    AccionExceso? accionExceso,
    int? celdasAdmin,
    int? celdasOperativas,
    int? celdasMovilidad,
  }) async {
    _setCargando(true);

    try {
      _configData = await _configService.actualizarParcial(
        horaApertura: horaApertura,
        horaCierre: horaCierre,
        permitirFestivos: permitirFestivos,
        tiempoMaximo: tiempoMaximo,
        accionExceso: accionExceso,
        celdasAdmin: celdasAdmin,
        celdasOperativas: celdasOperativas,
        celdasMovilidad: celdasMovilidad,
      );

      _error = '';

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setCargando(false);
    }
  }

  /// Guarda la configuración y devuelve el mensaje del servidor.
  Future<String?> guardarYObtenerMensaje(
    ConfiguracionModel configuracion,
  ) async {
    _setCargando(true);

    try {
      final mensaje =
          await _configService.guardarYObtenerMensaje(configuracion);

      _configData = configuracion;
      _error = '';

      return mensaje;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setCargando(false);
    }
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}