import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import 'AperturaTurno.dart';
import 'Dashboard.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Simulación de estado de turno
  final bool _turnoAbierto = false;
  final String _nombreVigilante = "Andrés Gómez";

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final fecha = "${ahora.day}/${ahora.month}/${ahora.year}";

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Parklink Vigilancia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      child: const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hola, $_nombreVigilante", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          Text("Puesto de Vigilancia · $fecha", style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Tarjeta de estado del turno
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(
                      color: (_turnoAbierto ? AppTheme.success : AppTheme.warning).withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_turnoAbierto ? AppTheme.success : AppTheme.warning).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _turnoAbierto ? Icons.lock_open_rounded : Icons.lock_clock_rounded,
                              color: _turnoAbierto ? AppTheme.success : AppTheme.warning,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _turnoAbierto ? "Turno Activo" : "Turno Cerrado",
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _turnoAbierto
                            ? "Tu turno está en curso. Dirígete al panel de control para gestionar la garita."
                            : "Debes abrir tu turno antes de registrar entradas, salidas o novedades.",
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _turnoAbierto ? const VigilanteDashboardScreen() : const AperturaTurnoScreen(),
                              ),
                            );
                          },
                          icon: Icon(_turnoAbierto ? Icons.dashboard_rounded : Icons.play_arrow_rounded, color: Colors.white),
                          label: Text(
                            _turnoAbierto ? "Ir al Panel de Control" : "Abrir Turno",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Resumen rápido del día
                const Text("Resumen de Hoy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCard("Vehículos Dentro", "12", Icons.directions_car_rounded, AppTheme.primary),
                    const SizedBox(width: 12),
                    _statCard("Novedades", "2", Icons.report_gmailerrorred_rounded, AppTheme.warning),
                    const SizedBox(width: 12),
                    _statCard("Visitantes", "4", Icons.badge_rounded, AppTheme.accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
