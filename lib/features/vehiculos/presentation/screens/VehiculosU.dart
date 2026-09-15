import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class UserVehiclesScreen extends StatefulWidget {
  const UserVehiclesScreen({Key? key}) : super(key: key);

  @override
  State<UserVehiclesScreen> createState() => _UserVehiclesScreenState();
}

class _UserVehiclesScreenState extends State<UserVehiclesScreen> {
  // Lista dinámica de vehículos
  final List<Map<String, String>> vehiculos = [
    {
      "placa": "ABC-123",
      "marca": "Mazda 3 - Gris",
      "tipo": "Carro",
      "principal": "Sí"
    },
    {
      "placa": "XYZ-987",
      "marca": "Yamaha FZ - Negra",
      "tipo": "Moto",
      "principal": "No"
    },
  ];

  // Controladores para el formulario de nuevo vehículo
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  String _tipoSeleccionado = "Carro";

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  // Método para eliminar un vehículo
  void _eliminarVehiculo(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirmar eliminación"),
        content: Text("¿Deseas eliminar el vehículo ${vehiculos[index]['placa']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                vehiculos.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Vehículo eliminado exitosamente")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Modal para agregar un nuevo vehículo
  void _mostrarModalAgregar() {
    _placaController.clear();
    _marcaController.clear();
    _tipoSeleccionado = "Carro";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Registrar Nuevo Vehículo",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Ingresa los datos del vehículo corporativo o personal",
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),

                    // Selector de tipo (Carro / Moto)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => _tipoSeleccionado = "Carro"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tipoSeleccionado == "Carro"
                                    ? AppTheme.primary.withOpacity(0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: _tipoSeleccionado == "Carro"
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
                                    color: _tipoSeleccionado == "Carro"
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Carro",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _tipoSeleccionado == "Carro"
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
                            onTap: () => setModalState(() => _tipoSeleccionado = "Moto"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tipoSeleccionado == "Moto"
                                    ? AppTheme.primary.withOpacity(0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: _tipoSeleccionado == "Moto"
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
                                    color: _tipoSeleccionado == "Moto"
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Moto",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _tipoSeleccionado == "Moto"
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
                    const SizedBox(height: 16),

                    // Campo Placa
                    TextFormField(
                      controller: _placaController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: "Placa del Vehículo",
                        hintText: "ej. ABC-123",
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Por favor ingresa la placa";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Campo Marca / Modelo
                    TextFormField(
                      controller: _marcaController,
                      decoration: InputDecoration(
                        labelText: "Marca y Color",
                        hintText: "ej. Mazda 3 - Gris",
                        prefixIcon: const Icon(Icons.time_to_leave_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Por favor ingresa la marca/color";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              vehiculos.add({
                                "placa": _placaController.text.toUpperCase().trim(),
                                "marca": _marcaController.text.trim(),
                                "tipo": _tipoSeleccionado,
                                "principal": vehiculos.isEmpty ? "Sí" : "No",
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Vehículo registrado con éxito")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Guardar Vehículo",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text("Mis Vehículos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalAgregar,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Agregar Vehículo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado descriptivo y contador
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Vehículos Registrados",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tienes ${vehiculos.length} vehículo(s) activo(s)",
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${vehiculos.length} / 3 Máx",
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de vehículos
              Expanded(
                child: vehiculos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text("No tienes vehículos registrados", style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _mostrarModalAgregar,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Registrar primero", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: vehiculos.length,
                        itemBuilder: (context, index) {
                          final v = vehiculos[index];
                          bool esCarro = v["tipo"] == "Carro";
                          bool esPrincipal = v["principal"] == "Sí";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: esPrincipal ? AppTheme.primary.withOpacity(0.3) : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Icono representativo
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: esCarro ? AppTheme.primary.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    esCarro ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                                    color: esCarro ? AppTheme.primary : Colors.orange[800],
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Información
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            v["placa"]!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (esPrincipal)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                "Principal",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${v['tipo']} • ${v['marca']}",
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),

                                // Acciones
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  tooltip: "Eliminar vehículo",
                                  onPressed: () => _eliminarVehiculo(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}