import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../data/services/novedad_service.dart';

class ConsolaTransferenciaScreen extends StatefulWidget {
  const ConsolaTransferenciaScreen({super.key});

  @override
  State<ConsolaTransferenciaScreen> createState() =>
      _ConsolaTransferenciaScreenState();
}

class _ConsolaTransferenciaScreenState
    extends State<ConsolaTransferenciaScreen> {
  final _nombreEntranteController = TextEditingController();
  final _notasController = TextEditingController();
  final NovedadService _novedadService = NovedadService();
  bool _cargando = false;

  final Map<String, bool> _checklist = {
    'Llaves y controles de acceso': false,
    'Radio / equipo de comunicación': false,
    'Novedades pendientes informadas': false,
    'Listado de vehículos activos': false,
    'Elementos de dotación': false,
  };

  bool get _checklistCompleto => _checklist.values.every((v) => v);

  Future<void> _confirmarTransferencia() async {
    if (_nombreEntranteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre del vigilante entrante'),
        ),
      );
      return;
    }
    if (!_checklistCompleto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el checklist de entrega antes de continuar'),
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final notas = _notasController.text.trim();
      final descripcion = notas.isEmpty
          ? 'Transferencia de turno: ${_nombreEntranteController.text.trim()}'
          : 'Transferencia de turno: ${_nombreEntranteController.text.trim()} - $notas';

      await _novedadService.registrarNovedad(descripcion);

      if (!mounted) return;
      setState(() => _cargando = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: AppTheme.primary, size: 28),
              SizedBox(width: 10),
              Text(
                'Transferencia Confirmada',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            'El turno fue transferido a ${_nombreEntranteController.text}.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreEntranteController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Consola de Transferencia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                        'Vigilante Entrante',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nombreEntranteController,
                        decoration: AppTheme.inputStyle(
                          'Nombre completo',
                          Icons.person_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                        'Checklist de Entrega',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._checklist.keys.map((item) {
                        return CheckboxListTile(
                          value: _checklist[item],
                          onChanged: (val) =>
                              setState(() => _checklist[item] = val ?? false),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppTheme.success,
                          title: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppTheme.textDark,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                        'Notas para el Entrante',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notasController,
                        maxLines: 3,
                        decoration: AppTheme.inputStyle(
                          'Detalles relevantes para el próximo turno...',
                          Icons.notes_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _cargando ? null : _confirmarTransferencia,
                    icon: _cargando
                        ? const SizedBox.shrink()
                        : const Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                          ),
                    label: _cargando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Confirmar Transferencia',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
