import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Nuevo import necesario
import '../../../../app_theme.dart';
import '../providers/acceso_provider.dart'; // 💡 Importamos tu provider
import '../../domain/models/acceso_model.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  State createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State {
  // Solo conservamos la variable de UI
  String _filtroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    // 💡 Pedimos los datos al Provider una vez que la vista termine de dibujarse
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read().cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Escuchamos el estado global del provider en tiempo real
    final provider = context.watch();

    // 💡 Filtramos usando la lista del provider
    final historialFiltrado = provider.historial.where((item) {
      if (_filtroSeleccionado == 'Todos') return true;
      return item.coincideConFiltro(_filtroSeleccionado);
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFiltroBoton('Todos'),
                          const SizedBox(width: 8),
                          _buildFiltroBoton('Entrada'),
                          const SizedBox(width: 8),
                          _buildFiltroBoton('Salida'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // 💡 Usamos provider.cargando
                child: provider.cargando
                    ? const Center(child: CircularProgressIndicator())
                    // 💡 Usamos provider.error
                    : provider.error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            provider.error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                        ),
                      )
                    : historialFiltrado.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No hay registros para este filtro",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: historialFiltrado.length,
                        itemBuilder: (context, index) {
                          final item = historialFiltrado[index];
                          final bool esEntrada = item.esEntrada;

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
                                    color: esEntrada
                                        ? Colors.green
                                        : Colors.orange[800],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.placa,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              '\({item.fechaTexto} •\){item.horaTexto}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.celdaTexto == 'N/A'
                                            ? item.tipoMovimiento
                                            : '\({item.tipoMovimiento} •\){item.celdaTexto}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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

  Widget _buildFiltroBoton(String titulo) {
    final bool seleccionado = _filtroSeleccionado == titulo;
    return SizedBox(
      width: 104,
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