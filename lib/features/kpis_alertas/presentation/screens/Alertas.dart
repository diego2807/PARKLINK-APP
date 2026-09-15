import 'package:flutter/material.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  String _selectedFilter = 'Sin Resolver';

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'title': 'Intento de acceso en celda reservada',
      'description': 'Vehículo con placa XYZ-123 intentó ocupar la celda VIP 04 asignada a otro usuario.',
      'time': 'Hace 5 minutos',
      'priority': 'Alta',
      'status': 'Pendiente',
      'icon': Icons.error_outline_rounded,
    },
    {
      'id': '2',
      'title': 'Capacidad de Zona Norte al 95%',
      'description': 'La sección ejecutiva está a punto de alcanzar el límite máximo de ocupación.',
      'time': 'Hace 22 minutos',
      'priority': 'Media',
      'status': 'Pendiente',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'id': '3',
      'title': 'Vehículo sin salida registrada',
      'description': 'El automóvil con placa HJK-789 excede el tiempo estimado de permanencia por más de 3 horas.',
      'time': 'Hace 1 hora',
      'priority': 'Baja',
      'status': 'Pendiente',
      'icon': Icons.info_outline_rounded,
    },
    {
      'id': '4',
      'title': 'Fallo de sensor en Celda B-02',
      'description': 'El sensor de presencia no reporta señal desde hace 45 minutos.',
      'time': 'Hace 2 horas',
      'priority': 'Media',
      'status': 'Resuelta',
      'icon': Icons.build_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filteredAlerts {
    if (_selectedFilter == 'Todas') return _alerts;
    if (_selectedFilter == 'Sin Resolver') {
      return _alerts.where((a) => a['status'] == 'Pendiente').toList();
    }
    return _alerts.where((a) => a['status'] == 'Resuelta').toList();
  }

  void _markAsResolved(String id) {
    setState(() {
      final index = _alerts.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _alerts[index]['status'] = 'Resuelta';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta marcada como resuelta.'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int altas = _alerts.where((a) => a['priority'] == 'Alta' && a['status'] == 'Pendiente').length;
    int medias = _alerts.where((a) => a['priority'] == 'Media' && a['status'] == 'Pendiente').length;
    int bajas = _alerts.where((a) => a['priority'] == 'Baja' && a['status'] == 'Pendiente').length;
    int resueltas = _alerts.where((a) => a['status'] == 'Resuelta').length;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Notificaciones e Incidentes Activos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircleAvatar(radius: 4, backgroundColor: Color(0xFFEF4444)),
                                  SizedBox(width: 6),
                                  Text(
                                    'En vivo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Supervisa los eventos críticos que requieren atención inmediata en el parqueadero.',
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Resumen de Métricas de Severidad
              Row(
                children: [
                  _buildMetricStat('Alta', '$altas', const Color(0xFFEF4444), Icons.error_outline),
                  const SizedBox(width: 8),
                  _buildMetricStat('Media', '$medias', const Color(0xFFF59E0B), Icons.warning_amber_rounded),
                  const SizedBox(width: 8),
                  _buildMetricStat('Baja', '$bajas', const Color(0xFF3B82F6), Icons.info_outline),
                  const SizedBox(width: 8),
                  _buildMetricStat('Resueltas', '$resueltas', const Color(0xFF10B981), Icons.check_circle_outline),
                ],
              ),
              const SizedBox(height: 24),

              // Filtros de Pestaña
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabFilter('Sin Resolver'),
                    const SizedBox(width: 8),
                    _buildTabFilter('Resueltas'),
                    const SizedBox(width: 8),
                    _buildTabFilter('Todas'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lista Dinámica de Alertas
              _filteredAlerts.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.done_all_rounded, size: 48, color: Color(0xFF10B981)),
                          SizedBox(height: 12),
                          Text(
                            '¡Todo bajo control!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'No hay incidentes registrados en esta categoría.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredAlerts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final alert = _filteredAlerts[index];
                        return _buildAlertCard(alert);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricStat(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
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
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabFilter(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: const Color(0xFF0F172A),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color themeColor;
    Color chipBg;

    switch (alert['priority']) {
      case 'Alta':
        themeColor = const Color(0xFFEF4444);
        chipBg = const Color(0xFFFEE2E2);
        break;
      case 'Media':
        themeColor = const Color(0xFFF59E0B);
        chipBg = const Color(0xFFFEF3C7);
        break;
      default:
        themeColor = const Color(0xFF3B82F6);
        chipBg = const Color(0xFFDBEAFE);
    }

    final bool isResolved = alert['status'] == 'Resuelta';

    return Container(
      decoration: BoxDecoration(
        color: isResolved ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isResolved ? const Color(0xFFCBD5E1) : themeColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isResolved
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isResolved ? const Color(0xFFCBD5E1) : themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isResolved ? Icons.check : alert['icon'],
              color: isResolved ? const Color(0xFF64748B) : themeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alert['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isResolved ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                          decoration: isResolved ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isResolved ? const Color(0xFFE2E8F0) : chipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isResolved ? 'Resuelta' : alert['priority'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isResolved ? const Color(0xFF64748B) : themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isResolved ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          alert['time'],
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    if (!isResolved)
                      OutlinedButton.icon(
                        onPressed: () => _markAsResolved(alert['id']),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Resolver'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}