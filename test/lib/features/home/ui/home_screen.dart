import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Menú rápido próximamente")),
            );
          },
        ),
        title: const Text('Bienvenido, Operador'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Configuraciones de perfil próximamente"),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/pacientes');
                },
                icon: const Icon(Icons.people),
                label: const Text('Revisar pacientes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/prueba');
                },
                icon: const Icon(Icons.people),
                label: const Text('grabación mínima'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
