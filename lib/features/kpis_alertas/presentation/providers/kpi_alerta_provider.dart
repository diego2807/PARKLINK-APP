import 'package:flutter/material.dart';

import '../../data/services/kpi_service.dart';
import '../../data/services/alerta_service.dart';
import '../../data/services/notificacion_service.dart';
import '../../domain/models/kpi_model.dart';
import '../../domain/models/kpi_ocupacion_model.dart';
import '../../domain/models/alerta_model.dart';

class KpiAlertaProvider extends ChangeNotifier {
  final KpiService _kpiService = KpiService();
  final AlertaService _alertaService = AlertaService();
  final NotificacionService _notificacionService =
      NotificacionService();

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  // ============================================================
  // ESTADOS DE LOS DATOS DEL MÓDULO
  // ============================================================

  KpiModel? _metricasKpi;
  KpiModel? get metricasKpi => _metricasKpi;

  KpiOcupacionModel? _ocupacion;
  KpiOcupacionModel? get ocupacion => _ocupacion;

  List<AlertaModel> _alertas = [];
  List<AlertaModel> get alertas => _alertas;

  List _notificaciones = [];
  List get notificaciones => _notificaciones;

  // ============================================================
  // CARGAR KPIS
  // ============================================================

  /// Carga las métricas principales del dashboard.
  Future<void> cargarKpis() async {
    _setCargando(true);

    try {
      _metricasKpi = await _kpiService.obtenerKpis();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ============================================================
  // CARGAR OCUPACIÓN
  // ============================================================

  /// Carga la ocupación global y por perfil.
  Future<void> cargarOcupacion() async {
    _setCargando(true);

    try {
      _ocupacion = await _kpiService.obtenerOcupacion();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ============================================================
  // CARGAR DASHBOARD COMPLETO
  // ============================================================

  /// Carga KPIs y ocupación en paralelo.
  Future<void> cargarDashboard() async {
    _setCargando(true);

    try {
      final resultado = await _kpiService.obtenerDashboard();

      _metricasKpi = resultado.kpis;
      _ocupacion = resultado.ocupacion;

      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ============================================================
  // CARGAR ALERTAS
  // ============================================================

  /// Carga el listado de alertas.
  Future<void> cargarAlertas() async {
    _setCargando(true);

    try {
      _alertas = await _alertaService.obtenerAlertas();
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ============================================================
  // CARGAR NOTIFICACIONES
  // ============================================================

  /// Carga las notificaciones del sistema.
  Future<void> cargarNotificaciones() async {
    _setCargando(true);

    try {
      _notificaciones =
          await _notificacionService.obtenerNotificaciones();

      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ============================================================
  // PUBLICAR ALERTA
  // ============================================================

  /// Publica un nuevo comunicado o alerta manual.
  Future<bool> publicarAlerta({
    required String titulo,
    required String contenido,
    SeveridadAlerta severidad = SeveridadAlerta.informativo,
  }) async {
    try {
      final String mensaje = await _alertaService.publicarAlerta(
        titulo: titulo,
        contenido: contenido,
        severidad: severidad,
      );

      // El backend devuelve un mensaje, no un bool.
      // Si llegamos aquí, la operación fue exitosa.
      _error = '';

      await cargarAlertas();

      return mensaje.isNotEmpty;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // ELIMINAR ALERTA
  // ============================================================

  /// Descarta o elimina una alerta del panel.
  Future<bool> eliminarAlerta(int alertaId) async {
    try {
      final String mensaje =
          await _alertaService.eliminarAlerta(alertaId);

      // El backend devuelve un mensaje, no un bool.
      // Si llegamos aquí, la operación fue exitosa.
      _error = '';

      _alertas.removeWhere(
        (AlertaModel alerta) => alerta.id == alertaId,
      );

      notifyListeners();

      return mensaje.isNotEmpty;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // ESTADO DE CARGA
  // ============================================================

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}