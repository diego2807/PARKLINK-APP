import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../data/services/turno_service.dart';
import '../../domain/models/turno_model.dart';

class HistorialTurnoScreen extends StatefulWidget {
  const HistorialTurnoScreen({super.key});

  @override
  State<HistorialTurnoScreen> createState() => _HistorialTurnoScreenState();
}

class _HistorialTurnoScreenState extends State<HistorialTurnoScreen> {
  final TurnoService _turnoService = TurnoService();
  late Future<List<TurnoModel>> _turnosFuture;

  @override
  void initState() {
    super.initState();
    _turnosFuture = _turnoService.obtenerMisTurnos();
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '--';
    final meses = <String>[
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Historial de Turnos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<TurnoModel>>(
        future: _turnosFuture,
        builder: (context, snapshot) {
          final turnos = snapshot.data ?? <TurnoModel>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: turnos.length,
                itemBuilder: (context, index) {
                  final turno = turnos[index];
                  final fecha = _formatearFecha(turno.fechaApertura);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
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
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.event_note_rounded,
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  fecha,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
                                color: AppTheme.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                turno.estadoTexto,
                                style: const TextStyle(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${turno.jornadaTexto} · ${turno.estadoTexto}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _miniStat(
                              Icons.login_rounded,
                              '${turno.totalEntradas ?? 0}',
                              'Entradas',
                              AppTheme.success,
                            ),
                            _miniStat(
                              Icons.logout_rounded,
                              '${turno.totalSalidas ?? 0}',
                              'Salidas',
                              AppTheme.primary,
                            ),
                            _miniStat(
                              Icons.report_gmailerrorred_rounded,
                              '${turno.totalNovedades ?? 0}',
                              'Novedades',
                              AppTheme.warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
