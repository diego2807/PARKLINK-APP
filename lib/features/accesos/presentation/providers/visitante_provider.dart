import 'package:flutter/material.dart';
import '../../data/services/visitante_service.dart';

class VisitanteProvider extends ChangeNotifier {
  final VisitanteService _service = VisitanteService();

  bool _registrando = false;
  bool get registrando => _registrando;

  Future registrarVisitante({
    required String nombreCompleto,
    required String documento,
    required String placaVehiculo,
    required String areaVisitada,
    required String motivoVisita,
  }) async {
    _registrando = true;
    notifyListeners();

    try {
      final mensaje = await _service.registrarVisitante(
        nombreCompleto: nombreCompleto,
        documento: documento,
        placaVehiculo: placaVehiculo,
        areaVisitada: areaVisitada,
        motivoVisita: motivoVisita,
      );
      return mensaje;
    } catch (e) {
      return null;
    } finally {
      _registrando = false;
      notifyListeners();
    }
  }
}