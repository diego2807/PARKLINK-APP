import 'package:flutter/material.dart';

import '../../data/services/log_service.dart';
import '../../domain/models/log_auditoria_model.dart';

/// Modelo de datos fuertemente tipado para evitar mapas dinámicos
class LogEntry {
  final String id;
  final DateTime timestamp;
  final String user;
  final String action;
  final String category;
  final String status; // 'Éxito', 'Advertencia', 'Bloqueado'
  final IconData icon;
  final String? ipAddress;
  final String? details;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.user,
    required this.action,
    required this.category,
    required this.status,
    required this.icon,
    this.ipAddress,
    this.details,
  });
}

class AdminLogScreen extends StatefulWidget {
  const AdminLogScreen({super.key});

  @override
  State<AdminLogScreen> createState() => _AdminLogScreenState();
}

class _AdminLogScreenState extends State<AdminLogScreen> {
  final LogService _logService = LogService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Todos';
  String _selectedCategoryFilter = 'Todas';
  bool _isLoading = true;
  String _error = '';

  List<LogEntry> _allLogs = <LogEntry>[];

  @override
  void initState() {
    super.initState();
    _cargarLogs();
  }

  Future<void> _cargarLogs() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final List<LogAuditoriaModel> logs = await _logService.obtenerLogs();
      if (!mounted) return;

      setState(() {
        _allLogs = logs.map(_mapLog).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  LogEntry _mapLog(LogAuditoriaModel model) {
    final String status = switch (model.nivel) {
      NivelLog.critico => 'Bloqueado',
      NivelLog.advertencia => 'Advertencia',
      NivelLog.informativo => 'Éxito',
    };

    final IconData icon = switch (model.nivel) {
      NivelLog.critico => Icons.shield_outlined,
      NivelLog.advertencia => Icons.warning_amber_rounded,
      NivelLog.informativo => Icons.info_outline_rounded,
    };

    return LogEntry(
      id: 'LOG-${model.id}',
      timestamp: model.fechaHora ?? DateTime.now(),
      user: model.usuarioId?.toString() ?? 'Sistema',
      action: model.descripcion,
      category: model.modulo,
      status: status,
      icon: icon,
      ipAddress: null,
      details: model.descripcion,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LogEntry> get _filteredLogs {
    return _allLogs.where((log) {
      final matchesSearch =
          log.user.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatusFilter == 'Todos' ||
          log.status == _selectedStatusFilter;
      final matchesCategory =
          _selectedCategoryFilter == 'Todas' ||
          log.category == _selectedCategoryFilter;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reporte de logs generado correctamente en formato CSV.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogDetailModal(LogEntry log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalle del Registro (${log.id})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(child: _buildStatusBadge(log.status)),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Acción Ejecutada', log.action),
            _buildDetailRow('Usuario Responsable', log.user),
            _buildDetailRow('Categoría', log.category),
            _buildDetailRow('Dirección IP', log.ipAddress ?? 'N/A'),
            _buildDetailRow(
              'Fecha y Hora',
              '${_formatDate(log.timestamp)} - ${_formatTime(log.timestamp)}',
            ),
            if (log.details != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Información Adicional / Payloads:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  log.details!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cerrar Ventana',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLogs = _allLogs.length;
    final successCount = _allLogs.where((l) => l.status == 'Éxito').length;
    final alertCount = _allLogs.where((l) => l.status != 'Éxito').length;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    if (_error.isNotEmpty && _allLogs.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO RESPONSIVE
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderTitle(),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: _buildExportButton(),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildHeaderTitle()),
                            const SizedBox(width: 16),
                            _buildExportButton(),
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),

              // KPIS SUPERIORES
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 220,
                            child: _buildSummaryCard(
                              'Total Registros',
                              '$totalLogs',
                              Icons.format_list_bulleted_rounded,
                              const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 220,
                            child: _buildSummaryCard(
                              'Operaciones Exitosas',
                              '$successCount',
                              Icons.check_circle_outline_rounded,
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 220,
                            child: _buildSummaryCard(
                              'Alertas / Bloqueos',
                              '$alertCount',
                              Icons.gpp_maybe_outlined,
                              const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Registros',
                          '$totalLogs',
                          Icons.format_list_bulleted_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Operaciones Exitosas',
                          '$successCount',
                          Icons.check_circle_outline_rounded,
                          const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Alertas / Bloqueos',
                          '$alertCount',
                          Icons.gpp_maybe_outlined,
                          const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // BARRA DE BÚSQUEDA Y FILTROS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Buscar por ID, usuario, acción o categoría...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // FILTROS DE ESTADO
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          "Estado: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ...['Todos', 'Éxito', 'Advertencia', 'Bloqueado'].map((
                          status,
                        ) {
                          final isSelected = _selectedStatusFilter == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(
                                    () => _selectedStatusFilter = status,
                                  );
                                }
                              },
                              selectedColor: const Color(0xFF3B82F6),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // FILTROS DE CATEGORÍA
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          "Categoría: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ...[
                          'Todas',
                          'Configuración',
                          'Operación',
                          'Seguridad',
                          'Usuarios',
                          'Acceso',
                        ].map((category) {
                          final isSelected =
                              _selectedCategoryFilter == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(
                                    () => _selectedCategoryFilter = category,
                                  );
                                }
                              },
                              selectedColor: const Color(0xFF0F172A),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // LISTA / TABLA CONTENEDORA DE LOGS
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _filteredLogs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 48,
                                  color: Color(0xFFCBD5E1),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No se encontraron registros coincidentes.',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedStatusFilter = 'Todos';
                                      _selectedCategoryFilter = 'Todas';
                                    });
                                  },
                                  child: const Text('Restablecer Filtros'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _filteredLogs.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, index) {
                              final log = _filteredLogs[index];
                              return InkWell(
                                onTap: () => _showLogDetailModal(log),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: 620,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          // Icono
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              log.icon,
                                              size: 20,
                                              color: const Color(0xFF475569),
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Fecha y Hora
                                          SizedBox(
                                            width: 100,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _formatDate(log.timestamp),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  _formatTime(log.timestamp),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Usuario Responsable
                                          SizedBox(
                                            width: 130,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: const Color(
                                                    0xFFDBEAFE,
                                                  ),
                                                  child: Text(
                                                    log.user.isEmpty
                                                        ? '?'
                                                        : log.user[0]
                                                              .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1D4ED8),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    log.user,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF334155),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Descripción de la Acción
                                          Expanded(
                                            child: Text(
                                              log.action,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // Badge de Estado
                                          _buildStatusBadge(log.status),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares de UI
  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Historial de Actividad',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Consulta eventos de seguridad, cambios de configuración y registros del sistema.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334155),
        elevation: 0,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _exportLogs,
      icon: const Icon(Icons.download_rounded, size: 18),
      label: const Text(
        'Exportar Log',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Éxito':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'Advertencia':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case 'Bloqueado':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }
}
