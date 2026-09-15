import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../../accesos/presentation/screens/Control.dart';
import '../../../accesos/presentation/screens/FormularioEntrada.dart';
import '../../../accesos/presentation/screens/FormularioSalida.dart';
import '../../../accesos/presentation/screens/FormularioVisitantes.dart';
import '../../../accesos/presentation/screens/ListaVehiculosActivo.dart';
import '../../../celdas_mapa/presentation/screens/MapaGrafico.dart';
import 'RegistroNovedades.dart';
import 'Incidentes.dart';
import 'ConsolaTransferencia.dart';
import 'HistorialTurno.dart';
import 'CierreTurno.dart';

class VigilanteDashboardScreen extends StatelessWidget {
  const VigilanteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Panel Vigilante", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar turno",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CierreTurnoScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de ocupación resumida
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.local_parking_rounded, color: AppTheme.primary, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ocupación Actual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                            SizedBox(height: 2),
                            Text("15 de 30 celdas ocupadas", style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ControlScreen())),
                        icon: const Icon(Icons.bar_chart_rounded, size: 18),
                        label: const Text("Ver panel"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                const Text("Módulos de Vigilancia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildNavCard(context, "Control", "Panel general", Icons.dashboard_customize_rounded, AppTheme.primary, const ControlScreen()),
                        _buildNavCard(context, "Registrar Entrada", "Ingreso de vehículos", Icons.login_rounded, AppTheme.success, const FormularioEntradaScreen()),
                        _buildNavCard(context, "Registrar Salida", "Salida de vehículos", Icons.logout_rounded, AppTheme.accent, const FormularioSalidaScreen()),
                        _buildNavCard(context, "Visitantes", "Registro de visitas", Icons.badge_rounded, Colors.teal, const FormularioVisitantesScreen()),
                        _buildNavCard(context, "Vehículos Activos", "Dentro del parqueadero", Icons.directions_car_rounded, AppTheme.primary, const ListaVehiculosActivoScreen()),
                        _buildNavCard(context, "Mapa Gráfico", "Estado de celdas", Icons.grid_view_rounded, Colors.indigo, const MapaGraficoScreen()),
                        _buildNavCard(context, "Novedades", "Registro del turno", Icons.notes_rounded, AppTheme.warning, const RegistroNovedadesScreen()),
                        _buildNavCard(context, "Incidencias", "Reportar incidente", Icons.report_gmailerrorred_rounded, Colors.redAccent, const VigilanteIncidentsScreen()),
                        _buildNavCard(context, "Transferencia", "Cambio de turno", Icons.swap_horiz_rounded, Colors.deepPurple, const ConsolaTransferenciaScreen()),
                        _buildNavCard(context, "Historial", "Turnos anteriores", Icons.history_rounded, AppTheme.textDark, const HistorialTurnoScreen()),
                      ],
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

  Widget _buildNavCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget destino) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}