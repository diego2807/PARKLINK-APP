import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class FormularioSalidaScreen extends StatefulWidget {
  const FormularioSalidaScreen({Key? key}) : super(key: key);

  @override
  State<FormularioSalidaScreen> createState() => _FormularioSalidaScreenState();
}

class _FormularioSalidaScreenState extends State<FormularioSalidaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();

  // Simulación de un vehículo encontrado dentro del parqueadero
  Map<String, String>? _vehiculoEncontrado;
  bool _buscando = false;
  bool _procesandoSalida = false;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  // Método simulado para buscar la placa activa en el sistema
  void _buscarVehiculo() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _buscando = true;
        _vehiculoEncontrado = null;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _buscando = false;
          String placaBuscada = _placaController.text.toUpperCase().trim();
          
          // Simulamos datos encontrados para cualquier placa ingresada
          _vehiculoEncontrado = {
            "placa": placaBuscada,
            "marca": "Mazda 3 - Gris",
            "tipo": "Carro",
            "horaEntrada": "08:30 AM",
            "espacio": "Parqueadero Principal - Espacio 12",
          };
        });
      });
    }
  }

  // Método para procesar la salida definitiva
  void _registrarSalida() {
    if (_vehiculoEncontrado == null) return;

    setState(() => _procesandoSalida = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _procesandoSalida = false;
        _vehiculoEncontrado = null;
      });
      _placaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Salida registrada con éxito! Vuelva pronto."),
          backgroundColor: Colors.green,
        ),
      );
    });
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
                // Tarjeta informativa superior
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
                      const Icon(Icons.logout_rounded, color: AppTheme.primary, size: 32),
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
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Formulario de búsqueda por placa
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _placaController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: "Placa del Vehículo",
                            hintText: "ej. ABC-123",
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _buscando ? null : _buscarVehiculo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: _buscando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.search_rounded, color: Colors.white),
                          label: const Text(
                            "Buscar",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mostrar tarjeta de detalles si el vehículo fue encontrado
                if (_vehiculoEncontrado != null) ...[
                  const Text(
                    "Vehículo Encontrado",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
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
                      border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.directions_car_rounded, color: Colors.green, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _vehiculoEncontrado!["placa"]!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      _vehiculoEncontrado!["marca"]!,
                                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Activo en parqueadero",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
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
                            const Text("Hora de Ingreso:", style: TextStyle(color: AppTheme.textMuted)),
                            Text(_vehiculoEncontrado!["horaEntrada"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Ubicación asignada:", style: TextStyle(color: AppTheme.textMuted)),
                            Text(_vehiculoEncontrado!["espacio"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Botón de confirmar salida
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _procesandoSalida ? null : _registrarSalida,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: _procesandoSalida
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.exit_to_app_rounded, color: Colors.white),
                            label: const Text(
                              "Confirmar Salida del Vehículo",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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