import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../data/services/notificacion_service.dart';
import '../../domain/models/notificacion_model.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  State<UserNotificationsScreen> createState() =>
      _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
  final NotificacionService _notificacionService = NotificacionService();

  String _filtroSel = 'Todas';
  bool _isLoading = true;
  String _error = '';
  List<NotificacionModel> _notificaciones = <NotificacionModel>[];

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final List<NotificacionModel> notificaciones = await _notificacionService
          .obtenerNotificaciones();
      if (!mounted) return;
      setState(() {
        _notificaciones = notificaciones;
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

  int get _noLeidasCount =>
      _notificaciones.where((NotificacionModel n) => !n.leida).length;

  List<NotificacionModel> get _notificacionesFiltradas {
    switch (_filtroSel) {
      case 'Sin leer':
        return _notificaciones
            .where((NotificacionModel n) => !n.leida)
            .toList();
      case 'Importantes':
        return _notificaciones
            .where((NotificacionModel n) => !n.leida || n.esDeHoy)
            .toList();
      case 'Todas':
      default:
        return List<NotificacionModel>.from(_notificaciones);
    }
  }

  void _marcarTodasLeidas() {
    setState(() {
      _notificaciones = _notificaciones
          .map((NotificacionModel n) => n.copyWith(leida: true))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones fueron marcadas como leídas'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleLeida(int id) {
    setState(() {
      _notificaciones = _notificaciones
          .map(
            (NotificacionModel n) =>
                n.id == id ? n.copyWith(leida: !n.leida) : n,
          )
          .toList();
    });
  }

  void _eliminarNotificacion(int id) {
    setState(() {
      _notificaciones.removeWhere((NotificacionModel n) => n.id == id);
    });
  }

  IconData _getIcono(NotificacionModel notificacion) {
    final String texto = notificacion.descripcion.toLowerCase();
    if (texto.contains('reserva')) return Icons.event_available_rounded;
    if (texto.contains('recordatorio') || texto.contains('salida')) {
      return Icons.alarm_rounded;
    }
    if (texto.contains('mantenimiento') || texto.contains('cierre')) {
      return Icons.build_circle_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _getColor(NotificacionModel notificacion) {
    final String texto = notificacion.descripcion.toLowerCase();
    if (texto.contains('reserva')) return AppTheme.success;
    if (texto.contains('recordatorio') || texto.contains('salida')) {
      return Colors.orange;
    }
    if (texto.contains('mantenimiento') || texto.contains('cierre')) {
      return AppTheme.primary;
    }
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                      if (_error.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Bandeja de Entrada',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              if (_noLeidasCount > 0) ...<Widget>[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$_noLeidasCount nuevas',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_noLeidasCount > 0)
                            TextButton.icon(
                              onPressed: _marcarTodasLeidas,
                              icon: const Icon(
                                Icons.done_all_rounded,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                              label: const Text(
                                'Marcar leídas',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <String>['Todas', 'Sin leer', 'Importantes']
                            .map((String categoria) {
                              final bool selected = _filtroSel == categoria;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(categoria),
                                  selected: selected,
                                  selectedColor: AppTheme.primary,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textDark,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      if (_notificacionesFiltradas.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No tienes notificaciones en esta categoría',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notificacionesFiltradas.length,
                          itemBuilder: (BuildContext context, int index) {
                            final NotificacionModel item =
                                _notificacionesFiltradas[index];
                            final bool leida = item.leida;
                            final Color colorTipo = _getColor(item);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: leida
                                    ? AppTheme.cardBg
                                    : Colors.blue.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.cardShadow,
                                border: Border.all(
                                  color: leida
                                      ? Colors.black.withValues(alpha: 0.03)
                                      : AppTheme.primary.withValues(alpha: 0.2),
                                  width: leida ? 1 : 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () => _toggleLeida(item.id),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorTipo.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            _getIcono(item),
                                            color: colorTipo,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.titulo,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: leida
                                                            ? FontWeight.normal
                                                            : FontWeight.bold,
                                                        color: leida
                                                            ? AppTheme.textMuted
                                                            : AppTheme.textDark,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    item.tiempoRelativo,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppTheme.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item.descripcion,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: leida
                                                      ? AppTheme.textMuted
                                                      : AppTheme.textDark
                                                            .withValues(
                                                              alpha: 0.85,
                                                            ),
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
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
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                                color: AppTheme.textMuted,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () =>
                                                  _eliminarNotificacion(
                                                    item.id,
                                                  ),
                                              tooltip: 'Eliminar',
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
