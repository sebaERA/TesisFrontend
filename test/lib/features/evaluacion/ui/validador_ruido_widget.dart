// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:noise_meter/noise_meter.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() => runApp(const NoiseMeterApp());

// class NoiseMeterApp extends StatefulWidget {
//   const NoiseMeterApp({super.key});
//   @override
//   State<NoiseMeterApp> createState() => _NoiseMeterAppState();
// }

// class _NoiseMeterAppState extends State<NoiseMeterApp> {
//   late NoiseMeter _noiseMeter;
//   StreamSubscription<NoiseReading>? _noiseSubscription;
//   NoiseReading? _latestReading;
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _noiseMeter = NoiseMeter(); // sin argumentos
//   }

//   @override
//   void dispose() {
//     _noiseSubscription?.cancel();
//     super.dispose();
//   }

//   Callback de datos
//   void _onData(NoiseReading reading) {
//     setState(() {
//       _latestReading = reading;
//       _isRecording = true;
//     });
//   }

//   Callback de error
//   void _onError(Object error) {
//     print('Error al medir ruido: $error');
//     _stop();
//   }

//   Future<bool> _ensureMicPermission() async {
//     if (await Permission.microphone.request().isGranted) return true;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Permiso de micrófono denegado')),
//     );
//     return false;
//   }

//   Future<void> _start() async {
//     if (!await _ensureMicPermission()) return;
//     try {
//       Arrancas la suscripción al stream de ruido, capturando errores aquí
//       _noiseSubscription = _noiseMeter.noise.listen(
//         _onData,
//         onError: _onError, // <— aquí va tu callback de error
//         cancelOnError: true, // opcional: cancela la suscripción al primer error
//       );
//       setState(() => _isRecording = true);
//     } catch (e) {
//       print('No se pudo iniciar la grabación: $e');
//     }
//   }

//   void _stop() {
//     _noiseSubscription?.cancel();
//     setState(() => _isRecording = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final decibels = _latestReading?.meanDecibel.toStringAsFixed(1) ?? '--';
//     final maxDb = _latestReading?.maxDecibel.toStringAsFixed(1) ?? '--';

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Noise Meter')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _isRecording ? 'Grabando…' : 'Detenido',
//                 style: const TextStyle(fontSize: 24),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Promedio: $decibels dB',
//                 style: const TextStyle(fontSize: 18),
//               ),
//               Text('Máximo: $maxDb dB', style: const TextStyle(fontSize: 18)),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _isRecording ? _stop : _start,
//           backgroundColor: _isRecording ? Colors.red : Colors.green,
//           child: Icon(_isRecording ? Icons.stop : Icons.mic),
//         ),
//       ),
//     );
//   }
// }
