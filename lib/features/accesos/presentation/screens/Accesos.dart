import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class AccesosScreen extends StatelessWidget {
  const AccesosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          "Gestión de Accesos - Parklink",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botón de Cerrar Sesión en la AppBar
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Redirige al login y limpia el historial
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              "Cerrar Sesión",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                // Tarjeta de bienvenida / módulo
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  shadowColor: Colors.black12,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: AppTheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Módulo de Control de Accesos",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Supervisa y administra el flujo vehicular y de visitantes en tiempo real para Redeban.",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Opciones de Acceso",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 14),

                // Opciones o tarjetas de navegación internas de accesos
                _buildAccessOption(
                  context,
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppTheme.primary,
                  title: "Registro de Visitantes",
                  subtitle:
                      "Ingresa datos de personas externas y vehículos temporales",
                  onTap: () {
                    // Acción o navegación interna si aplica
                  },
                ),
                const SizedBox(height: 12),
                _buildAccessOption(
                  context,
                  icon: Icons.logout_rounded,
                  color: AppTheme.accent,
                  title: "Registro de Salida",
                  subtitle:
                      "Busca la placa y libera espacios de estacionamiento ocupados",
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildAccessOption(
                  context,
                  icon: Icons.directions_car_rounded,
                  color: AppTheme.success,
                  title: "Vehículos Activos",
                  subtitle:
                      "Consulta el listado completo de vehículos actualmente dentro de las instalaciones",
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildAccessOption(
                  context,
                  icon: Icons.history_rounded,
                  color: Colors.purple,
                  title: "Historial de Movimientos",
                  subtitle:
                      "Revisa el registro histórico de todas las entradas y salidas registradas",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las tarjetas de opciones
  Widget _buildAccessOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppTheme.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
