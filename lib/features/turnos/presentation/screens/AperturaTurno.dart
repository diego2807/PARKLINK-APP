import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import 'Dashboard.dart';

class AperturaTurnoScreen extends StatefulWidget {
  const AperturaTurnoScreen({super.key});

  @override
  State<AperturaTurnoScreen> createState() => _AperturaTurnoScreenState();
}

class _AperturaTurnoScreenState extends State<AperturaTurnoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasController = TextEditingController();

  String _puesto = "Puerta Principal";
  String _jornada = "Mañana (06:00 - 14:00)";
  bool _cargando = false;

  final List<String> _puestos = ["Puerta Principal", "Sótano 1", "Sótano 2", "Torre A", "Torre B"];
  final List<String> _jornadas = ["Mañana (06:00 - 14:00)", "Tarde (14:00 - 22:00)", "Noche (22:00 - 06:00)"];

  void _iniciarTurno() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _cargando = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Turno iniciado correctamente"), backgroundColor: AppTheme.success),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VigilanteDashboardScreen()));
  }

  @override
  void dispose() {
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
        title: const Text("Apertura de Turno", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Verifica los datos antes de iniciar tu turno. Esta acción quedará registrada con fecha y hora.",
                            style: TextStyle(fontSize: 12.5, color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        const Text("Datos del Turno", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _puesto,
                          decoration: AppTheme.inputStyle("Puesto asignado", Icons.location_on_outlined),
                          items: _puestos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (val) => setState(() => _puesto = val!),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _jornada,
                          decoration: AppTheme.inputStyle("Jornada", Icons.schedule_rounded),
                          items: _jornadas.map((j) => DropdownMenuItem(value: j, child: Text(j, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) => setState(() => _jornada = val!),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _notasController,
                          maxLines: 3,
                          decoration: AppTheme.inputStyle("Observaciones iniciales (opcional)", Icons.notes_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _iniciarTurno,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _cargando
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text("Iniciar Turno", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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