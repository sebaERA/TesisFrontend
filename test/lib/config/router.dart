import 'package:flutter/material.dart';
import 'package:test/features/pacientes/ui/pacientes_screen.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/home/ui/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/pacientes': (context) => const PacientesScreen(), // reemplaza luego
};
