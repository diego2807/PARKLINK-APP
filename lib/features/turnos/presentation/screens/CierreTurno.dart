import 'package:flutter/material.dart';
import '../../../../app_theme.dart';
import '../../data/services/novedad_service.dart';
import '../../data/services/turno_service.dart';
import '../../domain/models/resumen_turno_model.dart';

class CierreTurnoScreen extends StatefulWidget {
  const CierreTurnoScreen({super.key});

  @override
  State<CierreTurnoScreen> createState() => _CierreTurnoScreenState();
}

class _CierreTurnoScreenState extends State<CierreTurnoScreen> {
  final _notasController = TextEditingController();
  final TurnoService _turnoService = TurnoService();
  final NovedadService _novedadService = NovedadService();
  bool _confirmaEntrega = false;
  bool _cargando = false;
  late Future<ResumenTurnoModel> _resumenFuture;

  @override
  void initState() {
    super.initState();
    _resumenFuture = _turnoService.obtenerResumenTurnoSeguro();
  }

  List<Map<String, dynamic>> _buildResumenCards(ResumenTurnoModel resumen) {
    return [
      {
        "label": "Entradas registradas",
        "valor": resumen.entradas.toString(),
        "icon": Icons.login_rounded,
        "color": AppTheme.success,
      },
      {
        "label": "Salidas registradas",
        "valor": resumen.salidas.toString(),
        "icon": Icons.logout_rounded,
        "color": AppTheme.primary,
      },
      {
        "label": "Vehículos aún dentro",
        "valor": resumen.vehiculosActivos.toString(),
        "icon": Icons.directions_car_rounded,
        "color": AppTheme.warning,
      },
      {
        "label": "Novedades reportadas",
        "valor": resumen.novedades.toString(),
        "icon": Icons.report_gmailerrorred_rounded,
        "color": AppTheme.accent,
      },
    ];
  }

  Future<void> _cerrarTurno() async {
    if (!_confirmaEntrega) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes confirmar la entrega de la garita"),
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final notas = _notasController.text.trim();
      if (notas.isNotEmpty) {
        await _novedadService.registrarNovedad(notas);
      }

      final resultado = await _turnoService.cerrarTurno();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: AppTheme.success,
        ),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Turno Cerrado",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            "Tu turno se cerró exitosamente. ¡Buen descanso!",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Aceptar",
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
          "Cierre de Turno",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          child: FutureBuilder<ResumenTurnoModel>(
            future: _resumenFuture,
            builder: (context, snapshot) {
              final resumen = snapshot.data ?? ResumenTurnoModel.vacio();
              final cards = _buildResumenCards(resumen);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resumen del Turno",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.7,
                      children: cards.map((r) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                r["icon"] as IconData,
                                color: r["color"] as Color,
                                size: 22,
                              ),
                              Text(
                                r["valor"] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                r["label"] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
                          const Text(
                            "Observaciones de Cierre",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notasController,
                            maxLines: 4,
                            decoration: AppTheme.inputStyle(
                              "Novedades finales, estado de la garita, etc.",
                              Icons.notes_rounded,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            value: _confirmaEntrega,
                            onChanged: (val) =>
                                setState(() => _confirmaEntrega = val ?? false),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppTheme.primary,
                            title: const Text(
                              "Confirmo que entrego la garita en orden y sin novedades pendientes por reportar",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _cerrarTurno,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _cargando
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Cerrar Turno",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
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
