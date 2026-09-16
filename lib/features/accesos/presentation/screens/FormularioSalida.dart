import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../data/services/acceso_service.dart';
import '../../domain/models/vehiculo_activo_model.dart';

class FormularioSalidaScreen extends StatefulWidget {
  const FormularioSalidaScreen({Key? key}) : super(key: key);

  @override
  State<FormularioSalidaScreen> createState() => _FormularioSalidaScreenState();
}

class _FormularioSalidaScreenState extends State<FormularioSalidaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accesoService = AccesoService();
  final _placaController = TextEditingController();

  Map<String, String>? _vehiculoEncontrado;
  bool _buscando = false;
  bool _procesandoSalida = false;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _buscarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _buscando = true;
      _vehiculoEncontrado = null;
    });

    try {
      final List<VehiculoActivoModel> vehicles = await _accesoService
          .obtenerVehiculosActivosSeguro();
      final String placaBuscada = _placaController.text.trim().toUpperCase();

      VehiculoActivoModel? encontrado;
      for (final vehiculo in vehicles) {
        if (vehiculo.placa == placaBuscada) {
          encontrado = vehiculo;
          break;
        }
      }

      if (!mounted) return;

      if (encontrado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró un vehículo activo con esa placa.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _vehiculoEncontrado = {
          'placa': encontrado!.placa,
          'marca': encontrado.tipoVehiculo,
          'tipo': encontrado.tipoVehiculo,
          'horaEntrada': encontrado.horaIngresoAmPm,
          'espacio': encontrado.celdaTexto,
        };
      });
    } catch (e) {
      if (!mounted) return;
      final String detalle = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detalle), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _buscando = false);
      }
    }
  }

  Future<void> _registrarSalida() async {
    if (_vehiculoEncontrado == null) return;

    setState(() => _procesandoSalida = true);

    try {
      final resultado = await _accesoService.registrarSalida(
        _vehiculoEncontrado!['placa']!,
      );

      if (!mounted) return;

      _placaController.clear();
      setState(() {
        _vehiculoEncontrado = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final String detalle = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detalle), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _procesandoSalida = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          "Registro de Salida",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppTheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Control de Salida Vehicular",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Digita la placa del vehículo para verificar su hora de ingreso y liberar el espacio de estacionamiento.",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _placaController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: "Placa del Vehículo",
                          hintText: "ej. ABC-123",
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Ingresa una placa para buscar";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _buscando ? null : _buscarVehiculo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: _buscando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                ),
                          label: const Text(
                            "Buscar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_vehiculoEncontrado != null) ...[
                  const Text(
                    "Vehículo Encontrado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car_rounded,
                                      color: Colors.green,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _vehiculoEncontrado!["placa"]!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          _vehiculoEncontrado!["marca"]!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Activo en parqueadero",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Hora de Ingreso:",
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                            Flexible(
                              child: Text(
                                _vehiculoEncontrado!["horaEntrada"]!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ubicación asignada:",
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                            Flexible(
                              child: Text(
                                _vehiculoEncontrado!["espacio"]!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _procesandoSalida
                                ? null
                                : _registrarSalida,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: _procesandoSalida
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.exit_to_app_rounded,
                                    color: Colors.white,
                                  ),
                            label: const Text(
                              "Confirmar Salida del Vehículo",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
