import 'package:flutter/material.dart';

import '../../data/services/tendencia_service.dart';
import '../../domain/models/tendencia_model.dart';

class AdminTendenciasScreen extends StatefulWidget {
  const AdminTendenciasScreen({super.key});

  @override
  State<AdminTendenciasScreen> createState() => _AdminTendenciasScreenState();
}

class _AdminTendenciasScreenState extends State<AdminTendenciasScreen> {
  final TendenciaService _tendenciaService = TendenciaService();

  String _selectedPeriod = 'Semanal';
  RangoTendencia _rangoSeleccionado = RangoTendencia.semana;
  TendenciaModel _tendencia = TendenciaModel.vacio();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTendencias();
  }

  Future<void> _cargarTendencias() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final TendenciaModel respuesta = await _tendenciaService
          .obtenerTendencias(rango: _rangoSeleccionado);

      if (!mounted) return;
      setState(() => _tendencia = respuesta);
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

  Future<void> _cambiarPeriodo(String period) async {
    final RangoTendencia nuevoRango = switch (period) {
      'Hoy' => RangoTendencia.hoy,
      'Mensual' => RangoTendencia.mes,
      _ => RangoTendencia.semana,
    };

    if (nuevoRango == _rangoSeleccionado && _selectedPeriod == period) return;

    setState(() {
      _selectedPeriod = period;
      _rangoSeleccionado = nuevoRango;
    });

    await _cargarTendencias();
  }

  List<Map<String, dynamic>> get _dayData {
    final List<DiaPicoModel> dias = _tendencia.diasPico;
    if (dias.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final int maximo = _tendencia.maximoIngresosDia;
    return dias
        .map(
          (DiaPicoModel dia) => {
            'day': dia.diaCorto,
            'percentage': maximo == 0 ? 0.0 : dia.ingresos / maximo,
            'label': '${dia.ingresos}',
          },
        )
        .toList();
  }

  Color _getBarColor(double value) {
    if (value >= 0.90) return const Color(0xFFEF4444);
    if (value >= 0.70) return const Color(0xFF3B82F6);
    if (value >= 0.40) return const Color(0xFF10B981);
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context) {
    final DiaPicoModel? diaMasConcurrido = _tendencia.diaMasConcurrido;
    final HoraPicoModel? horaMasConcurrida = _tendencia.franjaMasConcurrida;
    final List<HoraPicoModel> horasResumen = _tendencia.horasPico.length > 3
        ? _tendencia.horasPico.take(3).toList()
        : _tendencia.horasPico;

    final int maximoIngresosHora = horasResumen.isEmpty
        ? 0
        : horasResumen
              .map((HoraPicoModel item) => item.cantidadIngresos)
              .reduce((int a, int b) => a > b ? a : b);

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
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...<Widget>[
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 18),
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 900) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Hora Pico Principal',
                                  horaMasConcurrida?.hora ?? 'Sin datos',
                                  horaMasConcurrida?.flujo ?? 'Sin información',
                                  Icons.access_time_filled_rounded,
                                  const Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Día Con Mayor Flujo',
                                  diaMasConcurrido != null
                                      ? '${diaMasConcurrido.dia} (${diaMasConcurrido.ingresos})'
                                      : 'Sin datos',
                                  'Mayor volumen del período',
                                  Icons.trending_up_rounded,
                                  const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Tiempo Promedio',
                                  _tendencia.metricasPrediccion.tiempoPromedio,
                                  _tendencia
                                      .metricasPrediccion
                                      .perfilPredominante,
                                  Icons.timer_outlined,
                                  const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _buildStatCard(
                              'Hora Pico Principal',
                              horaMasConcurrida?.hora ?? 'Sin datos',
                              horaMasConcurrida?.flujo ?? 'Sin información',
                              Icons.access_time_filled_rounded,
                              const Color(0xFFF59E0B),
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              'Día Con Mayor Flujo',
                              diaMasConcurrido != null
                                  ? '${diaMasConcurrido.dia} (${diaMasConcurrido.ingresos})'
                                  : 'Sin datos',
                              'Mayor volumen del período',
                              Icons.trending_up_rounded,
                              const Color(0xFFEF4444),
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              'Tiempo Promedio',
                              _tendencia.metricasPrediccion.tiempoPromedio,
                              _tendencia.metricasPrediccion.perfilPredominante,
                              Icons.timer_outlined,
                              const Color(0xFF3B82F6),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isDesktop = constraints.maxWidth >= 950;

                        Widget chartSection = Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ingresos por Día',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          children: [
                                            _LegendDot(
                                              color: Color(0xFFEF4444),
                                              label: 'Alto',
                                            ),
                                            _LegendDot(
                                              color: Color(0xFF3B82F6),
                                              label: 'Medio',
                                            ),
                                            _LegendDot(
                                              color: Color(0xFF10B981),
                                              label: 'Bajo',
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  return const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ingresos por Día',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _LegendDot(
                                            color: Color(0xFFEF4444),
                                            label: 'Alto',
                                          ),
                                          SizedBox(width: 12),
                                          _LegendDot(
                                            color: Color(0xFF3B82F6),
                                            label: 'Medio',
                                          ),
                                          SizedBox(width: 12),
                                          _LegendDot(
                                            color: Color(0xFF10B981),
                                            label: 'Bajo',
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 28),
                              if (_dayData.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'No hay datos disponibles para este rango.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    height: 200,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: _dayData.map((data) {
                                        final double percentage =
                                            (data['percentage'] as num)
                                                .toDouble();
                                        final double height = percentage <= 0
                                            ? 8
                                            : 18 + (150 * percentage);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                data['label'] as String,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getBarColor(
                                                    percentage,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 500,
                                                ),
                                                width: 34,
                                                height: height,
                                                decoration: BoxDecoration(
                                                  color: _getBarColor(
                                                    percentage,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Afluencia por Turno',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (horasResumen.isEmpty)
                                    const Text(
                                      'No hay franjas horarias registradas.',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    )
                                  else
                                    ...horasResumen.map((HoraPicoModel hora) {
                                      final double percentage =
                                          maximoIngresosHora == 0
                                          ? 0.0
                                          : (hora.cantidadIngresos /
                                                    maximoIngresosHora)
                                                .clamp(0.0, 1.0);
                                      final Color barColor = percentage > 0.8
                                          ? const Color(0xFFEF4444)
                                          : percentage > 0.5
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF10B981);

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildShiftRow(
                                          hora.hora,
                                          percentage,
                                          hora.flujo,
                                          barColor,
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Recomendación del Sistema',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          diaMasConcurrido != null
                                              ? 'El mayor flujo de vehículos se registra en ${diaMasConcurrido.dia} con ${diaMasConcurrido.ingresos} ingresos.'
                                              : 'Aún no hay suficiente información para recomendar cambios.',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF1E3A8A),
                                          ),
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
                        }

                        return Column(
                          children: [
                            chartSection,
                            const SizedBox(height: 20),
                            sideSection,
                          ],
                        );
                      },
                    ),
                  ],
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
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
    const List<String> periods = <String>['Hoy', 'Semanal', 'Mensual'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final bool isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () => _cambiarPeriodo(period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
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
              color: color.withValues(alpha: 0.1),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftRow(
    String title,
    double percentage,
    String label,
    Color barColor,
  ) {
    return Column(
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
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
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
