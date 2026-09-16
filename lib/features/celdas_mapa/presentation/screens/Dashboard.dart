import 'package:flutter/material.dart';

import '../../data/services/celda_service.dart';
import '../../domain/models/resumen_zona_model.dart';
import '../../../../app_theme.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final CeldaService _celdaService = CeldaService();

  bool _isLoading = true;
  int _totalCeldas = 0;
  int _totalDisponibles = 0;
  int _totalOcupadas = 0;
  String _zonaMasDisponible = '—';
  List<ResumenZonaModel> _zonas = <ResumenZonaModel>[];

  @override
  void initState() {
    super.initState();
    _loadResumen();
  }

  Future<void> _loadResumen() async {
    try {
      final resumen = await _celdaService.obtenerResumenPorZona();
      setState(() {
        _zonas = resumen;
        _totalCeldas = resumen.fold<int>(0, (sum, item) => sum + item.total);
        _totalDisponibles = resumen.fold<int>(
          0,
          (sum, item) => sum + item.disponibles,
        );
        _totalOcupadas = resumen.fold<int>(
          0,
          (sum, item) => sum + item.ocupadas,
        );
        _zonaMasDisponible = resumen.isEmpty
            ? '—'
            : resumen
                  .reduce((a, b) => a.disponibles >= b.disponibles ? a : b)
                  .zona;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _estadoDisponibilidad {
    if (_totalDisponibles <= 0) return 'Sin disponibilidad';
    if (_totalDisponibles <= _totalCeldas * 0.2) return 'Pocos espacios';
    return 'Hay disponibilidad';
  }

  Map<String, dynamic> get _resumenActual {
    if (_totalDisponibles <= 0) {
      return {
        'spot': 'Sin celdas libres',
        'vehicle': 'Disponibilidad actual: 0',
        'schedule': 'Actualización en vivo',
        'location': 'Todas las zonas ocupadas',
      };
    }

    return {
      'spot': '$_totalDisponibles disponibles',
      'vehicle': 'Disponibilidad real del parqueadero',
      'schedule': '$_totalOcupadas ocupadas / $_totalCeldas total',
      'location': 'Zona más disponible: $_zonaMasDisponible',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool hasAvailability = _totalDisponibles > 0;
    final Map<String, dynamic> activeReservation = _resumenActual;

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
              child: const Icon(
                Icons.local_parking_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Parklink Redeban",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/user/notifications'),
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
                const Text(
                  "¡Hola, Sara!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const Text(
                  "Gestión y reservas de parqueadero corporativo Redeban",
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),

                hasAvailability
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
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
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Disponibilidad en Tiempo Real",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          "Estado: ${_estadoDisponibilidad}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    activeReservation['spot'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      activeReservation['schedule'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  activeReservation['location'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
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
                          border: Border.all(
                            color: AppTheme.textMuted.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppTheme.textMuted,
                                  size: 28,
                                ),
                                SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sin disponibilidad actual",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      "Todas las celdas de las zonas están ocupadas.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/user/reservations',
                              ),
                              child: const Text('Reservar'),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 28),

                const Text(
                  "Módulos del Sistema",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
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
                        _buildNavCard(
                          context,
                          "Reservar Celda",
                          "Solicita tu espacio",
                          Icons.add_location_alt_rounded,
                          AppTheme.primary,
                          '/user/reservations',
                        ),
                        _buildNavCard(
                          context,
                          "Semáforo",
                          "Disponibilidad en vivo: $_totalDisponibles libres",
                          Icons.traffic_rounded,
                          AppTheme.warning,
                          '/user/traffic-light',
                        ),
                        _buildNavCard(
                          context,
                          "Mis Vehículos",
                          "${_totalCeldas} celdas activas",
                          Icons.directions_car_rounded,
                          AppTheme.accent,
                          '/user/vehicles',
                        ),
                        _buildNavCard(
                          context,
                          "Historial",
                          "$_totalOcupadas ocupadas",
                          Icons.history_rounded,
                          AppTheme.textDark,
                          '/user/history',
                        ),
                        _buildNavCard(
                          context,
                          "Notificaciones",
                          "Actualización en vivo",
                          Icons.notifications_active_rounded,
                          Colors.purple,
                          '/user/notifications',
                        ),
                        _buildNavCard(
                          context,
                          "Mi Perfil",
                          "Datos y seguridad",
                          Icons.person_rounded,
                          Colors.teal,
                          '/user/profile',
                        ),
                        _buildNavCard(
                          context,
                          "Ayuda",
                          "Soporte técnico",
                          Icons.help_outline_rounded,
                          Colors.blueGrey,
                          '/user/help',
                        ),
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

  Widget _buildNavCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
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
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
