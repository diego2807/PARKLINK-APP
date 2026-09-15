import 'package:flutter/material.dart';
import '../../../../app_theme.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  // Lista de registros de historial simulados
  final List<Map<String, String>> historial = [
    {
      "placa": "ABC-123",
      "tipo": "Entrada",
      "fecha": "15 Sep 2026",
      "hora": "08:30 AM",
      "ubicacion": "Parqueadero Principal - Espacio 12"
    },
    {
      "placa": "XYZ-987",
      "tipo": "Salida",
      "fecha": "14 Sep 2026",
      "hora": "05:45 PM",
      "ubicacion": "Parqueadero Norte - Espacio 04"
    },
    {
      "placa": "ABC-123",
      "tipo": "Salida",
      "fecha": "14 Sep 2026",
      "hora": "06:15 PM",
      "ubicacion": "Parqueadero Principal - Espacio 12"
    },
    {
      "placa": "JKL-456",
      "tipo": "Entrada",
      "fecha": "14 Sep 2026",
      "hora": "09:00 AM",
      "ubicacion": "Parqueadero Visitantes - Espacio 02"
    },
  ];

  String _filtroSeleccionado = "Todos";

  @override
  Widget build(BuildContext context) {
    // Filtrar la lista según el botón seleccionado
    final historialFiltrado = historial.where((item) {
      if (_filtroSeleccionado == "Todos") return true;
      return item["tipo"] == _filtroSeleccionado;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          "Historial de Accesos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado y Filtros
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Registro de Movimientos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Consulta las entradas y salidas registradas",
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Botones de filtro
                    Row(
                      children: [
                        _buildFiltroBoton("Todos"),
                        const SizedBox(width: 8),
                        _buildFiltroBoton("Entrada"),
                        const SizedBox(width: 8),
                        _buildFiltroBoton("Salida"),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de Historial
              Expanded(
                child: historialFiltrado.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text(
                              "No hay registros para este filtro",
                              style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: historialFiltrado.length,
                        itemBuilder: (context, index) {
                          final item = historialFiltrado[index];
                          bool esEntrada = item["tipo"] == "Entrada";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icono indicativo de Entrada o Salida
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: esEntrada
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    esEntrada
                                        ? Icons.login_rounded
                                        : Icons.logout_rounded,
                                    color: esEntrada ? Colors.green : Colors.orange[800],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Detalles del movimiento
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item["placa"]!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          Text(
                                            "${item['fecha']} • ${item['hora']}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item["ubicacion"]!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  // Widget auxiliar para los botones de filtro superiores
  Widget _buildFiltroBoton(String titulo) {
    bool seleccionado = _filtroSeleccionado == titulo;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _filtroSeleccionado = titulo;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: seleccionado ? AppTheme.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: seleccionado ? AppTheme.primary : Colors.grey[300]!,
            ),
          ),
          child: Text(
            titulo,
            style: TextStyle(
              color: seleccionado ? Colors.white : AppTheme.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}