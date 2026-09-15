import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class VigilanteIncidentsScreen extends StatefulWidget {
  const VigilanteIncidentsScreen({super.key});

  @override
  State<VigilanteIncidentsScreen> createState() => _VigilanteIncidentsScreenState();
}

class _VigilanteIncidentsScreenState extends State<VigilanteIncidentsScreen> {
  final _placaController = TextEditingController();
  final _detalleController = TextEditingController();
  bool _cargando = false;

  void _enviarReporte() async {
    if (_detalleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa la descripción de la novedad o falla")),
      );
      return;
    }

    setState(() => _cargando = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _cargando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Incidencia enviada al Administrador")),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _placaController.dispose();
    _detalleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text("Reportar Incidencia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detalle de la Novedad", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _placaController,
                    decoration: AppTheme.inputStyle("Placa involucrada (Opcional)", Icons.badge_outlined),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detalleController,
                    maxLines: 4,
                    decoration: AppTheme.inputStyle("Descripción de la novedad o falla...", Icons.notes),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _enviarReporte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _cargando
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text("Enviar Reporte", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}