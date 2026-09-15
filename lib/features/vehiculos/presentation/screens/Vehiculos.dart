import 'package:flutter/material.dart';

class AdminVehiclesScreen extends StatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  State<AdminVehiclesScreen> createState() => _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends State<AdminVehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todos';

  final List<Map<String, dynamic>> _vehicles = [
    {
      'plate': 'ABC-123',
      'owner': 'Carlos Mendoza',
      'type': 'Automóvil',
      'status': 'Estacionado',
      'spot': 'A-01',
      'entryTime': '08:30 AM',
    },
    {
      'plate': 'XYZ-789',
      'owner': 'Ana Gómez',
      'type': 'Camioneta',
      'status': 'Fuera',
      'spot': 'N/A',
      'entryTime': 'Ayer 05:40 PM',
    },
    {
      'plate': 'LMN-456',
      'owner': 'Roberto Sánchez',
      'type': 'Automóvil',
      'status': 'Estacionado',
      'spot': 'A-03',
      'entryTime': '09:15 AM',
    },
    {
      'plate': 'HJK-789',
      'owner': 'María Pérez',
      'type': 'Motocicleta',
      'status': 'Estacionado',
      'spot': 'B-02',
      'entryTime': '07:50 AM',
    },
    {
      'plate': 'KOP-321',
      'owner': 'David Torres',
      'type': 'Automóvil',
      'status': 'Fuera',
      'spot': 'N/A',
      'entryTime': 'Hace 2 días',
    },
  ];

  List<Map<String, dynamic>> get _filteredVehicles {
    final query = _searchController.text.toLowerCase().trim();
    return _vehicles.where((v) {
      final matchesSearch = v['plate'].toString().toLowerCase().contains(query) ||
          v['owner'].toString().toLowerCase().contains(query);

      if (_selectedFilter == 'Todos') return matchesSearch;
      if (_selectedFilter == 'Estacionado') return matchesSearch && v['status'] == 'Estacionado';
      if (_selectedFilter == 'Fuera') return matchesSearch && v['status'] == 'Fuera';
      if (_selectedFilter == 'Motos') return matchesSearch && v['type'] == 'Motocicleta';
      if (_selectedFilter == 'Carros') return matchesSearch && (v['type'] == 'Automóvil' || v['type'] == 'Camioneta');

      return matchesSearch;
    }).toList();
  }

  void _showAddVehicleDialog() {
    final formKey = GlobalKey<FormState>();
    final plateController = TextEditingController();
    final ownerController = TextEditingController();
    String selectedType = 'Automóvil';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.directions_car_filled_outlined, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Text('Registrar Vehículo', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: plateController,
                        decoration: const InputDecoration(
                          labelText: 'Placa del Vehículo',
                          hintText: 'Ej. ABC-123',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa la placa del vehículo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ownerController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Propietario',
                          hintText: 'Ej. Juan Pérez',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre del propietario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Vehículo',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Automóvil', child: Text('Automóvil')),
                          DropdownMenuItem(value: 'Camioneta', child: Text('Camioneta')),
                          DropdownMenuItem(value: 'Motocicleta', child: Text('Motocicleta')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedType = val!),
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
                        _vehicles.add({
                          'plate': plateController.text.trim().toUpperCase(),
                          'owner': ownerController.text.trim(),
                          'type': selectedType,
                          'status': 'Fuera',
                          'spot': 'N/A',
                          'entryTime': 'Recién registrado',
                        });
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vehículo ${plateController.text.toUpperCase()} registrado correctamente.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Vehículo'),
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
    int total = _vehicles.length;
    int estacionados = _vehicles.where((v) => v['status'] == 'Estacionado').length;
    int fuera = total - estacionados;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Principal Unificado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Directorio de Automóviles Registrados',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Consulta el listado de vehículos activos y sus propietarios en el sistema.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddVehicleDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Registrar Vehículo'),
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

              // Resumen Rápido
              Row(
                children: [
                  _buildQuickStat('Total Registrados', '$total', Colors.blue, Icons.time_to_leave_rounded),
                  const SizedBox(width: 12),
                  _buildQuickStat('Estacionados Ahora', '$estacionados', const Color(0xFF10B981), Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  _buildQuickStat('Fuera del Parqueadero', '$fuera', const Color(0xFF64748B), Icons.no_drinks_outlined),
                ],
              ),
              const SizedBox(height: 24),

              // Barra de Búsqueda y Filtros
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Buscar por placa o nombre de propietario...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos'),
                        _buildFilterChip('Estacionado'),
                        _buildFilterChip('Fuera'),
                        _buildFilterChip('Carros'),
                        _buildFilterChip('Motos'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lista de Vehículos
              _filteredVehicles.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                          SizedBox(height: 12),
                          Text(
                            'No se encontraron vehículos',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Prueba cambiando el término de búsqueda o el filtro seleccionado.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredVehicles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final vehicle = _filteredVehicles[index];
                        return _buildVehicleCard(vehicle);
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
      padding: const EdgeInsets.only(left: 6.0),
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
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final bool isParked = vehicle['status'] == 'Estacionado';
    final Color statusColor = isParked ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final Color statusBg = isParked ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFE2E8F0);

    IconData vehicleIcon = Icons.directions_car_rounded;
    if (vehicle['type'] == 'Motocicleta') {
      vehicleIcon = Icons.two_wheeler_rounded;
    } else if (vehicle['type'] == 'Camioneta') {
      vehicleIcon = Icons.airport_shuttle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(vehicleIcon, color: const Color(0xFF3B82F6), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      vehicle['plate'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vehicle['type'],
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      vehicle['owner'],
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    if (isParked) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.pin_drop_outlined, size: 14, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                      Text(
                        'Celda: ${vehicle['spot']}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3.5, backgroundColor: statusColor),
                const SizedBox(width: 6),
                Text(
                  vehicle['status'],
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
    );
  }
}