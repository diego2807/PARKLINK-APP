import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<UserNotificationsScreen> createState() => _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
  String _filtroSel = "Todas";

  List<Map<String, dynamic>> _notificaciones = [
    {
      "id": "1",
      "titulo": "Reserva Confirmada",
      "mensaje": "Celda A-12 reservada con éxito para el día de hoy.",
      "tiempo": "Hace 10 min",
      "tipo": "reserva", // reserva, recordatorio, mantenimiento
      "leida": false,
      "importante": true,
    },
    {
      "id": "2",
      "titulo": "Recordatorio de Salida",
      "mensaje": "Tu tiempo de parqueo finaliza a las 05:00 PM. Por favor retira tu vehículo a tiempo.",
      "tiempo": "Hace 2 horas",
      "tipo": "recordatorio",
      "leida": false,
      "importante": false,
    },
    {
      "id": "3",
      "titulo": "Mantenimiento Programado",
      "mensaje": "Sótano 1 estará cerrado mañana por labores de limpieza y pintura de celdas.",
      "tiempo": "Ayer",
      "tipo": "mantenimiento",
      "leida": true,
      "importante": true,
    },
    {
      "id": "4",
      "titulo": "Semáforo Actualizado",
      "mensaje": "Nivel de ocupación media en Sótano 2. Disponibilidad de 15 celdas.",
      "tiempo": "Hace 2 días",
      "tipo": "mantenimiento",
      "leida": true,
      "importante": false,
    },
  ];

  int get _noLeidasCount => _notificaciones.where((n) => !n["leida"]).length;

  List<Map<String, dynamic>> get _notificacionesFiltradas {
    if (_filtroSel == "Sin leer") {
      return _notificaciones.where((n) => !n["leida"]).toList();
    } else if (_filtroSel == "Importantes") {
      return _notificaciones.where((n) => n["importante"] == true).toList();
    }
    return _notificaciones;
  }

  void _marcarTodasLeidas() {
    setState(() {
      for (var n in _notificaciones) {
        n["leida"] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Todas las notificaciones fueron marcadas como leídas"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Actualizado para buscar por ID y evitar desalineación con los filtros
  void _toggleLeida(String id) {
    setState(() {
      final index = _notificaciones.indexWhere((n) => n["id"] == id);
      if (index != -1) {
        _notificaciones[index]["leida"] = !_notificaciones[index]["leida"];
      }
    });
  }

  void _eliminarNotificacion(String id) {
    setState(() {
      _notificaciones.removeWhere((n) => n["id"] == id);
    });
  }

  IconData _getIcono(String tipo) {
    switch (tipo) {
      case "reserva":
        return Icons.event_available_rounded;
      case "recordatorio":
        return Icons.alarm_rounded;
      case "mantenimiento":
        return Icons.build_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case "reserva":
        return AppTheme.success;
      case "recordatorio":
        return Colors.orange;
      case "mantenimiento":
        return AppTheme.primary;
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text("Notificaciones", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header de Notificaciones con Badge y Botón Limpiar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("Bandeja de Entrada", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              if (_noLeidasCount > 0) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$_noLeidasCount nuevas",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_noLeidasCount > 0)
                            TextButton.icon(
                              onPressed: _marcarTodasLeidas,
                              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppTheme.primary),
                              label: const Text("Marcar leídas", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filtros por Categoría
                      Row(
                        children: ["Todas", "Sin leer", "Importantes"].map((categoria) {
                          bool selected = _filtroSel == categoria;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(categoria),
                              selected: selected,
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AppTheme.textDark,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              backgroundColor: AppTheme.cardBg,
                              onSelected: (bool isSelected) {
                                if (isSelected) {
                                  setState(() => _filtroSel = categoria);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Lista de Notificaciones
                      if (_notificacionesFiltradas.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text("No tienes notificaciones en esta categoría", style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notificacionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final item = _notificacionesFiltradas[index];
                            bool leida = item["leida"];
                            Color colorTipo = _getColor(item["tipo"]);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: leida ? AppTheme.cardBg : Colors.blue.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.cardShadow,
                                border: Border.all(
                                  color: leida ? Colors.black.withOpacity(0.03) : AppTheme.primary.withOpacity(0.2),
                                  width: leida ? 1 : 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () => _toggleLeida(item["id"]),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icono de Notificación según tipo
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorTipo.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(_getIcono(item["tipo"]), color: colorTipo, size: 24),
                                        ),
                                        const SizedBox(width: 14),

                                        // Contenido de la notificación
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item["titulo"],
                                                      style: TextStyle(
                                                        fontWeight: leida ? FontWeight.w600 : FontWeight.bold,
                                                        fontSize: 15,
                                                        color: AppTheme.textDark,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(item["tiempo"], style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item["mensaje"],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: leida ? AppTheme.textMuted : AppTheme.textDark.withOpacity(0.85),
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Indicador No Leída & Opciones
                                        Column(
                                          children: [
                                            if (!leida)
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            else
                                              const SizedBox(height: 10),
                                            const SizedBox(height: 8),
                                            IconButton(
                                              icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textMuted),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => _eliminarNotificacion(item["id"]),
                                              tooltip: "Eliminar",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}