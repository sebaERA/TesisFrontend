import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void login() {
    setState(() => isLoading = true);

    // Simulación login
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
      // Aquí iría el llamado real al backend
      final email = emailController.text;
      final password = passwordController.text;

      if (email == "operador@eleam.com" && password == "1234") {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: login,
                  child: const Text('Ingresar'),
                ),
            const SizedBox(height: 10), // Espaciado entre los botones
            TextButton(
              onPressed: () {
                // Aquí puedes mostrar un dialog o navegar a otra pantalla
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Recuperar contraseña"),
                        content: const Text(
                          "Por favor contacta al administrador para restablecer tu contraseña.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Aceptar"),
                          ),
                        ],
                      ),
                );
              },
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
          ],
        ),
      ),
    );
  }
}
