import 'package:flutter/material.dart';

import '../../data/services/tendencia_service.dart';
import '../../domain/models/tendencia_model.dart';

class TendenciaProvider extends ChangeNotifier {
  final TendenciaService _tendenciaService = TendenciaService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  TendenciaModel? _tendencia;
  TendenciaModel? get tendencia => _tendencia;

  /// Carga los datos de tendencias y estadísticas
  /// desde el backend de Flask.
  Future<void> cargarTendencias() async {
    _setCargando(true);

    try {
      _tendencia = await _tendenciaService.obtenerTendencias();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Carga las tendencias correspondientes a hoy.
  Future<void> cargarTendenciasDeHoy() async {
    _setCargando(true);

    try {
      _tendencia =
          await _tendenciaService.obtenerTendenciasDeHoy();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Carga las tendencias correspondientes a la semana.
  Future<void> cargarTendenciasDeLaSemana() async {
    _setCargando(true);

    try {
      _tendencia =
          await _tendenciaService.obtenerTendenciasDeLaSemana();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Carga las tendencias correspondientes al mes.
  Future<void> cargarTendenciasDelMes() async {
    _setCargando(true);

    try {
      _tendencia =
          await _tendenciaService.obtenerTendenciasDelMes();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}