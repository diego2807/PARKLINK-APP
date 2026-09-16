import 'package:flutter/material.dart';

import '../../data/services/celda_service.dart';
import '../../domain/models/celda_model.dart';

class CeldaProvider extends ChangeNotifier {
  final CeldaService _celdaService = CeldaService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  List<CeldaModel> _celdas = [];
  List<CeldaModel> get celdas => _celdas;

  /// Carga el mapa actual de celdas desde el backend de Flask.
  Future<void> cargarCeldas() async {
    _setCargando(true);

    try {
      _celdas = await _celdaService.obtenerCeldas();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  /// Cambia el estado de ocupación de una celda.
  Future<void> cambiarEstadoCelda(
    int celdaId,
    bool ocupada, {
    String tipoCelda = 'operativas',
  }) async {
    try {
      await _celdaService.cambiarEstadoCelda(
        celdaId: celdaId,
        ocupada: ocupada,
        tipoCelda: tipoCelda,
      );

      await cargarCeldas();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}