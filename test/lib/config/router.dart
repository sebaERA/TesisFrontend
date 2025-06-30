import 'package:flutter/material.dart';

// Pantallas de Autenticación y Home
import 'package:test/features/auth/ui/login_screen.dart';
import 'package:test/features/home/ui/home_screen.dart';

// Pantallas de Pacientes
import 'package:test/features/pacientes/ui/pacientes_screen.dart';
import 'package:test/features/pacientes/ui/detalle_paciente_screen.dart';
import 'package:test/features/pacientes/ui/consentimiento_screen.dart';

// Pantalla de Grabación
import 'package:test/features/evaluacion/ui/grabacion_screen.dart';

// Pantalla de Historial
import 'package:test/features/historial/ui/historial_detallado_screen.dart';

// Modelo de Paciente
import 'package:test/features/pacientes/models/paciente.dart';

/// Todas las rutas de la aplicación centralizadas
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/pacientes': (context) => PacientesScreen(),

  // Rutas que esperan recibir un objeto `Paciente` en `arguments`
  '/pacientes/detalle': (context) {
    final paciente = ModalRoute.of(context)!.settings.arguments as Paciente;
    return DetallePacienteScreen(paciente: paciente);
  },

  '/pacientes/consentimiento': (context) {
    final paciente = ModalRoute.of(context)!.settings.arguments as Paciente;
    return ConsentimientoScreen(paciente: paciente);
  },

  '/pacientes/grabacion': (context) {
    final paciente = ModalRoute.of(context)!.settings.arguments as Paciente;
    return GrabacionRealScreen(paciente: paciente);
  },

  '/pacientes/historial': (context) {
    final paciente = ModalRoute.of(context)!.settings.arguments as Paciente;
    return HistorialDetalladoScreen(paciente: paciente);
  },
};
