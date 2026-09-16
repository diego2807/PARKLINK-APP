import 'package:flutter/material.dart';

import '../../data/services/log_service.dart';
import '../../domain/models/log_auditoria_model.dart';

class AuditoriaProvider extends ChangeNotifier {
  final LogService _logService = LogService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  List<LogAuditoriaModel> _logs = [];
  List<LogAuditoriaModel> get logs => _logs;

  /// Carga el historial de logs aplicando filtros opcionales
  /// de búsqueda y severidad.
  Future<void> cargarLogs({
    String? termino,
    String? severidad,
  }) async {
    _setCargando(true);

    try {
      NivelLog? nivel;

      if (severidad != null && severidad != 'todos') {
        nivel = NivelLog.values.firstWhere(
          (e) => e.valor == severidad,
        );
      }

      _logs = await _logService.obtenerLogs(
        termino: termino,
        severidad: nivel,
      );

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
