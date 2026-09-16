import 'package:flutter/material.dart';
import '../../data/services/acceso_service.dart';
import '../../domain/models/acceso_model.dart';
import '../../domain/models/vehiculo_activo_model.dart';

class AccesoProvider extends ChangeNotifier {
  final AccesoService _accesoService = AccesoService();

  List _historial = [];
  List get historial => _historial;

  bool _cargando = false;
  bool get cargando => _cargando;

  String _error = '';
  String get error => _error;

  // 💡 Extraemos la lógica que tenías en Historial.dart
  Future cargarHistorial() async {
    _cargando = true;
    _error = '';
    notifyListeners(); // 📢 Avisa a la UI que muestre el CircularProgressIndicator

    try {
      _historial = await _accesoService.obtenerHistorialGlobal();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _cargando = false;
      notifyListeners(); // 📢 Avisa a la UI que ya terminó de cargar
    }
  }

  // Añade esto dentro de tu clase AccesoProvider
  Future registrarEntrada(String placa) async {
    try {
      final resultado = await _accesoService.registrarEntrada(placa);
      // Si quieres, aquí mismo podrías llamar a cargarVehiculosActivos() 
      // para que la lista se actualice sola en segundo plano.
      _error = '';
      return resultado;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    }
  }
}