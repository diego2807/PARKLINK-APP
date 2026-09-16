import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Importante para usar el Provider
import '../providers/configuracion_provider.dart'; // 💡 Tu nuevo provider de configuración

class AdminConfigScreen extends StatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  State createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State {
  // Reglas de negocio locales para reflejar el estado en la UI
  int _toleranciaReserva = 15; // minutos
  int _maxHorasEstadia = 10; // horas
  bool _permitirReservasFuturas = true;

  // Notificaciones
  bool _notificarVencimiento = true;
  bool _notificarOcupacionNoAutorizada = true;
  bool _enviarResumenDiario = false;

  // Soporte
  final TextEditingController _soporteController = TextEditingController(
    text: 'soporte.parqueadero@redeban.com',
  );

  @override
  void initState() {
    super.initState();
    // 💡 Cargamos la configuración global a través del provider al iniciar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarConfiguracionProvider();
    });
  }

  Future _cargarConfiguracionProvider() async {
    final provider = context.read();
    await provider.cargarConfiguracion();

    if (provider.error.isEmpty && provider.configData.isNotEmpty) {
      setState(() {
        _maxHorasEstadia = provider.configData['tiempo_maximo'] ?? 10;
        _permitirReservasFuturas = provider.configData['permitir_festivos'] ?? true;
      });
    }
  }

  @override
  void dispose() {
    _soporteController.dispose();
    super.dispose();
  }

  Future _guardarConfiguracion() async {
    final provider = context.read();

    // Preparamos el payload que Flask espera según la ruta de configuración
    final nuevosDatos = {
      'permitir_festivos': _permitirReservasFuturas,
      'tiempo_maximo': _maxHorasEstadia,
    };

    final exito = await provider.actualizarConfiguracion(nuevosDatos);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Parámetros actualizados correctamente',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar la configuración: ${provider.error}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    // 💡 Escuchamos el estado del provider global
    final provider = context.watch();

    if (provider.cargando && provider.configData.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO ADAPTABLE
              if (isDesktop)
                Row(
                  children: [
                    Expanded(child: _buildHeaderContent(provider.cargando)[0]),
                    const SizedBox(width: 16),
                    _buildHeaderContent(provider.cargando)[2],
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [..._buildHeaderContent(provider.cargando)],
                ),
              const SizedBox(height: 20),

              // BANNER DE BENEFICIO EMPLEADOS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Beneficio Corporativo - Parqueadero Gratuito',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'El uso del parqueadero es exclusivo y sin costo para colaboradores autorizados. Las políticas aseguran disponibilidad equitativa.',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDBEAFE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECCIONES DE CONFIGURACIÓN RESPONSIVAS
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTimeAndRulesCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildNotificationsAndSupportColumn()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildTimeAndRulesCard(),
                    const SizedBox(height: 20),
                    _buildNotificationsAndSupportColumn(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List _buildHeaderContent(bool isSaving) {
    return [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parámetros de Operación Parklink',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Gestiona las políticas de uso, tiempos de tolerancia y canal de soporte del parqueadero.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isSaving ? null : _guardarConfiguracion,
        icon: isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(
          isSaving ? 'Guardando...' : 'Guardar Cambios',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  Widget _buildTimeAndRulesCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFF2563EB), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reglas de Tiempo y Reservas',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28, color: Color(0xFFF1F5F9)),

            // Tolerancia de reserva
            const Text(
              'Tiempo de Tolerancia en Reserva',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Minutos permitidos antes de liberar la celda si el usuario no ingresa.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: _toleranciaReserva,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              items: [5, 10, 15, 20, 30].map((int val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    '$val minutos',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _toleranciaReserva = val);
              },
            ),
            const SizedBox(height: 18),

            // Tiempo Máximo
            const Text(
              'Límite Máximo de Estancia Continua',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Horas máximas que un vehículo puede estar parqueado por jornada.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: _maxHorasEstadia,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              items: [8, 10, 12, 24].map((int val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    '$val horas',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _maxHorasEstadia = val);
              },
            ),
            const SizedBox(height: 18),

            // Switch Reserva Futura
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Permitir Reservas Anticipadas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              subtitle: const Text(
                'Permite a los empleados agendar celdas para el día siguiente.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              value: _permitirReservasFuturas,
              activeThumbColor: const Color(0xFF2563EB),
              onChanged: (val) =>
                  setState(() => _permitirReservasFuturas = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsAndSupportColumn() {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notificaciones del Sistema',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Aviso de Tolerancia por Vencer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  subtitle: const Text(
                    'Enviar notificación al usuario cuando queden 5 min de tolerancia.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  value: _notificarVencimiento,
                  activeThumbColor: const Color(0xFF2563EB),
                  onChanged: (val) =>
                      setState(() => _notificarVencimiento = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Alerta de Ocupación No Autorizada',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  subtitle: const Text(
                    'Notificar a seguridad si una celda ocupada no tiene reserva activa.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  value: _notificarOcupacionNoAutorizada,
                  activeThumbColor: const Color(0xFF2563EB),
                  onChanged: (val) =>
                      setState(() => _notificarOcupacionNoAutorizada = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Resumen Diario por Correo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  subtitle: const Text(
                    'Enviar reporte automático al final de la jornada con la ocupación global.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  value: _enviarResumenDiario,
                  activeThumbColor: const Color(0xFF2563EB),
                  onChanged: (val) =>
                      setState(() => _enviarResumenDiario = val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.contact_support_outlined,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Canal de Soporte',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Correo de Atención Administrativa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _soporteController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}