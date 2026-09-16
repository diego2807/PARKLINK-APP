import 'package:flutter/material.dart';

import '../../data/services/alerta_service.dart';
import '../../domain/models/alerta_model.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  final AlertaService _alertaService = AlertaService();

  String _selectedFilter = 'Sin Resolver';
  bool _isLoading = true;
  String _error = '';
  final Set<int> _resueltas = <int>{};
  List<AlertaModel> _allAlerts = <AlertaModel>[];

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final List<AlertaModel> alertas = await _alertaService.obtenerAlertas();
      if (!mounted) return;
      setState(() {
        _allAlerts = alertas;
        _resueltas.clear();
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

  List<AlertaModel> get _filteredAlerts {
    switch (_selectedFilter) {
      case 'Sin Resolver':
        return _allAlerts
            .where((AlertaModel alerta) => !_resueltas.contains(alerta.id))
            .toList();
      case 'Resueltas':
        return _allAlerts
            .where((AlertaModel alerta) => _resueltas.contains(alerta.id))
            .toList();
      case 'Todas':
      default:
        return List<AlertaModel>.from(_allAlerts);
    }
  }

  Future<void> _markAsResolved(int alertaId) async {
    try {
      await _alertaService.eliminarAlerta(alertaId);
      if (!mounted) return;
      setState(() {
        _resueltas.add(alertaId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerta marcada como resuelta.'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo resolver la alerta: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int altas = _allAlerts
        .where(
          (AlertaModel alerta) =>
              alerta.severidad == SeveridadAlerta.urgente &&
              !_resueltas.contains(alerta.id),
        )
        .length;
    final int medias = _allAlerts
        .where(
          (AlertaModel alerta) =>
              alerta.severidad == SeveridadAlerta.advertencia &&
              !_resueltas.contains(alerta.id),
        )
        .length;
    final int bajas = _allAlerts
        .where(
          (AlertaModel alerta) =>
              alerta.severidad == SeveridadAlerta.informativo &&
              !_resueltas.contains(alerta.id),
        )
        .length;
    final int resueltas = _resueltas.length;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Color(0xFFEF4444),
                                  ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMetricStat(
                    'Alta',
                    '$altas',
                    const Color(0xFFEF4444),
                    Icons.error_outline,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricStat(
                    'Media',
                    '$medias',
                    const Color(0xFFF59E0B),
                    Icons.warning_amber_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricStat(
                    'Baja',
                    '$bajas',
                    const Color(0xFF3B82F6),
                    Icons.info_outline,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricStat(
                    'Resueltas',
                    '$resueltas',
                    const Color(0xFF10B981),
                    Icons.check_circle_outline,
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                          Icon(
                            Icons.done_all_rounded,
                            size: 48,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '¡Todo bajo control!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'No hay incidentes registrados en esta categoría.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredAlerts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final AlertaModel alerta = _filteredAlerts[index];
                        return _buildAlertCard(alerta);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricStat(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
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
                color: color.withValues(alpha: 0.1),
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
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
    final bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
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

  Widget _buildAlertCard(AlertaModel alerta) {
    final Color themeColor = switch (alerta.severidad) {
      SeveridadAlerta.urgente => const Color(0xFFEF4444),
      SeveridadAlerta.advertencia => const Color(0xFFF59E0B),
      SeveridadAlerta.informativo => const Color(0xFF3B82F6),
    };
    final Color chipBg = switch (alerta.severidad) {
      SeveridadAlerta.urgente => const Color(0xFFFEE2E2),
      SeveridadAlerta.advertencia => const Color(0xFFFEF3C7),
      SeveridadAlerta.informativo => const Color(0xFFDBEAFE),
    };
    final IconData icon = switch (alerta.severidad) {
      SeveridadAlerta.urgente => Icons.error_outline_rounded,
      SeveridadAlerta.advertencia => Icons.warning_amber_rounded,
      SeveridadAlerta.informativo => Icons.info_outline_rounded,
    };
    final bool isResolved = _resueltas.contains(alerta.id);

    return Container(
      decoration: BoxDecoration(
        color: isResolved ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isResolved
              ? const Color(0xFFCBD5E1)
              : themeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: isResolved
            ? <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
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
              color: isResolved
                  ? const Color(0xFFCBD5E1)
                  : themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isResolved ? Icons.check : icon,
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
                        alerta.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isResolved
                              ? const Color(0xFF64748B)
                              : const Color(0xFF0F172A),
                          decoration: isResolved
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isResolved ? const Color(0xFFE2E8F0) : chipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isResolved ? 'Resuelta' : alerta.severidadTexto,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isResolved
                              ? const Color(0xFF64748B)
                              : themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alerta.contenido,
                  style: TextStyle(
                    fontSize: 14,
                    color: isResolved
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alerta.tiempoRelativo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    if (!isResolved)
                      OutlinedButton.icon(
                        onPressed: () => _markAsResolved(alerta.id),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Resolver'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
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
