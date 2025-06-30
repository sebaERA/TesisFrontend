import 'package:flutter/material.dart';
import 'config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App ELEAM',
      // Ruta inicial (por ejemplo, login)
      initialRoute: '/login',
      // Importamos nuestro mapa de rutas
      routes: appRoutes,
      // Opcional: manejo de ruta desconocida
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Página no encontrada')),
              ),
        );
      },
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
