import 'package:flutter/material.dart';

import '../../data/services/celda_service.dart';
import '../../domain/models/celda_model.dart';
import '../../domain/models/resumen_zona_model.dart';
import '../../../../app_theme.dart';

class UserTrafficLightScreen extends StatefulWidget {
  const UserTrafficLightScreen({Key? key}) : super(key: key);

  @override
  State<UserTrafficLightScreen> createState() => _UserTrafficLightScreenState();
}

class _UserTrafficLightScreenState extends State<UserTrafficLightScreen> {
  final CeldaService _celdaService = CeldaService();
  bool _isLoading = true;
  String _filtroVehiculo = 'Todos';
  List<ResumenZonaModel> _zonas = <ResumenZonaModel>[];

  @override
  void initState() {
    super.initState();
    _loadZonas();
  }

  Future<void> _loadZonas() async {
    try {
      final resumen = await _celdaService.obtenerResumenPorZona();
      setState(() {
        _zonas = resumen;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<ResumenZonaModel> get _zonasFiltradas {
    if (_filtroVehiculo == 'Carros') {
      return _zonas
          .where(
            (zona) =>
                zona.celdas.any((celda) => !celda.tipoCelda.contains('moto')),
          )
          .toList();
    }
    if (_filtroVehiculo == 'Motos') {
      return _zonas
          .where(
            (zona) =>
                zona.celdas.any((celda) => celda.tipoCelda.contains('moto')),
          )
          .toList();
    }
    return _zonas;
  }

  int get _totalCeldas => _zonas.fold(0, (sum, item) => sum + item.total);
  int get _totalOcupadas => _zonas.fold(0, (sum, item) => sum + item.ocupadas);
  int get _totalLibres => _totalCeldas - _totalOcupadas;

  Color _getColorEstado(double porcentaje) {
    if (porcentaje >= 1.0) {
      return AppTheme.accent;
    } else if (porcentaje >= 0.75) {
      return Colors.orange;
    } else {
      return AppTheme.success;
    }
  }

  String _getEtiquetaEstado(double porcentaje) {
    if (porcentaje >= 1.0) {
      return 'Lleno Total';
    } else if (porcentaje >= 0.75) {
      return 'Pocos Espacios';
    } else {
      return 'Alta Disponibilidad';
    }
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconoZona(List<CeldaModel> celdas) {
    final contieneMoto = celdas.any(
      (celda) => celda.tipoCelda.contains('moto'),
    );
    return contieneMoto
        ? Icons.two_wheeler_rounded
        : Icons.directions_car_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Semáforo de Disponibilidad',
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF1A365D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Estado en Tiempo Real',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ocupación General Redeban',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${_totalCeldas == 0 ? 0 : ((_totalOcupadas / _totalCeldas) * 100).round()}% Ocupado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildSummaryCard(
                      'Celdas Libres',
                      '$_totalLibres',
                      Icons.event_seat_rounded,
                      AppTheme.success,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      'Celdas Ocupadas',
                      '$_totalOcupadas',
                      Icons.time_to_leave_rounded,
                      AppTheme.accent,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      'Capacidad Total',
                      '$_totalCeldas',
                      Icons.local_parking_rounded,
                      AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: ['Todos', 'Carros', 'Motos'].map((filtro) {
                    bool selected = _filtroVehiculo == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filtro),
                        selected: selected,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppTheme.textDark,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: AppTheme.cardBg,
                        onSelected: (bool isSelected) {
                          if (isSelected) {
                            setState(() => _filtroVehiculo = filtro);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _zonasFiltradas.length,
                  itemBuilder: (context, index) {
                    final zona = _zonasFiltradas[index];
                    final ocupadas = zona.ocupadas;
                    final total = zona.total;
                    final libres = zona.disponibles;
                    final porcentaje = zona.fraccionOcupacion;
                    final colorEstado = _getColorEstado(porcentaje);
                    final estadoTexto = _getEtiquetaEstado(porcentaje);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.cardShadow,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.04),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorEstado.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconoZona(zona.celdas),
                                      color: colorEstado,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    zona.zona,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorEstado.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  estadoTexto,
                                  style: TextStyle(
                                    color: colorEstado,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: porcentaje,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorEstado,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Celdas ocupadas: $ocupadas / $total',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                '$libres celdas libres',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: libres > 0
                                      ? colorEstado
                                      : AppTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
