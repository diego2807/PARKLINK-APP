import 'package:flutter/material.dart';

class AdminRegistroScreen extends StatefulWidget {
  const AdminRegistroScreen({super.key});

  @override
  State<AdminRegistroScreen> createState() => _AdminRegistroScreenState();
}

class _AdminRegistroScreenState extends State<AdminRegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de Texto
  final _plateController = TextEditingController();
  final _ownerController = TextEditingController();
  final _spotController = TextEditingController();

  int _transactionType = 0; // 0 = Entrada, 1 = Salida
  String _selectedVehicleType = 'Automóvil';

  // Historial dinámico de accesos recientes
  final List<Map<String, dynamic>> _recentLogs = [
    {
      'plate': 'ABC-123',
      'owner': 'Carlos Mendoza',
      'spot': 'A-01',
      'time': '11:12 AM',
      'type': 'Entrada',
      'vehicle': 'Automóvil',
    },
    {
      'plate': 'XYZ-789',
      'owner': 'Ana Gómez',
      'spot': 'B-04',
      'time': '10:45 AM',
      'type': 'Salida',
      'vehicle': 'Automóvil',
    },
    {
      'plate': 'KTM-890',
      'owner': 'David López',
      'spot': 'M-02',
      'time': '10:30 AM',
      'type': 'Entrada',
      'vehicle': 'Motocicleta',
    },
  ];

  @override
  void dispose() {
    _plateController.dispose();
    _ownerController.dispose();
    _spotController.dispose();
    super.dispose();
  }

  void _registerMovement() {
    if (_formKey.currentState!.validate()) {
      final now = TimeOfDay.now();
      final formattedTime =
          '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';

      setState(() {
        _recentLogs.insert(0, {
          'plate': _plateController.text.trim().toUpperCase(),
          'owner': _ownerController.text.trim(),
          'spot': _spotController.text.trim().toUpperCase(),
          'time': formattedTime,
          'type': _transactionType == 0 ? 'Entrada' : 'Salida',
          'vehicle': _selectedVehicleType,
        });

        // Limpiar formulario
        _plateController.clear();
        _ownerController.clear();
        _spotController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _transactionType == 0
                    ? '¡Ingreso registrado exitosamente!'
                    : '¡Salida registrada exitosamente!',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUMNA IZQUIERDA: Formulario Principal
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Control de Accesos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gestiona las entradas y salidas de vehículos en tiempo real.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Selector Tipo de Operación (Tabs Entrada / Salida)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _transactionType = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _transactionType == 0
                                        ? const Color(0xFF3B82F6)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        size: 18,
                                        color: _transactionType == 0
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Registrar Entrada',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _transactionType == 0
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _transactionType = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _transactionType == 1
                                        ? const Color(0xFFEF4444)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        size: 18,
                                        color: _transactionType == 1
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Registrar Salida',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _transactionType == 1
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tarjeta Formulario
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tipo de Vehículo',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildVehicleOption(
                                    'Automóvil',
                                    Icons.directions_car_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildVehicleOption(
                                    'Motocicleta',
                                    Icons.two_wheeler_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Placa
                              _buildLabel('Placa del Vehículo'),
                              TextFormField(
                                controller: _plateController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: _inputDecoration(
                                  'Ej. ABC-123',
                                  Icons.subtitles_outlined,
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                        ? 'Ingresa la placa del vehículo'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              // Propietario
                              _buildLabel('Propietario / Conductor'),
                              TextFormField(
                                controller: _ownerController,
                                decoration: _inputDecoration(
                                  'Nombre completo',
                                  Icons.person_outline_rounded,
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                        ? 'Ingresa el nombre del propietario'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              // Celda Asignada
                              _buildLabel('Celda Asignada'),
                              TextFormField(
                                controller: _spotController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: _inputDecoration(
                                  'Ej. A-05',
                                  Icons.local_parking_rounded,
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                        ? 'Ingresa el código de la celda'
                                        : null,
                              ),
                              const SizedBox(height: 24),

                              // Botón de Confirmación
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _transactionType == 0
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _registerMovement,
                                  child: Text(
                                    _transactionType == 0
                                        ? 'Confirmar Ingreso'
                                        : 'Confirmar Salida',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // COLUMNA DERECHA: Actividad Reciente en Vivo
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Movimientos Recientes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _recentLogs.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final log = _recentLogs[index];
                            final bool isEntry = log['type'] == 'Entrada';

                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isEntry
                                        ? const Color(0xFF10B981).withOpacity(0.1)
                                        : const Color(0xFFEF4444).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isEntry
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isEntry
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${log['plate']} • ${log['spot']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        '${log['owner']} (${log['vehicle']})',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  log['time'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption(String label, IconData icon) {
    final bool isSelected = _selectedVehicleType == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedVehicleType = label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6).withOpacity(0.1)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
    );
  }
}