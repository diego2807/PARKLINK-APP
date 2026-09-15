import 'package:flutter/material.dart';

class AdminTendenciasScreen extends StatefulWidget {
  const AdminTendenciasScreen({super.key});

  @override
  State<AdminTendenciasScreen> createState() => _AdminTendenciasScreenState();
}

class _AdminTendenciasScreenState extends State<AdminTendenciasScreen> {
  String _selectedPeriod = 'Semanal';

  // Datos para gráfico de barras
  final List<Map<String, dynamic>> _dayData = [
    {'day': 'Lun', 'percentage': 0.85, 'label': '85%'},
    {'day': 'Mar', 'percentage': 0.95, 'label': '95%'},
    {'day': 'Mié', 'percentage': 0.90, 'label': '90%'},
    {'day': 'Jue', 'percentage': 0.88, 'label': '88%'},
    {'day': 'Vie', 'percentage': 0.70, 'label': '70%'},
    {'day': 'Sáb', 'percentage': 0.35, 'label': '35%'},
    {'day': 'Dom', 'percentage': 0.15, 'label': '15%'},
  ];

  Color _getBarColor(double value) {
    if (value >= 0.90) return const Color(0xFFEF4444); // Rojo - Crítico
    if (value >= 0.70) return const Color(0xFF3B82F6); // Azul - Alto
    if (value >= 0.40) return const Color(0xFF10B981); // Verde - Moderado
    return const Color(0xFF94A3B8); // Gris - Bajo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ENCABEZADO Y FILTROS ADAPTATIVOS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 700) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderTitles(),
                            const SizedBox(height: 16),
                            _buildPeriodSelector(),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildHeaderTitles()),
                          const SizedBox(width: 16),
                          _buildPeriodSelector(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // TARJETAS DE KPIS RÁPIDOS (Adaptativo Grid / Columna)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 900) {
                        return Row(
                          children: [
                            Expanded(child: _buildStatCard('Hora Pico Principal', '08:30 AM - 10:00 AM', 'Mayor flujo registrado', Icons.access_time_filled_rounded, const Color(0xFFF59E0B))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('Día Con Mayor Flujo', 'Martes (95%)', 'Capacidad casi máxima', Icons.trending_up_rounded, const Color(0xFFEF4444))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('Tiempo Promedio', '4h 25m', 'Por vehículo estacionado', Icons.timer_outlined, const Color(0xFF3B82F6))),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildStatCard('Hora Pico Principal', '08:30 AM - 10:00 AM', 'Mayor flujo registrado', Icons.access_time_filled_rounded, const Color(0xFFF59E0B)),
                            const SizedBox(height: 16),
                            _buildStatCard('Día Con Mayor Flujo', 'Martes (95%)', 'Capacidad casi máxima', Icons.trending_up_rounded, const Color(0xFFEF4444)),
                            const SizedBox(height: 16),
                            _buildStatCard('Tiempo Promedio', '4h 25m', 'Por vehículo estacionado', Icons.timer_outlined, const Color(0xFF3B82F6)),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // CONTENIDO PRINCIPAL EN DOS COLUMNAS RESPONSIVAS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isDesktop = constraints.maxWidth >= 950;
                      
                      Widget chartSection = Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                if (innerConstraints.maxWidth < 500) {
                                  return const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nivel de Ocupación Promedio por Día',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      SizedBox(height: 10),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          _LegendDot(color: Color(0xFFEF4444), label: 'Crítico (>90%)'),
                                          _LegendDot(color: Color(0xFF3B82F6), label: 'Alto'),
                                          _LegendDot(color: Color(0xFF10B981), label: 'Moderado'),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nivel de Ocupación Promedio por Día',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    Row(
                                      children: [
                                        _LegendDot(color: Color(0xFFEF4444), label: 'Crítico (>90%)'),
                                        SizedBox(width: 12),
                                        _LegendDot(color: Color(0xFF3B82F6), label: 'Alto'),
                                        SizedBox(width: 12),
                                        _LegendDot(color: Color(0xFF10B981), label: 'Moderado'),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 28),

                            // Barras de ocupación con scroll horizontal para asegurar responsividad en móviles
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                height: 200,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _dayData.map((data) {
                                    final double percentage = (data['percentage'] as num).toDouble();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            data['label'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getBarColor(percentage),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            width: 32,
                                            height: 150 * percentage,
                                            decoration: BoxDecoration(
                                              color: _getBarColor(percentage),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            data['day'] as String,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      Widget sideSection = Column(
                        children: [
                          // Card Horarios
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Afluencia por Turno',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 16),
                                _buildShiftRow('Mañana (06:00 - 12:00)', 0.88, 'Alta Demanda'),
                                const SizedBox(height: 12),
                                _buildShiftRow('Tarde (12:00 - 18:00)', 0.65, 'Demanda Media'),
                                const SizedBox(height: 12),
                                _buildShiftRow('Noche (18:00 - 00:00)', 0.25, 'Baja Demanda'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Card Sugerencia Inteligente
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recomendación del Sistema',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Los martes y miércoles entre 8:00 y 10:00 AM la ocupación supera el 90%. Se sugiere habilitar la zona reservada de apoyo.',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: chartSection),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: sideSection),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            chartSection,
                            const SizedBox(height: 20),
                            sideSection,
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comportamiento de Ocupación',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        SizedBox(height: 4),
        Text(
          'Analiza los días y horarios con mayor flujo de vehículos para anticipar la demanda.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Semanal', 'Mensual', 'Anual'].map((period) {
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftRow(String title, double percentage, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.8
                  ? const Color(0xFFEF4444)
                  : percentage > 0.5
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}