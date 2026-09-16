import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/celda_provider.dart';
import '../../data/services/celda_service.dart';

class AdminSpotsScreen extends StatefulWidget {
  const AdminSpotsScreen({super.key});

  @override
  State<AdminSpotsScreen> createState() => _AdminSpotsScreenState();
}

class _AdminSpotsScreenState extends State<AdminSpotsScreen> {
  final CeldaService _celdaService = CeldaService();

  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CeldaProvider>().cargarCeldas();
    });
  }

  String _tipoCeldaBackend(String valor) {
    switch (valor.toLowerCase()) {
      case 'administrativas':
        return 'administrativas';

      case 'eléctricos':
      case 'electricos':
        return 'eléctricos';

      case 'movilidad':
      case 'movilidad reducida':
        return 'movilidad';

      case 'operativas':
      default:
        return 'operativas';
    }
  }

  void _showAddSpotDialog() {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController();

    String selectedZone = 'A';
    String selectedType = 'Operativas';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.add_location_alt_outlined,
                    color: Color(0xFF3B82F6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Agregar Nueva Celda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: idController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Celda',
                          hintText: 'Ej. C-01, M-05',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el identificador de la celda';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedZone,
                        decoration: const InputDecoration(
                          labelText: 'Zona',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'A',
                            child: Text('Zona A'),
                          ),
                          DropdownMenuItem(
                            value: 'B',
                            child: Text('Zona B'),
                          ),
                          DropdownMenuItem(
                            value: 'VIP',
                            child: Text('Zona VIP'),
                          ),
                        ],
                        onChanged: (String? val) {
                          if (val == null) return;

                          setDialogState(() {
                            selectedZone = val;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Celda',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Operativas',
                            child: Text('Operativas'),
                          ),
                          DropdownMenuItem(
                            value: 'Administrativas',
                            child: Text('Administrativas'),
                          ),
                          DropdownMenuItem(
                            value: 'Movilidad',
                            child: Text('Movilidad Reducida'),
                          ),
                          DropdownMenuItem(
                            value: 'Eléctricos',
                            child: Text('Eléctricos'),
                          ),
                        ],
                        onChanged: (String? val) {
                          if (val == null) return;

                          setDialogState(() {
                            selectedType = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final codigo = idController.text.trim();

                    final codigoFinal = codigo.contains('-')
                        ? codigo
                        : '$selectedZone-$codigo';

                    try {
                      await _celdaService.registrarCelda(
                        codigoCelda: codigoFinal,
                        tipoCelda: _tipoCeldaBackend(selectedType),
                      );

                      if (!mounted) return;

                      await context.read<CeldaProvider>().cargarCeldas();

                      if (!mounted) return;

                      Navigator.of(ctx).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Celda "$codigoFinal" agregada con éxito.',
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No se pudo crear la celda: $error',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Celda'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSpotDialog(Map<String, dynamic> spot) {
    String selectedStatus = spot['status'] as String;

    final plateController = TextEditingController(
      text: spot['plate']?.toString() ?? '',
    );

    final int? celdaId = spot['celdaId'] as int?;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.edit_location_alt_outlined,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gestionar Celda ${spot['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado de la Celda',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Disponible',
                          child: Text('Disponible'),
                        ),
                        DropdownMenuItem(
                          value: 'Ocupado',
                          child: Text('Ocupado'),
                        ),
                        DropdownMenuItem(
                          value: 'Reservado',
                          child: Text('Reservado'),
                        ),
                      ],
                      onChanged: (String? val) {
                        if (val == null) return;

                        setDialogState(() {
                          selectedStatus = val;

                          if (selectedStatus == 'Disponible') {
                            plateController.clear();
                          }
                        });
                      },
                    ),

                    if (selectedStatus == 'Ocupado' ||
                        selectedStatus == 'Reservado') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: plateController,
                        decoration: const InputDecoration(
                          labelText: 'Placa del Vehículo',
                          hintText: 'Ej. ABC-123',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (celdaId == null) return;

                    try {
                      final bool ocupada =
                          selectedStatus == 'Ocupado' ||
                          selectedStatus == 'Reservado';

                      await _celdaService.cambiarEstadoCelda(
                        celdaId: celdaId,
                        ocupada: ocupada,
                      );

                      if (!mounted) return;

                      await context.read<CeldaProvider>().cargarCeldas();

                      if (!mounted) return;

                      Navigator.of(ctx).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Celda ${spot['id']} actualizada correctamente.',
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No se pudo actualizar la celda: $error',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final celdaProvider = context.watch<CeldaProvider>();

    final List<Map<String, dynamic>> spots =
        celdaProvider.celdas.map((celda) {
      return {
        'id': celda.codigoCelda,
        'zone': celda.zona,
        'type': celda.tipoEtiqueta,
        'status': celda.ocupada ? 'Ocupado' : 'Disponible',
        'plate': null,
        'celdaId': celda.id,
      };
    }).toList();

    final List<Map<String, dynamic>> filteredSpots =
        _selectedFilter == 'Todas'
            ? spots
            : spots
                .where(
                  (s) => s['status'] == _selectedFilter,
                )
                .toList();

    if (celdaProvider.cargando && spots.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (celdaProvider.error.isNotEmpty && spots.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                Text(
                  celdaProvider.error,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<CeldaProvider>().cargarCeldas();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final int disponibles =
        spots.where((s) => s['status'] == 'Disponible').length;

    final int ocupadas =
        spots.where((s) => s['status'] == 'Ocupado').length;

    final int reservadas =
        spots.where((s) => s['status'] == 'Reservado').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  const header = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado de Celdas en Tiempo Real',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Supervisa, asigna y gestiona los espacios del parqueadero.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  );

                  final button = ElevatedButton.icon(
                    onPressed: _showAddSpotDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nueva Celda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  );

                  return constraints.maxWidth < 560
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: button,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Expanded(
                              child: header,
                            ),
                            const SizedBox(width: 16),
                            button,
                          ],
                        );
                },
              ),

              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickStat(
                      'Total Celdas',
                      '${spots.length}',
                      Colors.blue,
                      Icons.grid_view_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickStat(
                      'Disponibles',
                      '$disponibles',
                      const Color(0xFF10B981),
                      Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickStat(
                      'Ocupadas',
                      '$ocupadas',
                      const Color(0xFFEF4444),
                      Icons.directions_car_filled,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickStat(
                      'Reservadas',
                      '$reservadas',
                      const Color(0xFFF59E0B),
                      Icons.bookmark_border,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todas'),
                    _buildFilterChip('Disponible'),
                    _buildFilterChip('Ocupado'),
                    _buildFilterChip('Reservado'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final int crossAxisCount =
                      constraints.maxWidth > 1100
                          ? 4
                          : constraints.maxWidth > 700
                              ? 3
                              : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: filteredSpots.length,
                    itemBuilder: (context, index) {
                      final spot = filteredSpots[index];

                      return _buildSpotCard(spot);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: 190,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
        selectedColor: const Color(0xFF3B82F6),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : const Color(0xFF64748B),
          fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotCard(Map<String, dynamic> spot) {
    Color statusColor;
    Color bgColor;

    switch (spot['status']) {
      case 'Disponible':
        statusColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.08);
        break;

      case 'Ocupado':
        statusColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.08);
        break;

      case 'Reservado':
        statusColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.08);
        break;

      default:
        statusColor = const Color(0xFF64748B);
        bgColor = const Color(0xFF64748B).withValues(alpha: 0.08);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditSpotDialog(spot),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${spot['id']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Icon(
                      spot['status'] == 'Disponible'
                          ? Icons.check_circle_rounded
                          : spot['status'] == 'Ocupado'
                              ? Icons.directions_car_filled
                              : Icons.bookmark_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${spot['zone']} • ${spot['type']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    if (spot['plate'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Placa: ${spot['plate']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${spot['status']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}