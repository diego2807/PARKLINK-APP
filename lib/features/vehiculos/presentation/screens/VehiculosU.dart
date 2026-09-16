import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../data/services/vehiculo_service.dart';
import '../../domain/models/vehiculo_model.dart';

class UserVehiclesScreen extends StatefulWidget {
  const UserVehiclesScreen({super.key});

  @override
  State<UserVehiclesScreen> createState() => _UserVehiclesScreenState();
}

class _UserVehiclesScreenState extends State<UserVehiclesScreen> {
  final VehiculoService _vehiculoService = VehiculoService();
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  String _tipoSeleccionado = 'Carro';
  List<VehiculoModel> _vehiculos = <VehiculoModel>[];
  late Future<List<VehiculoModel>> _vehiculosFuture;

  @override
  void initState() {
    super.initState();
    _vehiculosFuture = _cargarVehiculos();
  }

  Future<List<VehiculoModel>> _cargarVehiculos() async {
    final lista = await _vehiculoService.obtenerMisVehiculos();
    if (mounted) {
      setState(() => _vehiculos = lista);
    }
    return lista;
  }

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  Future<void> _mostrarModalAgregar() async {
    _placaController.clear();
    _marcaController.clear();
    _tipoSeleccionado = 'Carro';
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet(
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
                      'Registrar Nuevo Vehículo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ingresa los datos del vehículo corporativo o personal',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(
                              () => _tipoSeleccionado = 'Carro',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tipoSeleccionado == 'Carro'
                                    ? AppTheme.primary.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: _tipoSeleccionado == 'Carro'
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
                                    color: _tipoSeleccionado == 'Carro'
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Carro',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _tipoSeleccionado == 'Carro'
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
                            onTap: () =>
                                setModalState(() => _tipoSeleccionado = 'Moto'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tipoSeleccionado == 'Moto'
                                    ? AppTheme.primary.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: _tipoSeleccionado == 'Moto'
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
                                    color: _tipoSeleccionado == 'Moto'
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Moto',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _tipoSeleccionado == 'Moto'
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
                    TextFormField(
                      controller: _placaController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Placa del Vehículo',
                        hintText: 'ej. ABC-123',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Por favor ingresa la placa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _marcaController,
                      decoration: InputDecoration(
                        labelText: 'Marca y Color',
                        hintText: 'ej. Mazda 3 - Gris',
                        prefixIcon: const Icon(Icons.time_to_leave_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Por favor ingresa la marca/color';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          if (!mounted) return;

                          try {
                            final tipoServicio = _tipoSeleccionado == 'Moto'
                                ? 'Motocicleta'
                                : 'Automóvil';

                            final mensaje = await _vehiculoService
                                .registrarMiVehiculo(
                                  placa: _placaController.text,
                                  tipoVehiculo: tipoServicio,
                                  marca: _marcaController.text
                                      .trim()
                                      .split('-')
                                      .first
                                      .trim(),
                                  color:
                                      _marcaController.text.trim().contains('-')
                                      ? _marcaController.text
                                            .trim()
                                            .split('-')
                                            .last
                                            .trim()
                                      : null,
                                );

                            if (!mounted) return;

                            if (!navigator.mounted) return;

                            final nuevoVehiculo = VehiculoModel(
                              id: DateTime.now().millisecondsSinceEpoch,
                              placa: _placaController.text.trim(),
                              tipoVehiculo: tipoServicio,
                              marca: _marcaController.text
                                  .trim()
                                  .split('-')
                                  .first
                                  .trim(),
                              color: _marcaController.text.trim().contains('-')
                                  ? _marcaController.text
                                        .trim()
                                        .split('-')
                                        .last
                                        .trim()
                                  : null,
                              area: 'Funcionario',
                            );

                            setState(() {
                              _vehiculos.insert(0, nuevoVehiculo);
                              _vehiculosFuture = Future.value(_vehiculos);
                            });

                            navigator.pop();

                            messenger.showSnackBar(
                              SnackBar(content: Text(mensaje)),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            final mensaje = error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(mensaje),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar Vehículo',
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
        title: const Text(
          'Mis Vehículos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalAgregar,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Agregar Vehículo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<VehiculoModel>>(
        future: _vehiculosFuture,
        builder: (context, snapshot) {
          final vehicles = snapshot.data ?? _vehiculos;

          if (snapshot.connectionState == ConnectionState.waiting &&
              vehicles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vehículos Registrados',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tienes ${vehicles.length} vehículo(s) activo(s)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${vehicles.length} / 3 Máx',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: vehicles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No tienes vehículos registrados',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _mostrarModalAgregar,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Registrar primero',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              final VehiculoModel v = vehicles[index];
                              final bool esCarro = v.esCarro;
                              final bool esPrincipal = index == 0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: esPrincipal
                                        ? AppTheme.primary.withValues(
                                            alpha: 0.3,
                                          )
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: esCarro
                                            ? AppTheme.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.orange.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        esCarro
                                            ? Icons.directions_car_rounded
                                            : Icons.two_wheeler_rounded,
                                        color: esCarro
                                            ? AppTheme.primary
                                            : Colors.orange[800],
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                v.placaFormateada,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (esPrincipal)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Principal',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${v.tipoCorto} • ${v.descripcion}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'Eliminar vehículo',
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'La eliminación de vehículos de usuario no está disponible en el backend actual.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      },
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
          );
        },
      ),
    );
  }
}
