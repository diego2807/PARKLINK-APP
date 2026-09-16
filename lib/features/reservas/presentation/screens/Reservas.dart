import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../data/services/reserva_service.dart';
import '../../domain/models/reserva_model.dart';

class UserReserveSpotScreen extends StatefulWidget {
  const UserReserveSpotScreen({super.key});

  @override
  State<UserReserveSpotScreen> createState() => _UserReserveSpotScreenState();
}

class _UserReserveSpotScreenState extends State<UserReserveSpotScreen> {
  final ReservaService _reservaService = ReservaService();
  final int _vehiculoId = 1;

  String _tipoVehiculo = 'carro';
  String _zonaSeleccionada = 'Torre A - Piso 1';
  String? _celdaSeleccionada;
  DateTime _fechaReserva = DateTime.now();
  TimeOfDay _horaReserva = const TimeOfDay(hour: 8, minute: 0);

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _error = '';
  List<ReservaModel> _misReservas = <ReservaModel>[];

  final List<String> _zonas = [
    'Torre A - Piso 1',
    'Torre A - Piso 2',
    'Sótano 1 - General',
    'Sótano 2 - VIP',
  ];

  final Map<String, List<Map<String, dynamic>>> _mapaCeldas = {
    'Torre A - Piso 1': [
      {'id': 'A-01', 'estado': 'disponible'},
      {'id': 'A-02', 'estado': 'ocupado'},
      {'id': 'A-03', 'estado': 'disponible'},
      {'id': 'A-04', 'estado': 'disponible'},
      {'id': 'A-05', 'estado': 'ocupado'},
      {'id': 'A-06', 'estado': 'disponible'},
      {'id': 'A-07', 'estado': 'ocupado'},
      {'id': 'A-08', 'estado': 'disponible'},
      {'id': 'A-09', 'estado': 'disponible'},
    ],
    'Torre A - Piso 2': [
      {'id': 'B-01', 'estado': 'ocupado'},
      {'id': 'B-02', 'estado': 'ocupado'},
      {'id': 'B-03', 'estado': 'disponible'},
      {'id': 'B-04', 'estado': 'disponible'},
      {'id': 'B-05', 'estado': 'disponible'},
      {'id': 'B-06', 'estado': 'ocupado'},
    ],
    'Sótano 1 - General': [
      {'id': 'S1-01', 'estado': 'disponible'},
      {'id': 'S1-02', 'estado': 'disponible'},
      {'id': 'S1-03', 'estado': 'ocupado'},
      {'id': 'S1-04', 'estado': 'disponible'},
    ],
    'Sótano 2 - VIP': [
      {'id': 'VIP-01', 'estado': 'disponible'},
      {'id': 'VIP-02', 'estado': 'ocupado'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final List<ReservaModel> reservas = await _reservaService
          .obtenerMisReservas();
      if (!mounted) return;
      setState(() {
        _misReservas = reservas;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmarReserva() async {
    if (_celdaSeleccionada == null) return;

    final String? validacion = _reservaService.validarReserva(
      fecha: _fechaReserva,
      horaDelDia: _horaReserva.hour,
    );

    if (validacion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validacion), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String mensaje = await _reservaService.crearReservaConFecha(
        vehiculoId: _vehiculoId,
        fecha: _fechaReserva,
        horaDelDia: _horaReserva.hour,
      );

      if (!mounted) return;

      setState(() {
        final celdas = _mapaCeldas[_zonaSeleccionada];
        if (celdas != null) {
          for (final Map<String, dynamic> celda in celdas) {
            if (celda['id'] == _celdaSeleccionada) {
              celda['estado'] = 'ocupado';
              break;
            }
          }
        }
        _celdaSeleccionada = null;
      });

      await _cargarReservas();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
                'Reserva confirmada',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mensaje,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Celda:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _celdaSeleccionada ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ubicación:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _zonaSeleccionada,
                          style: const TextStyle(color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Vehículo:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _tipoVehiculo == 'carro'
                              ? 'Carro (ABC-123)'
                              : 'Moto (XYZ-89)',
                          style: const TextStyle(color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaReserva,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (fecha != null) {
      setState(() => _fechaReserva = fecha);
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaReserva,
    );

    if (hora != null) {
      setState(() => _horaReserva = hora);
    }
  }

  Widget _buildLegendItem(String label, Color color, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> celdasActuales =
        _mapaCeldas[_zonaSeleccionada] ?? <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Reservar Celda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _tipoVehiculo = 'carro';
                            _celdaSeleccionada = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoVehiculo == 'carro'
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_rounded,
                                  size: 20,
                                  color: _tipoVehiculo == 'carro'
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Carro',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _tipoVehiculo == 'carro'
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _tipoVehiculo = 'moto';
                            _celdaSeleccionada = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoVehiculo == 'moto'
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.two_wheeler_rounded,
                                  size: 20,
                                  color: _tipoVehiculo == 'moto'
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Moto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _tipoVehiculo == 'moto'
                                        ? Colors.white
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
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.layers_rounded,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Zona / Ubicación:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _zonaSeleccionada,
                                  isExpanded: true,
                                  items: _zonas
                                      .map(
                                        (String z) => DropdownMenuItem<String>(
                                          value: z,
                                          child: Text(
                                            z,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (String? val) {
                                    if (val != null) {
                                      setState(() {
                                        _zonaSeleccionada = val;
                                        _celdaSeleccionada = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(
                            'Disponible',
                            const Color(0xFFE8F5E9),
                            AppTheme.success,
                          ),
                          _buildLegendItem(
                            'Ocupado',
                            Colors.grey[200]!,
                            Colors.grey[400]!,
                          ),
                          _buildLegendItem(
                            'Seleccionado',
                            AppTheme.primary.withValues(alpha: 0.15),
                            AppTheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _seleccionarFecha,
                        child: _infoChip(
                          icon: Icons.calendar_today_rounded,
                          title: 'Fecha',
                          value:
                              '${_fechaReserva.day}/${_fechaReserva.month}/${_fechaReserva.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _seleccionarHora,
                        child: _infoChip(
                          icon: Icons.access_time_rounded,
                          title: 'Hora',
                          value:
                              '${_horaReserva.hour.toString().padLeft(2, '0')}:${_horaReserva.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reservas registradas: ${_misReservas.length}',
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Selecciona tu Celda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${celdasActuales.where((Map<String, dynamic> c) => c['estado'] == 'disponible').length} disponibles',
                      style: const TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: celdasActuales.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> celda = celdasActuales[index];
                    final bool ocupado = celda['estado'] == 'ocupado';
                    final bool seleccionado = _celdaSeleccionada == celda['id'];

                    Color bgColor;
                    Color borderColor;
                    Color textColor;

                    if (ocupado) {
                      bgColor = Colors.grey[100]!;
                      borderColor = Colors.grey[300]!;
                      textColor = Colors.grey[500]!;
                    } else if (seleccionado) {
                      bgColor = AppTheme.primary.withValues(alpha: 0.12);
                      borderColor = AppTheme.primary;
                      textColor = AppTheme.primary;
                    } else {
                      bgColor = const Color(0xFFE8F5E9);
                      borderColor = AppTheme.success.withValues(alpha: 0.6);
                      textColor = AppTheme.success;
                    }

                    return Material(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: ocupado
                            ? null
                            : () {
                                setState(() {
                                  _celdaSeleccionada = celda['id'] as String;
                                });
                              },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor,
                              width: seleccionado ? 2.5 : 1.5,
                            ),
                            boxShadow: seleccionado
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : const <BoxShadow>[],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ocupado
                                    ? Icons.block_rounded
                                    : (seleccionado
                                          ? Icons.check_circle_rounded
                                          : Icons.local_parking_rounded),
                                color: textColor,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                celda['id'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: ocupado
                                      ? Colors.grey[600]
                                      : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ocupado
                                    ? 'Ocupada'
                                    : (seleccionado
                                          ? 'Seleccionada'
                                          : 'Disponible'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                if (_celdaSeleccionada != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Celda seleccionada: $_celdaSeleccionada',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                'Ubicación: $_zonaSeleccionada',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _celdaSeleccionada != null && !_isSubmitting
                        ? _confirmarReserva
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _celdaSeleccionada != null && !_isSubmitting
                          ? AppTheme.primary
                          : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _celdaSeleccionada != null ? 3 : 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _celdaSeleccionada != null
                                ? 'Confirmar Reserva'
                                : 'Selecciona una celda libre',
                            style: TextStyle(
                              color: _celdaSeleccionada != null
                                  ? Colors.white
                                  : Colors.grey[600],
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
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
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
