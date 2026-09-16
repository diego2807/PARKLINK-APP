import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Importamos el gestor de estados

// ============================================================
// PROVIDERS (TUS NUEVOS ARCHIVOS)
// ============================================================
import 'features/accesos/presentation/providers/acceso_provider.dart';
import 'features/accesos/presentation/providers/visitante_provider.dart';
import 'features/auditoria/presentation/providers/auditoria_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/celdas_mapa/presentation/providers/celda_provider.dart';
import 'features/configuracion/presentation/providers/configuracion_provider.dart';
import 'features/kpis_alertas/presentation/providers/kpi_alerta_provider.dart';
import 'features/reservas/presentation/providers/reserva_provider.dart';
import 'features/tendencias/presentation/providers/tendencia_provider.dart';

// ============================================================
// MÓDULO DE AUTENTICACIÓN / USUARIO
// ============================================================

import 'features/auth/presentation/screens/Login.dart';
import 'features/auth/presentation/screens/Perfil.dart';
import 'features/auth/presentation/screens/Ayuda.dart';

import 'features/kpis_alertas/presentation/screens/Notificaciones.dart';

import 'features/celdas_mapa/presentation/screens/Semaforo.dart';
import 'features/celdas_mapa/presentation/screens/Dashboard.dart'
    as user_dashboard;

import 'features/reservas/presentation/screens/Reservas.dart';
import 'features/vehiculos/presentation/screens/VehiculosU.dart';
import 'features/accesos/presentation/screens/Historial.dart';

// ============================================================
// MÓDULO DE ACCESOS / VIGILANTE
// ============================================================

import 'features/accesos/presentation/screens/Control.dart';
import 'features/accesos/presentation/screens/FormularioEntrada.dart';
import 'features/accesos/presentation/screens/FormularioSalida.dart';
import 'features/accesos/presentation/screens/FormularioVisitantes.dart';
import 'features/accesos/presentation/screens/ListaVehiculosActivo.dart';

// ============================================================
// MÓDULO DE TURNOS / VIGILANTE
// ============================================================

import 'features/turnos/presentation/screens/Inicio.dart';
import 'features/turnos/presentation/screens/AperturaTurno.dart';
import 'features/turnos/presentation/screens/CierreTurno.dart';
import 'features/turnos/presentation/screens/ConsolaTransferencia.dart';
import 'features/turnos/presentation/screens/HistorialTurno.dart';
import 'features/turnos/presentation/screens/RegistroNovedades.dart';
import 'features/turnos/presentation/screens/Incidentes.dart';

// ============================================================
// MAPA GRÁFICO
// ============================================================

import 'features/celdas_mapa/presentation/screens/MapaGrafico.dart';

// ============================================================
// DASHBOARD ADMINISTRADOR
// ============================================================

import 'features/kpis_alertas/presentation/screens/Dashboard.dart'
    as admin_dashboard;

// ============================================================
// FUNCIÓN PRINCIPAL
// ============================================================

void main() {
  runApp(const MyApp());
}

// ============================================================
// APLICACIÓN PRINCIPAL
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Aquí envolvemos toda tu app con el MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccesoProvider()),
        ChangeNotifierProvider(create: (_) => VisitanteProvider()),
        ChangeNotifierProvider(create: (_) => AuditoriaProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CeldaProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => KpiAlertaProvider()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
        ChangeNotifierProvider(create: (_) => TendenciaProvider()),
      ],
      child: MaterialApp(
        title: 'Parklink',

        // Quitar la cinta de DEBUG
        debugShowCheckedModeBanner: false,

        // Pantalla inicial
        initialRoute: '/login',

        // ========================================================
        // RUTAS DE LA APLICACIÓN
        // ========================================================

        routes: {
          // ------------------------------------------------------
          // LOGIN
          // ------------------------------------------------------

          '/login': (context) => const LoginScreen(),

          // ======================================================
          // MÓDULO DE USUARIO
          // ======================================================

          '/user/dashboard': (context) =>
              const user_dashboard.UserDashboardScreen(),

          '/user/profile': (context) => const PerfilScreen(),

          '/user/notifications': (context) => const UserNotificationsScreen(),

          '/user/help': (context) => const AyudaScreen(),

          '/user/traffic-light': (context) => const UserTrafficLightScreen(),

          '/user/reservations': (context) => const UserReserveSpotScreen(),

          '/user/vehicles': (context) => const UserVehiclesScreen(),

          '/user/history': (context) => const HistorialScreen(),

          // ======================================================
          // MÓDULO DE VIGILANTE
          // ======================================================

          '/vigilante/dashboard': (context) =>
              const admin_dashboard.AdminDashboardScreen(),

          '/vigilante/inicio': (context) => const InicioScreen(),

          '/vigilante/control': (context) => const ControlScreen(),

          '/vigilante/apertura-turno': (context) => const AperturaTurnoScreen(),

          '/vigilante/cierre-turno': (context) => const CierreTurnoScreen(),

          '/vigilante/consola-transferencia': (context) =>
              const ConsolaTransferenciaScreen(),

          '/vigilante/formulario-entrada': (context) =>
              const FormularioEntradaScreen(),

          '/vigilante/formulario-salida': (context) =>
              const FormularioSalidaScreen(),

          '/vigilante/formulario-visitantes': (context) =>
              const FormularioVisitantesScreen(),

          '/vigilante/historial-turno': (context) =>
              const HistorialTurnoScreen(),

          '/vigilante/lista-vehiculos': (context) =>
              const ListaVehiculosActivoScreen(),

          '/vigilante/mapa-grafico': (context) => const MapaGraficoScreen(),

          '/vigilante/registro-novedades': (context) =>
              const RegistroNovedadesScreen(),

          '/vigilante/incidencias': (context) =>
              const VigilanteIncidentsScreen(),

          // ======================================================
          // MÓDULO DE ADMINISTRADOR
          // ======================================================

          '/admin': (context) => const admin_dashboard.AdminDashboardScreen(),

          '/admin/dashboard': (context) =>
              const admin_dashboard.AdminDashboardScreen(),
        },
      ),
    );
  }
}