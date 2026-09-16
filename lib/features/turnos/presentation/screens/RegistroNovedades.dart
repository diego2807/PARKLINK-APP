import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../data/services/novedad_service.dart';
import '../../domain/models/novedad_model.dart';

class RegistroNovedadesScreen extends StatefulWidget {
  const RegistroNovedadesScreen({super.key});

  @override
  State<RegistroNovedadesScreen> createState() =>
      _RegistroNovedadesScreenState();
}

class _RegistroNovedadesScreenState extends State<RegistroNovedadesScreen> {
  final NovedadService _novedadService = NovedadService();
  final _descripcionController = TextEditingController();
  String _categoria = 'Mantenimiento';
  final List<String> _categorias = [
    'Mantenimiento',
    'Seguridad',
    'Cliente',
    'Infraestructura',
    'Otro',
  ];
  late Future<List<NovedadModel>> _novedadesFuture;

  @override
  void initState() {
    super.initState();
    _novedadesFuture = _novedadService.obtenerNovedades();
  }

  String _categoriaDesdeDescripcion(String descripcion) {
    final index = descripcion.indexOf(':');
    if (index > 0) return descripcion.substring(0, index).trim();
    return 'Otro';
  }

  String _descripcionLimpia(String descripcion) {
    final index = descripcion.indexOf(':');
    if (index > 0) return descripcion.substring(index + 1).trim();
    return descripcion.trim();
  }

  IconData _icono(String cat) {
    switch (cat) {
      case 'Mantenimiento':
        return Icons.build_rounded;
      case 'Seguridad':
        return Icons.security_rounded;
      case 'Cliente':
        return Icons.person_outline_rounded;
      case 'Infraestructura':
        return Icons.apartment_rounded;
      default:
        return Icons.notes_rounded;
    }
  }

  Future<void> _agregarNovedad() async {
    if (_descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe la novedad antes de guardar')),
      );
      return;
    }

    try {
      final descripcion = '$_categoria: ${_descripcionController.text.trim()}';
      await _novedadService.registrarNovedad(descripcion);
      if (!mounted) return;
      setState(() {
        _novedadesFuture = _novedadService.obtenerNovedades();
        _descripcionController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Novedad registrada'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Registro de Novedades',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: FutureBuilder<List<NovedadModel>>(
            future: _novedadesFuture,
            builder: (context, snapshot) {
              final novedades = snapshot.data ?? <NovedadModel>[];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nueva Novedad',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _categoria,
                            decoration: AppTheme.inputStyle(
                              'Categoría',
                              Icons.category_outlined,
                            ),
                            items: _categorias
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _categoria = val!),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descripcionController,
                            maxLines: 3,
                            decoration: AppTheme.inputStyle(
                              'Describe la novedad...',
                              Icons.edit_note_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _agregarNovedad,
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Guardar Novedad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Novedades del Turno',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (novedades.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Aún no hay novedades registradas',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        ),
                      ),
                    ...novedades.map((n) {
                      final categoria = _categoriaDesdeDescripcion(
                        n.descripcion,
                      );
                      final descripcion = _descripcionLimpia(n.descripcion);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _icono(categoria),
                                color: AppTheme.warning,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        categoria,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      Text(
                                        n.horaAmPm,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    descripcion,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
