import 'package:flutter/material.dart';

import '../../data/services/celda_service.dart';
import '../../domain/models/celda_model.dart';
import '../../../../app_theme.dart';

class MapaGraficoScreen extends StatefulWidget {
  const MapaGraficoScreen({super.key});

  @override
  State<MapaGraficoScreen> createState() => _MapaGraficoScreenState();
}

class _MapaGraficoScreenState extends State<MapaGraficoScreen> {
  final CeldaService _celdaService = CeldaService();
  bool _isLoading = true;

  String _zonaSeleccionada = '';
  List<String> _zonas = <String>[];
  final Map<String, List<CeldaModel>> _mapaCeldas =
      <String, List<CeldaModel>>{};

  @override
  void initState() {
    super.initState();
    _loadCeldas();
  }

  Future<void> _loadCeldas() async {
    try {
      final celdas = await _celdaService.obtenerCeldas();
      final mapa = <String, List<CeldaModel>>{};

      for (final celda in celdas) {
        final key = celda.zona;
        mapa.putIfAbsent(key, () => <CeldaModel>[]).add(celda);
      }

      setState(() {
        _mapaCeldas
          ..clear()
          ..addAll(mapa);
        _zonas = mapa.keys.toList()..sort();
        _zonaSeleccionada = _zonas.isNotEmpty ? _zonas.first : '';
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mostrarDetalle(CeldaModel celda) async {
    final estado = celda.estadoClave;
    final bool disponible = celda.disponible;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.local_parking_rounded,
              color: estado == 'ocupado' ? AppTheme.accent : AppTheme.success,
            ),
            const SizedBox(width: 10),
            Text(
              'Celda ${celda.codigoCelda}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          estado == 'ocupado'
              ? 'La celda está ocupada actualmente.'
              : 'La celda está disponible para asignación inmediata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
          if (disponible)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reservar'),
            ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _celdaService.cambiarEstadoCelda(
          celdaId: celda.id,
          ocupada: true,
        );
        await _loadCeldas();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Celda ${celda.codigoCelda} reservada con éxito!'),
            backgroundColor: AppTheme.success,
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo reservar la celda.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final celdas = _mapaCeldas[_zonaSeleccionada] ?? <CeldaModel>[];
    final disponibles = celdas.where((c) => c.disponible).length;

    if (_zonas.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          elevation: 0,
          title: const Text(
            'Mapa Gráfico',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: Text('No hay celdas disponibles.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Mapa Gráfico',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _zonaSeleccionada,
                          items: _zonas
                              .map(
                                (z) => DropdownMenuItem(
                                  value: z,
                                  child: Text(
                                    z,
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(
                            () => _zonaSeleccionada = val ?? _zonas.first,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _leyenda(
                            'Disponible',
                            const Color(0xFFE8F5E9),
                            AppTheme.success,
                          ),
                          _leyenda(
                            'Ocupado',
                            Colors.grey[200]!,
                            Colors.grey[500]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Celdas de la zona',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '$disponibles disponibles',
                      style: const TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: celdas.length,
                  itemBuilder: (context, index) {
                    final celda = celdas[index];
                    final estado = celda.estadoClave;

                    Color bg;
                    Color border;
                    Color text;
                    IconData icon;

                    switch (estado) {
                      case 'ocupado':
                        bg = Colors.grey[100]!;
                        border = Colors.grey[300]!;
                        text = Colors.grey[600]!;
                        icon = Icons.directions_car_rounded;
                        break;
                      default:
                        bg = const Color(0xFFE8F5E9);
                        border = AppTheme.success;
                        text = AppTheme.success;
                        icon = Icons.check_circle_outline_rounded;
                    }

                    return Material(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _mostrarDetalle(celda),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border, width: 1.4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: text, size: 22),
                              const SizedBox(height: 6),
                              Text(
                                celda.codigoCelda,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: estado == 'ocupado'
                                      ? Colors.grey[700]
                                      : AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leyenda(String label, Color color, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
