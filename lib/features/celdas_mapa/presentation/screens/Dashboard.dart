import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  // Simulación del estado de la reserva activa del usuario
  bool _hasActiveReservation = true;
  final Map<String, dynamic> _activeReservation = {
    'spot': 'Celda A-12',
    'vehicle': 'ABC-123 (Carro)',
    'schedule': '08:00 AM - 05:00 PM',
    'location': 'Sede Principal Redeban',
  };

  void _showCancelReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancelar Reserva', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas cancelar tu reserva activa para el día de hoy? Esta acción liberará la celda.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Volver', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  _hasActiveReservation = false;
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva cancelada con éxito.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text("Parklink Redeban", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/user/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/user/profile'),
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
                // Bienvenida
                const Text("¡Hola, Sara!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const Text("Gestión y reservas de parqueadero corporativo Redeban", style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                const SizedBox(height: 24),

                // Tarjeta Reserva Activa o Estado Vacío
                _hasActiveReservation
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
                                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Reserva Activa Hoy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                                        Text("Vehículo: ${_activeReservation['vehicle']}", style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                                      child: Text(_activeReservation['spot'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 22),
                                      tooltip: 'Cancelar reserva',
                                      onPressed: _showCancelReservationDialog,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 16, color: AppTheme.textMuted),
                                    const SizedBox(width: 6),
                                    Text(_activeReservation['schedule'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                  ],
                                ),
                                Text(_activeReservation['location'], style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                          border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: AppTheme.textMuted, size: 28),
                                SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Sin reserva activa hoy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                                    Text("Asegura tu espacio corporativo con anticipación.", style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/user/reservations'),
                              child: const Text('Reservar'),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 28),

                // Título Módulos
                const Text("Módulos del Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 16),

                // Grilla Compacta
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
                        _buildNavCard(context, "Reservar Celda", "Solicita tu espacio", Icons.add_location_alt_rounded, AppTheme.primary, '/user/reservations'),
                        _buildNavCard(context, "Semáforo", "Disponibilidad en vivo", Icons.traffic_rounded, AppTheme.warning, '/user/traffic-light'),
                        _buildNavCard(context, "Mis Vehículos", "2 Registrados", Icons.directions_car_rounded, AppTheme.accent, '/user/vehicles'),
                        _buildNavCard(context, "Historial", "Reservas pasadas", Icons.history_rounded, AppTheme.textDark, '/user/history'),
                        _buildNavCard(context, "Notificaciones", "3 Novedades", Icons.notifications_active_rounded, Colors.purple, '/user/notifications'),
                        _buildNavCard(context, "Mi Perfil", "Datos y seguridad", Icons.person_rounded, Colors.teal, '/user/profile'),
                        _buildNavCard(context, "Ayuda", "Soporte técnico", Icons.help_outline_rounded, Colors.blueGrey, '/user/help'),
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

  Widget _buildNavCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
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