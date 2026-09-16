import 'package:flutter/material.dart';

import '../../data/services/alerta_service.dart';
import '../../data/services/kpi_service.dart';
import 'KPIs.dart';
import 'Alertas.dart';
import '../../../celdas_mapa/presentation/screens/Celdas.dart';
import '../../../configuracion/presentation/screens/Config.dart';
import '../../../auditoria/presentation/screens/log.dart';
import '../../../usuarios/presentation/screens/Registro.dart';
import '../../../tendencias/presentation/screens/Tendencias.dart';
import '../../../vehiculos/presentation/screens/Vehiculos.dart';
import '../../../tendencias/presentation/screens/Reportes.dart';
import '../../../accesos/presentation/screens/Accesos.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final KpiService _kpiService = KpiService();
  final AlertaService _alertaService = AlertaService();

  int _currentIndex = 3;
  bool _isLoading = true;
  String _error = '';
  int _celdasDisponibles = 0;
  int _alertasActivas = 0;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final dashboard = await _kpiService.obtenerDashboard();
      final alertas = await _alertaService.obtenerAlertas();

      if (!mounted) return;

      setState(() {
        _celdasDisponibles = dashboard.ocupacion.celdasDisponibles;
        _alertasActivas = alertas.length;
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> adminScreens = [
      const AdminKpisScreen(),
      const AdminSpotsScreen(),
      const AdminAlertsScreen(),
      const AdminVehiclesScreen(),
      const AdminRegistroScreen(),
      const AdminTendenciasScreen(),
      const AdminLogScreen(),
      const AdminConfigScreen(),
      const AdminReportsScreen(),
      const AccesosScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          if (!_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  if (_error.isEmpty) ...[
                    _summaryChip(
                      'Celdas libres',
                      '$_celdasDisponibles',
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 10),
                    _summaryChip(
                      'Alertas',
                      '$_alertasActivas',
                      const Color(0xFFEF4444),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            )
          else
            const SizedBox(
              height: 54,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  elevation: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              backgroundColor: Colors.white,
                              selectedIndex: _currentIndex,
                              onDestinationSelected: (int index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              labelType: NavigationRailLabelType.all,
                              selectedIconTheme: const IconThemeData(
                                color: Color(0xFF3B82F6),
                              ),
                              selectedLabelTextStyle: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              unselectedIconTheme: const IconThemeData(
                                color: Color(0xFF64748B),
                              ),
                              unselectedLabelTextStyle: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(Icons.analytics_outlined),
                                  selectedIcon: Icon(Icons.analytics),
                                  label: Text('KPIs'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.grid_view_outlined),
                                  selectedIcon: Icon(Icons.grid_view),
                                  label: Text('Celdas'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.notifications_outlined),
                                  selectedIcon: Icon(Icons.notifications),
                                  label: Text('Alertas'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.directions_car_outlined),
                                  selectedIcon: Icon(Icons.directions_car),
                                  label: Text('Vehículos'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.app_registration_outlined),
                                  selectedIcon: Icon(Icons.app_registration),
                                  label: Text('Registro'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.trending_up_outlined),
                                  selectedIcon: Icon(Icons.trending_up),
                                  label: Text('Tendencias'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.history_outlined),
                                  selectedIcon: Icon(Icons.history),
                                  label: Text('Logs'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.settings_outlined),
                                  selectedIcon: Icon(Icons.settings),
                                  label: Text('Config'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.bar_chart_outlined),
                                  selectedIcon: Icon(Icons.bar_chart),
                                  label: Text('Reportes'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.security_outlined),
                                  selectedIcon: Icon(Icons.security),
                                  label: Text('Accesos'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Color(0xFFE2E8F0),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: adminScreens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
