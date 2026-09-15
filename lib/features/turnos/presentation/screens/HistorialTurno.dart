import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class HistorialTurnoScreen extends StatelessWidget {
  const HistorialTurnoScreen({super.key});

  final List<Map<String, dynamic>> _turnos = const [
    {"fecha": "08 Sep 2026", "jornada": "Mañana (06:00 - 14:00)", "puesto": "Puerta Principal", "entradas": 22, "salidas": 20, "novedades": 1},
    {"fecha": "07 Sep 2026", "jornada": "Tarde (14:00 - 22:00)", "puesto": "Sótano 1", "entradas": 15, "salidas": 15, "novedades": 0},
    {"fecha": "05 Sep 2026", "jornada": "Noche (22:00 - 06:00)", "puesto": "Torre A", "entradas": 6, "salidas": 6, "novedades": 2},
    {"fecha": "04 Sep 2026", "jornada": "Mañana (06:00 - 14:00)", "puesto": "Puerta Principal", "entradas": 19, "salidas": 18, "novedades": 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text("Historial de Turnos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _turnos.length,
            itemBuilder: (context, index) {
              final t = _turnos[index];
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
                              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.event_note_rounded, color: AppTheme.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(t["fecha"] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: const Text("Cerrado", style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("${t["jornada"]} · ${t["puesto"]}", style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniStat(Icons.login_rounded, "${t["entradas"]}", "Entradas", AppTheme.success),
                        _miniStat(Icons.logout_rounded, "${t["salidas"]}", "Salidas", AppTheme.primary),
                        _miniStat(Icons.report_gmailerrorred_rounded, "${t["novedades"]}", "Novedades", AppTheme.warning),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
      ],
    );
  }
}