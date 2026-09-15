import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class MapaGraficoScreen extends StatefulWidget {
  const MapaGraficoScreen({super.key});

  @override
  State<MapaGraficoScreen> createState() => _MapaGraficoScreenState();
}

class _MapaGraficoScreenState extends State<MapaGraficoScreen> {
  String _zonaSeleccionada = "Torre A - Piso 1";

  final List<String> _zonas = ["Torre A - Piso 1", "Torre A - Piso 2", "Sótano 1 - General", "Sótano 2 - VIP"];

  final Map<String, List<Map<String, dynamic>>> _mapaCeldas = {
    "Torre A - Piso 1": [
      {"id": "A-01", "estado": "ocupado", "placa": "ABC-123"},
      {"id": "A-02", "estado": "disponible"},
      {"id": "A-03", "estado": "disponible"},
      {"id": "A-04", "estado": "reservado"},
      {"id": "A-05", "estado": "ocupado", "placa": "DEF-456"},
      {"id": "A-06", "estado": "disponible"},
      {"id": "A-07", "estado": "ocupado", "placa": "GHI-789"},
      {"id": "A-08", "estado": "disponible"},
      {"id": "A-09", "estado": "disponible"},
    ],
    "Torre A - Piso 2": [
      {"id": "B-01", "estado": "ocupado", "placa": "JKL-456"},
      {"id": "B-02", "estado": "ocupado", "placa": "MNO-111"},
      {"id": "B-03", "estado": "disponible"},
      {"id": "B-04", "estado": "disponible"},
      {"id": "B-05", "estado": "disponible"},
      {"id": "B-06", "estado": "ocupado", "placa": "PQR-222"},
    ],
    "Sótano 1 - General": [
      {"id": "S1-01", "estado": "disponible"},
      {"id": "S1-02", "estado": "ocupado", "placa": "XYZ-89"},
      {"id": "S1-03", "estado": "ocupado", "placa": "STU-333"},
      {"id": "S1-04", "estado": "disponible"},
    ],
    "Sótano 2 - VIP": [
      {"id": "VIP-01", "estado": "disponible"},
      {"id": "VIP-02", "estado": "ocupado", "placa": "MNP-321"},
    ],
  };

  void _mostrarDetalle(Map<String, dynamic> celda) {
    final estado = celda["estado"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.local_parking_rounded, color: estado == "ocupado" ? AppTheme.accent : AppTheme.success),
            const SizedBox(width: 10),
            Text("Celda ${celda["id"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(
          estado == "ocupado"
              ? "Ocupada por el vehículo ${celda["placa"]}."
              : estado == "reservado"
                  ? "Celda reservada, pendiente de ingreso."
                  : "Celda disponible para asignación inmediata.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cerrar", style: TextStyle(color: Colors.grey)),
          ),
          if (estado == "disponible")
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  celda["estado"] = "reservado";
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Celda ${celda["id"]} reservada con éxito!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
              child: const Text("Reservar"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final celdas = _mapaCeldas[_zonaSeleccionada] ?? [];
    final disponibles = celdas.where((c) => c["estado"] == "disponible").length;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text("Mapa Gráfico", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          items: _zonas.map((z) => DropdownMenuItem(value: z, child: Text(z, style: const TextStyle(fontSize: 13.5)))).toList(),
                          onChanged: (val) => setState(() => _zonaSeleccionada = val!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _leyenda("Disponible", const Color(0xFFE8F5E9), AppTheme.success),
                          _leyenda("Ocupado", Colors.grey[200]!, Colors.grey[500]!),
                          _leyenda("Reservado", AppTheme.warning.withOpacity(0.15), AppTheme.warning),
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
                    const Text("Celdas de la zona", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                    Text("$disponibles disponibles", style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12.5)),
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
                    final estado = celda["estado"] as String;

                    Color bg;
                    Color border;
                    Color text;
                    IconData icon;

                    switch (estado) {
                      case "ocupado":
                        bg = Colors.grey[100]!;
                        border = Colors.grey[300]!;
                        text = Colors.grey[600]!;
                        icon = Icons.directions_car_rounded;
                        break;
                      case "reservado":
                        bg = AppTheme.warning.withOpacity(0.12);
                        border = AppTheme.warning;
                        text = AppTheme.warning;
                        icon = Icons.schedule_rounded;
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
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 1.4)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: text, size: 22),
                              const SizedBox(height: 6),
                              Text(celda["id"] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: estado == "ocupado" ? Colors.grey[700] : AppTheme.textDark)),
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
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: Border.all(color: borderColor)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}