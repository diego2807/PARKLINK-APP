import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class UserReserveSpotScreen extends StatefulWidget {
  const UserReserveSpotScreen({super.key});

  @override
  State<UserReserveSpotScreen> createState() => _UserReserveSpotScreenState();
}

class _UserReserveSpotScreenState extends State<UserReserveSpotScreen> {
  String _tipoVehiculo = "carro"; // "carro" o "moto"
  String _zonaSeleccionada = "Torre A - Piso 1";
  String? _celdaSeleccionada;

  final List<String> _zonas = [
    "Torre A - Piso 1",
    "Torre A - Piso 2",
    "Sótano 1 - General",
    "Sótano 2 - VIP",
  ];

  // Mapa de celdas mutable para reflejar cambios en tiempo real
  final Map<String, List<Map<String, dynamic>>> _mapaCeldas = {
    "Torre A - Piso 1": [
      {"id": "A-01", "estado": "disponible"},
      {"id": "A-02", "estado": "ocupado"},
      {"id": "A-03", "estado": "disponible"},
      {"id": "A-04", "estado": "disponible"},
      {"id": "A-05", "estado": "ocupado"},
      {"id": "A-06", "estado": "disponible"},
      {"id": "A-07", "estado": "ocupado"},
      {"id": "A-08", "estado": "disponible"},
      {"id": "A-09", "estado": "disponible"},
    ],
    "Torre A - Piso 2": [
      {"id": "B-01", "estado": "ocupado"},
      {"id": "B-02", "estado": "ocupado"},
      {"id": "B-03", "estado": "disponible"},
      {"id": "B-04", "estado": "disponible"},
      {"id": "B-05", "estado": "disponible"},
      {"id": "B-06", "estado": "ocupado"},
    ],
    "Sótano 1 - General": [
      {"id": "S1-01", "estado": "disponible"},
      {"id": "S1-02", "estado": "disponible"},
      {"id": "S1-03", "estado": "ocupado"},
      {"id": "S1-04", "estado": "disponible"},
    ],
    "Sótano 2 - VIP": [
      {"id": "VIP-01", "estado": "disponible"},
      {"id": "VIP-02", "estado": "ocupado"},
    ],
  };

  void _confirmarReserva() {
    if (_celdaSeleccionada == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 28),
            SizedBox(width: 10),
            Text("Reserva Confirmada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Detalles de tu asignación:", style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Celda:", style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_celdaSeleccionada!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Ubicación:", style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_zonaSeleccionada, style: const TextStyle(color: AppTheme.textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Vehículo:", style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_tipoVehiculo == "carro" ? "Carro (ABC-123)" : "Moto (XYZ-89)", style: const TextStyle(color: AppTheme.textDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Actualizamos el estado de la celda a ocupado en el mapa local
              setState(() {
                final celdas = _mapaCeldas[_zonaSeleccionada];
                if (celdas != null) {
                  for (var celda in celdas) {
                    if (celda["id"] == _celdaSeleccionada) {
                      celda["estado"] = "ocupado";
                      break;
                    }
                  }
                }
                _celdaSeleccionada = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Aceptar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color borderColor) {
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
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> celdasActuales = _mapaCeldas[_zonaSeleccionada] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text("Reservar Celda", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de Tipo de Vehículo
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _tipoVehiculo = "carro";
                            _celdaSeleccionada = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoVehiculo == "carro" ? AppTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car_rounded, size: 20, color: _tipoVehiculo == "carro" ? Colors.white : AppTheme.textMuted),
                                const SizedBox(width: 8),
                                Text(
                                  "Carro",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _tipoVehiculo == "carro" ? Colors.white : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _tipoVehiculo = "moto";
                            _celdaSeleccionada = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoVehiculo == "moto" ? AppTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.two_wheeler_rounded, size: 20, color: _tipoVehiculo == "moto" ? Colors.white : AppTheme.textMuted),
                                const SizedBox(width: 8),
                                Text(
                                  "Moto",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _tipoVehiculo == "moto" ? Colors.white : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Selector de Zona / Piso + Leyenda
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.layers_rounded, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Text("Zona / Ubicación:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _zonaSeleccionada,
                                  isExpanded: true,
                                  items: _zonas.map((z) => DropdownMenuItem(value: z, child: Text(z, style: const TextStyle(fontSize: 13)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _zonaSeleccionada = val;
                                        _celdaSeleccionada = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem("Disponible", const Color(0xFFE8F5E9), AppTheme.success),
                          _buildLegendItem("Ocupado", Colors.grey[200]!, Colors.grey[400]!),
                          _buildLegendItem("Seleccionado", AppTheme.primary.withOpacity(0.15), AppTheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Título de Celdas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Selecciona tu Celda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    Text("${celdasActuales.where((c) => c["estado"] == "disponible").length} disponibles", style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),

                // Grilla de Celdas
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: celdasActuales.length,
                  itemBuilder: (context, index) {
                    final celda = celdasActuales[index];
                    bool ocupado = celda["estado"] == "ocupado";
                    bool seleccionado = _celdaSeleccionada == celda["id"];

                    Color bgColor;
                    Color borderColor;
                    Color textColor;

                    if (ocupado) {
                      bgColor = Colors.grey[100]!;
                      borderColor = Colors.grey[300]!;
                      textColor = Colors.grey[500]!;
                    } else if (seleccionado) {
                      bgColor = AppTheme.primary.withOpacity(0.12);
                      borderColor = AppTheme.primary;
                      textColor = AppTheme.primary;
                    } else {
                      bgColor = const Color(0xFFE8F5E9);
                      borderColor = AppTheme.success.withOpacity(0.6);
                      textColor = AppTheme.success;
                    }

                    return Material(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: ocupado
                            ? null
                            : () {
                                setState(() {
                                  _celdaSeleccionada = celda["id"];
                                });
                              },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: seleccionado ? 2.5 : 1.5),
                            boxShadow: seleccionado ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)] : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ocupado ? Icons.block_rounded : (seleccionado ? Icons.check_circle_rounded : Icons.local_parking_rounded),
                                color: textColor,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                celda["id"],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ocupado ? Colors.grey[600] : AppTheme.textDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ocupado ? "Ocupada" : (seleccionado ? "Seleccionada" : "Disponible"),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Resumen de Selección
                if (_celdaSeleccionada != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Celda seleccionada: $_celdaSeleccionada", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                              Text("Ubicación: $_zonaSeleccionada", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón de Confirmación
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _celdaSeleccionada != null ? _confirmarReserva : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _celdaSeleccionada != null ? AppTheme.primary : Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: _celdaSeleccionada != null ? 3 : 0,
                    ),
                    child: Text(
                      _celdaSeleccionada != null ? "Confirmar Reserva" : "Selecciona una celda libre",
                      style: TextStyle(
                        color: _celdaSeleccionada != null ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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