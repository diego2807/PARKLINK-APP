import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = 'Este Mes';

  // Datos mock para distribución de horas pico
  final List<Map<String, dynamic>> _hourlyData = [
    {'time': '06:00 AM', 'percentage': 25},
    {'time': '08:00 AM', 'percentage': 92},
    {'time': '10:00 AM', 'percentage': 84},
    {'time': '12:00 PM', 'percentage': 65},
    {'time': '02:00 PM', 'percentage': 78},
    {'time': '04:00 PM', 'percentage': 88},
    {'time': '06:00 PM', 'percentage': 40},
  ];

  void _exportReport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text('Generando y descargando reporte en formato $type...'),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ENCABEZADO Y SELECTOR
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderTitles(),
                            const SizedBox(height: 16),
                            _buildPeriodDropdown(),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildHeaderTitles()),
                          const SizedBox(width: 16),
                          _buildPeriodDropdown(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // KPIS DESTACADOS (Adaptativo con LayoutBuilder / Wrap)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isDesktop = constraints.maxWidth >= 800;
                      if (isDesktop) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Ocupación Promedio',
                                value: '84%',
                                subtitle: '+5% respecto al mes anterior',
                                icon: Icons.pie_chart_outline_rounded,
                                color: const Color(0xFF2563EB),
                                progress: 0.84,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Hora Pico de Afluencia',
                                value: '08:00 AM - 10:00 AM',
                                subtitle: '92% de capacidad ocupada',
                                icon: Icons.access_time_filled_rounded,
                                color: const Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Rotación Diaria',
                                value: '2.4 Vehículos/Celda',
                                subtitle: 'Promedio de parqueo: 4.5h',
                                icon: Icons.autorenew_rounded,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildMetricCard(
                              title: 'Ocupación Promedio',
                              value: '84%',
                              subtitle: '+5% respecto al mes anterior',
                              icon: Icons.pie_chart_outline_rounded,
                              color: const Color(0xFF2563EB),
                              progress: 0.84,
                            ),
                            const SizedBox(height: 16),
                            _buildMetricCard(
                              title: 'Hora Pico de Afluencia',
                              value: '08:00 AM - 10:00 AM',
                              subtitle: '92% de capacidad ocupada',
                              icon: Icons.access_time_filled_rounded,
                              color: const Color(0xFF059669),
                            ),
                            const SizedBox(height: 16),
                            _buildMetricCard(
                              title: 'Rotación Diaria',
                              value: '2.4 Vehículos/Celda',
                              subtitle: 'Promedio de parqueo: 4.5h',
                              icon: Icons.autorenew_rounded,
                              color: const Color(0xFF7C3AED),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // GRÁFICO DE DISTRIBUCIÓN POR HORAS
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comportamiento de Ocupación por Horarios',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Nivel de demanda porcentual registrado a lo largo del día',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Barras de ocupación por hora con scroll horizontal si es necesario
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _hourlyData.map((data) {
                              final int percentage = data['percentage'] as int;
                              final isPeak = percentage >= 85;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$percentage%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPeak ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 32,
                                      height: (percentage * 1.4).toDouble(),
                                      decoration: BoxDecoration(
                                        color: isPeak ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['time'].toString(),
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BANNER DE EXPORTACIÓN Y ACCIONES RÁPIDAS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 750) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildExportInfoContent(),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF059669),
                                        side: const BorderSide(color: Color(0xFF10B981)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _exportReport('Excel'),
                                      icon: const Icon(Icons.table_view_rounded, size: 18),
                                      label: const Text('Exportar Excel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E3A8A),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _exportReport('PDF'),
                                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                                      label: const Text('Exportar PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildExportInfoContent()),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF059669),
                                    side: const BorderSide(color: Color(0xFF10B981)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _exportReport('Excel'),
                                  icon: const Icon(Icons.table_view_rounded, size: 18),
                                  label: const Text('Exportar Excel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _exportReport('PDF'),
                                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                                  label: const Text('Exportar PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Analítico de Uso',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Analiza el rendimiento del parqueadero corporativo y exporta los informes.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          items: ['Esta Semana', 'Este Mes', 'Trimestre', 'Año Actual'].map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedPeriod = val);
          },
        ),
      ),
    );
  }

  Widget _buildExportInfoContent() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFEFF6FF),
          child: Icon(Icons.description_outlined, color: Color(0xFF2563EB)),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exportar Informes Ejecutivos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 2),
              Text(
                'Descarga la matriz de datos completa para auditorías internas.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}