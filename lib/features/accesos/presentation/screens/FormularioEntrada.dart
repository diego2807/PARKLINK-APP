import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../data/services/acceso_service.dart';

class FormularioEntradaScreen extends StatefulWidget {
  const FormularioEntradaScreen({super.key});

  @override
  State<FormularioEntradaScreen> createState() =>
      _FormularioEntradaScreenState();
}

class _FormularioEntradaScreenState extends State<FormularioEntradaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accesoService = AccesoService();
  final _placaController = TextEditingController();
  final _conductorController = TextEditingController();

  String _tipoVehiculo = "Carro";
  String _zona = "Torre A - Piso 1";
  String? _celda = "A-03";
  bool _cargando = false;

  final List<String> _zonas = [
    "Torre A - Piso 1",
    "Torre A - Piso 2",
    "Sótano 1 - General",
    "Sótano 2 - VIP",
  ];

  final Map<String, List<String>> _celdasDisponibles = {
    "Torre A - Piso 1": ["A-01", "A-03", "A-04", "A-06", "A-08", "A-09"],
    "Torre A - Piso 2": ["B-03", "B-04", "B-05"],
    "Sótano 1 - General": ["S1-01", "S1-02", "S1-04"],
    "Sótano 2 - VIP": ["VIP-01"],
  };

  @override
  void dispose() {
    _placaController.dispose();
    _conductorController.dispose();
    super.dispose();
  }

  void _onZonaChanged(String? nuevaZona) {
    if (nuevaZona == null) return;
    setState(() {
      _zona = nuevaZona;
      final celdas = _celdasDisponibles[_zona] ?? [];
      _celda = celdas.isNotEmpty ? celdas.first : null;
    });
  }

  Future<void> _registrarEntrada() async {
    if (!_formKey.currentState!.validate()) return;
    if (_celda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay celdas disponibles en esta zona")),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final resultado = await _accesoService.registrarEntrada(
        _placaController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.detalle),
          backgroundColor: AppTheme.success,
        ),
      );

      _formKey.currentState!.reset();
      _placaController.clear();
      _conductorController.clear();
      setState(() {
        _tipoVehiculo = "Carro";
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Entrada Registrada",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            "Vehículo ${_placaController.text.trim().toUpperCase()} asignado a la celda $_celda.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Aceptar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final String mensaje = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Widget _tipoChip(String tipo, IconData icon) {
    final bool seleccionado = _tipoVehiculo == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoVehiculo = tipo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: seleccionado ? AppTheme.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? AppTheme.primary : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: seleccionado ? Colors.white : AppTheme.textMuted,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                tipo,
                style: TextStyle(
                  color: seleccionado ? Colors.white : AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final celdas = _celdasDisponibles[_zona] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.success,
        elevation: 0,
        title: const Text(
          "Registrar Entrada",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tipo de Vehículo",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _tipoChip("Carro", Icons.directions_car_rounded),
                        _tipoChip("Moto", Icons.two_wheeler_rounded),
                        _tipoChip("Camioneta", Icons.airport_shuttle_rounded),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _placaController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: AppTheme.inputStyle(
                        "Placa del vehículo",
                        Icons.confirmation_number_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Ingresa la placa";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _conductorController,
                      textCapitalization: TextCapitalization.words,
                      decoration: AppTheme.inputStyle(
                        "Nombre del conductor",
                        Icons.person_outline_rounded,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Ingresa el nombre";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _zona,
                      decoration: AppTheme.inputStyle(
                        "Zona",
                        Icons.map_outlined,
                      ),
                      items: _zonas
                          .map(
                            (z) => DropdownMenuItem(
                              value: z,
                              child: Text(
                                z,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _onZonaChanged,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: celdas.contains(_celda) ? _celda : null,
                      decoration: AppTheme.inputStyle(
                        "Celda asignada",
                        Icons.local_parking_rounded,
                      ),
                      items: celdas
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _celda = val),
                      validator: (v) =>
                          v == null ? "Selecciona una celda" : null,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Función de cámara no disponible en esta demo",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppTheme.primary,
                      ),
                      label: const Text(
                        "Tomar foto del vehículo",
                        style: TextStyle(color: AppTheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _registrarEntrada,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _cargando
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Registrar Entrada",
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
            ),
          ),
        ),
      ),
    );
  }
}
