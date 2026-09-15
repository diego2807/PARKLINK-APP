import 'package:flutter/material.dart';

class AdminSpotsScreen extends StatefulWidget {
  const AdminSpotsScreen({super.key});

  @override
  State<AdminSpotsScreen> createState() => _AdminSpotsScreenState();
}

class _AdminSpotsScreenState extends State<AdminSpotsScreen> {
  String _selectedFilter = 'Todas';

  final List<Map<String, dynamic>> _spots = [
    {'id': 'A-01', 'zone': 'Zona Norte', 'type': 'Carro', 'status': 'Ocupado', 'plate': 'ABC-123'},
    {'id': 'A-02', 'zone': 'Zona Norte', 'type': 'Carro', 'status': 'Disponible', 'plate': null},
    {'id': 'A-03', 'zone': 'Zona Norte', 'type': 'Carro', 'status': 'Reservado', 'plate': 'DEF-456'},
    {'id': 'A-04', 'zone': 'Zona Norte', 'type': 'Carro', 'status': 'Disponible', 'plate': null},
    {'id': 'B-01', 'zone': 'Zona Sur', 'type': 'Carro', 'status': 'Ocupado', 'plate': 'GHI-789'},
    {'id': 'B-02', 'zone': 'Zona Sur', 'type': 'Moto', 'status': 'Mantenimiento', 'plate': null},
    {'id': 'B-03', 'zone': 'Zona Sur', 'type': 'Moto', 'status': 'Disponible', 'plate': null},
    {'id': 'B-04', 'zone': 'Zona Sur', 'type': 'Moto', 'status': 'Disponible', 'plate': null},
  ];

  List<Map<String, dynamic>> get _filteredSpots {
    if (_selectedFilter == 'Todas') return _spots;
    return _spots.where((s) => s['status'] == _selectedFilter).toList();
  }

  void _showAddSpotDialog() {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController();
    String selectedZone = 'Zona Norte';
    String selectedType = 'Carro';
    String selectedStatus = 'Disponible';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.add_location_alt_outlined, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Text('Agregar Nueva Celda', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          DropdownMenuItem(value: 'Zona Norte', child: Text('Zona Norte')),
                          DropdownMenuItem(value: 'Zona Sur', child: Text('Zona Sur')),
                          DropdownMenuItem(value: 'Zona VIP', child: Text('Zona VIP')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedZone = val!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Vehículo',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Carro', child: Text('Carro')),
                          DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedType = val!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Estado Inicial',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
                          DropdownMenuItem(value: 'Ocupado', child: Text('Ocupado')),
                          DropdownMenuItem(value: 'Reservado', child: Text('Reservado')),
                          DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedStatus = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        _spots.add({
                          'id': idController.text.trim().toUpperCase(),
                          'zone': selectedZone,
                          'type': selectedType,
                          'status': selectedStatus,
                          'plate': selectedStatus == 'Ocupado' || selectedStatus == 'Reservado' ? 'DEF-999' : null,
                        });
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Celda "${idController.text.toUpperCase()}" agregada con éxito.'),
                          backgroundColor: const Color(0xFF10B981),
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
    String selectedStatus = spot['status'];
    final plateController = TextEditingController(text: spot['plate'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit_location_alt_outlined, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Text('Gestionar Celda ${spot['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                        DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
                        DropdownMenuItem(value: 'Ocupado', child: Text('Ocupado')),
                        DropdownMenuItem(value: 'Reservado', child: Text('Reservado')),
                        DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedStatus = val!;
                          if (selectedStatus == 'Disponible' || selectedStatus == 'Mantenimiento') {
                            plateController.clear();
                          }
                        });
                      },
                    ),
                    if (selectedStatus == 'Ocupado' || selectedStatus == 'Reservado') ...[
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
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      spot['status'] = selectedStatus;
                      spot['plate'] = plateController.text.trim().isEmpty ? null : plateController.text.trim().toUpperCase();
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Celda ${spot['id']} actualizada correctamente.'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
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
    int disponibles = _spots.where((s) => s['status'] == 'Disponible').length;
    int ocupadas = _spots.where((s) => s['status'] == 'Ocupado').length;
    int reservadas = _spots.where((s) => s['status'] == 'Reservado').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado de Celdas en Tiempo Real',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Supervisa, asigna y gestiona los espacios del parqueadero.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddSpotDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nueva Celda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildQuickStat('Total Celdas', '${_spots.length}', Colors.blue, Icons.grid_view_rounded),
                  const SizedBox(width: 12),
                  _buildQuickStat('Disponibles', '$disponibles', const Color(0xFF10B981), Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  _buildQuickStat('Ocupadas', '$ocupadas', const Color(0xFFEF4444), Icons.directions_car_filled),
                  const SizedBox(width: 12),
                  _buildQuickStat('Reservadas', '$reservadas', const Color(0xFFF59E0B), Icons.bookmark_border),
                ],
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
                    _buildFilterChip('Mantenimiento'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1100
                      ? 4
                      : constraints.maxWidth > 700
                          ? 3
                          : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: _filteredSpots.length,
                    itemBuilder: (context, index) {
                      final spot = _filteredSpots[index];
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

  Widget _buildQuickStat(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
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
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
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
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
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
        bgColor = const Color(0xFF10B981).withOpacity(0.08);
        break;
      case 'Ocupado':
        statusColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withOpacity(0.08);
        break;
      case 'Reservado':
        statusColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFF59E0B).withOpacity(0.08);
        break;
      default:
        statusColor = const Color(0xFF64748B);
        bgColor = const Color(0xFF64748B).withOpacity(0.08);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                    Text(
                      spot['id'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Icon(
                      spot['type'] == 'Carro' ? Icons.directions_car : Icons.two_wheeler,
                      color: const Color(0xFF64748B),
                      size: 22,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot['zone'],
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    if (spot['plate'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Placa: ${spot['plate']}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        spot['status'],
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