import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class FormularioVisitantesScreen extends StatefulWidget {
  const FormularioVisitantesScreen({Key? key}) : super(key: key);

  @override
  State<FormularioVisitantesScreen> createState() => _FormularioVisitantesScreenState();
}

class _FormularioVisitantesScreenState extends State<FormularioVisitantesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del visitante
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _placaController = TextEditingController();
  final _empresaController = TextEditingController();
  final _motivoController = TextEditingController();
  
  String _tipoVehiculo = "Carro";
  bool _estaRegistrando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _placaController.dispose();
    _empresaController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  void _registrarVisitante() {
    if (_formKey.currentState!.validate()) {
      setState(() => _estaRegistrando = true);

      // Simulamos un registro exitoso
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _estaRegistrando = false);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Visitante registrado con éxito! Acceso autorizado."),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _formKey.currentState!.reset();
        _nombreController.clear();
        _documentoController.clear();
        _placaController.clear();
        _empresaController.clear();
        _motivoController.clear();
        setState(() => _tipoVehiculo = "Carro");
      });
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
          "Registro de Visitantes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
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
                        const Icon(Icons.badge_rounded, color: AppTheme.primary, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Control de Acceso Temporal",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Ingresa los datos correspondientes para registrar la entrada del visitante a las instalaciones de Redeban.",
                                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Información Personal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 14),

                  // Nombre Completo
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Nombre Completo del Visitante",
                      hintText: "ej. Carlos Andrés Pérez",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Por favor ingresa el nombre del visitante";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Número de Documento y Empresa
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _documentoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Número de Documento",
                            hintText: "ej. 10203040",
                            prefixIcon: const Icon(Icons.credit_card_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Ingresa el documento";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _empresaController,
                          decoration: InputDecoration(
                            labelText: "Empresa de Procedencia",
                            hintText: "ej. Proveedor S.A.",
                            prefixIcon: const Icon(Icons.business_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Información del Vehículo / Ingreso",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 14),

                  // Selector de tipo de vehículo
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _tipoVehiculo = "Carro"),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoVehiculo == "Carro"
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: _tipoVehiculo == "Carro"
                                    ? AppTheme.primary
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_rounded,
                                  color: _tipoVehiculo == "Carro"
                                      ? AppTheme.primary
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Carro",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _tipoVehiculo == "Carro"
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _tipoVehiculo = "Moto"),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoVehiculo == "Moto"
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: _tipoVehiculo == "Moto"
                                    ? AppTheme.primary
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.two_wheeler_rounded,
                                  color: _tipoVehiculo == "Moto"
                                      ? AppTheme.primary
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Moto",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _tipoVehiculo == "Moto"
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Placa
                  TextFormField(
                    controller: _placaController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: "Placa del Vehículo",
                      hintText: "ej. XYZ-789 (Opcional si viene a pie)",
                      prefixIcon: const Icon(Icons.directions_car_filled_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Motivo de Visita
                  TextFormField(
                    controller: _motivoController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Motivo de la Visita",
                      hintText: "ej. Reunión con el área de sistemas / Mantenimiento",
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Por favor ingresa el motivo de la visita";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botón Registrar Acceso
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _estaRegistrando ? null : _registrarVisitante,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _estaRegistrando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Registrar Acceso de Visitante",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
    );
  }
}