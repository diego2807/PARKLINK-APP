import 'package:flutter/material.dart';

import '../../data/services/kpi_service.dart';
import '../../domain/models/kpi_model.dart';
import '../../domain/models/kpi_ocupacion_model.dart';

class AdminKpisScreen extends StatefulWidget {
  const AdminKpisScreen({super.key});

  @override
  State<AdminKpisScreen> createState() => _AdminKpisScreenState();
}

class _AdminKpisScreenState extends State<AdminKpisScreen> {
  final KpiService _kpiService = KpiService();

  String _selectedPeriod = 'Hoy';
  bool _isLoading = true;
  String _error = '';
  KpiModel _kpis = KpiModel.vacio();
  KpiOcupacionModel _ocupacion = KpiOcupacionModel.vacio();

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final ({KpiModel kpis, KpiOcupacionModel ocupacion}) dashboard =
          await _kpiService.obtenerDashboard();
      if (!mounted) return;
      setState(() {
        _kpis = dashboard.kpis;
        _ocupacion = dashboard.ocupacion;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double porcentaje = _ocupacion.porcentajeUsoGlobal;
    final int disponibles = _ocupacion.celdasDisponibles;
    final int capacidad = _ocupacion.capacidadMaxima;
    final int vehiculosActivos = _kpis.vehiculosActivos.length;
    final int incidentes = _kpis.celdasEspeciales;

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
                  final bool isSmallScreen = constraints.maxWidth < 700;
                  if (isSmallScreen) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _KpiHeaderTitles(),
                        const SizedBox(height: 16),
                        _buildFilterAndBadgeRow(),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [_KpiHeaderTitles(), _KpiHeaderControls()],
                  );
                },
              ),
              const SizedBox(height: 24),
              if (_error.isNotEmpty)
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
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            _buildKpiCard(
                              title: 'Ocupación Actual',
                              value: '${porcentaje.toStringAsFixed(1)}%',
                              subtext:
                                  '${_ocupacion.ocupacionActual} de $capacidad ocupados',
                              isPositive: porcentaje < 75,
                              icon: Icons.local_parking_rounded,
                              iconBg: const Color(0xFFEFF6FF),
                              iconColor: const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 16),
                            _buildKpiCard(
                              title: 'Celdas Disponibles',
                              value: '$disponibles / $capacidad',
                              subtext: 'Listas para ocupar',
                              isPositive: true,
                              icon: Icons.event_seat_rounded,
                              iconBg: const Color(0xFFECFDF5),
                              iconColor: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildKpiCard(
                              title: 'Vehículos Activos',
                              value: '$vehiculosActivos',
                              subtext:
                                  '${_kpis.totalCarros} carros · ${_kpis.totalMotos} motos',
                              isPositive: true,
                              icon: Icons.directions_car_rounded,
                              iconBg: const Color(0xFFF5F3FF),
                              iconColor: const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 16),
                            _buildKpiCard(
                              title: 'Incidentes / Alertas',
                              value: '$incidentes',
                              subtext: incidentes > 0
                                  ? 'Requieren atención'
                                  : 'Sin alertas',
                              isPositive: incidentes == 0,
                              icon: Icons.warning_amber_rounded,
                              iconBg: const Color(0xFFFEF2F2),
                              iconColor: const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      _buildKpiCard(
                        title: 'Ocupación Actual',
                        value: '${porcentaje.toStringAsFixed(1)}%',
                        subtext:
                            '${_ocupacion.ocupacionActual} de $capacidad ocupados',
                        isPositive: porcentaje < 75,
                        icon: Icons.local_parking_rounded,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 16),
                      _buildKpiCard(
                        title: 'Celdas Disponibles',
                        value: '$disponibles / $capacidad',
                        subtext: 'Listas para ocupar',
                        isPositive: true,
                        icon: Icons.event_seat_rounded,
                        iconBg: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 16),
                      _buildKpiCard(
                        title: 'Vehículos Activos',
                        value: '$vehiculosActivos',
                        subtext:
                            '${_kpis.totalCarros} carros · ${_kpis.totalMotos} motos',
                        isPositive: true,
                        icon: Icons.directions_car_rounded,
                        iconBg: const Color(0xFFF5F3FF),
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 16),
                      _buildKpiCard(
                        title: 'Incidentes / Alertas',
                        value: '$incidentes',
                        subtext: incidentes > 0
                            ? 'Requieren atención'
                            : 'Sin alertas',
                        isPositive: incidentes == 0,
                        icon: Icons.warning_amber_rounded,
                        iconBg: const Color(0xFFFEF2F2),
                        iconColor: const Color(0xFFEF4444),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withAlpha(3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estado General de Celdas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Capacidad Total: ${capacidad == 0 ? 'Sin datos' : '$capacidad espacios'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: capacidad == 0 ? 0 : _ocupacion.fraccionGlobal,
                        minHeight: 14,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.spaceAround,
                      children: <Widget>[
                        _buildVehicleStatusItem(
                          icon: Icons.directions_car_rounded,
                          label: 'Carros Ocupados',
                          value: '${_kpis.totalCarros} registrados',
                          color: const Color(0xFF2563EB),
                        ),
                        _buildVehicleStatusItem(
                          icon: Icons.two_wheeler_rounded,
                          label: 'Motos Ocupadas',
                          value: '${_kpis.totalMotos} registradas',
                          color: const Color(0xFF8B5CF6),
                        ),
                        _buildVehicleStatusItem(
                          icon: Icons.check_circle_rounded,
                          label: 'Celdas Libres',
                          value: '$disponibles Disponibles',
                          color: const Color(0xFF10B981),
                        ),
                      ],
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

  Widget _buildFilterAndBadgeRow() {
    return Row(
      children: [
        Expanded(child: _buildPeriodDropdown()),
        const SizedBox(width: 12),
        _buildLiveBadge(),
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedPeriod = newValue);
            }
          },
          items: <String>['Hoy', 'Esta Semana', 'Este Mes']
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: Color(0xFF16A34A)),
          SizedBox(width: 8),
          Text(
            'Sistema en Vivo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required bool isPositive,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Expanded(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPositive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiHeaderTitles extends StatelessWidget {
  const _KpiHeaderTitles();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rendimiento General del Parqueadero',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Métricas analíticas operativas en tiempo real para empleados y visitantes.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _KpiHeaderControls extends StatelessWidget {
  const _KpiHeaderControls();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
