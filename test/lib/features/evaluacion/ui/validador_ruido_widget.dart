import 'dart:async';
import 'dart:collection';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NoiseWatcher {
  final double noisyThresholdDb;     // p.ej. 52.0
  final double quietThresholdDb;     // p.ej. 47.0 (histéresis)
  final Duration noisyMinDuration;   // p.ej. 2s
  final Duration quietMinDuration;   // p.ej. 1s
  final Duration window;             // p.ej. 1500ms

  final _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _sub;
  final _buffer = Queue<_Sample>();
  DateTime? _noisySince;
  DateTime? _quietSince;

  ValueNotifier<bool> isNoisy = ValueNotifier<bool>(false);
  ValueNotifier<double?> meanDb = ValueNotifier<double?>(null);
  ValueNotifier<double?> maxDb = ValueNotifier<double?>(null);

  NoiseWatcher({
    this.noisyThresholdDb = 52.0,
    this.quietThresholdDb = 47.0,
    this.noisyMinDuration = const Duration(seconds: 2),
    this.quietMinDuration = const Duration(seconds: 1),
    this.window = const Duration(milliseconds: 1500),
  });

  Future<bool> _ensureMic() async {
    final s = await Permission.microphone.request();
    return s.isGranted;
  }

  Future<void> start() async {
    if (!await _ensureMic()) {
      throw Exception('Permiso de micrófono denegado');
    }
    await stop(); // por si había una previa
    _sub = _noiseMeter.noise.listen(_onData, onError: _onError, cancelOnError: true);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _buffer.clear();
    _noisySince = null;
    _quietSince = null;
  }

  void _onData(NoiseReading r) {
    final now = DateTime.now();
    _buffer.addLast(_Sample(now, r.meanDecibel, r.maxDecibel));

    // recorta ventana
    final cutoff = now.subtract(window);
    while (_buffer.isNotEmpty && _buffer.first.t.isBefore(cutoff)) {
      _buffer.removeFirst();
    }

    // promedio en ventana
    final m = _buffer.map((s) => s.mean).fold<double>(0.0, (a, b) => a + b) /
        (_buffer.isEmpty ? 1 : _buffer.length);
    final mx = _buffer.isEmpty ? r.maxDecibel : _buffer.map((s) => s.max).reduce((a, b) => a > b ? a : b);

    meanDb.value = m;
    maxDb.value = mx;

    // lógica de umbrales con histéresis
    final noisyNow = m >= noisyThresholdDb;
    final quietNow = m <= quietThresholdDb;

    if (noisyNow) {
      _noisySince ??= now;
      _quietSince = null;
      if (!isNoisy.value && now.difference(_noisySince!).compareTo(noisyMinDuration) >= 0) {
        isNoisy.value = true;
      }
    } else if (quietNow) {
      _quietSince ??= now;
      _noisySince = null;
      if (isNoisy.value && now.difference(_quietSince!).compareTo(quietMinDuration) >= 0) {
        isNoisy.value = false;
      }
    } else {
      // zona gris entre quietThresholdDb y noisyThresholdDb: no cambies estado hasta cumplir duraciones
      _noisySince = null;
      _quietSince = null;
    }
  }

  void _onError(Object e) {
    // Podrías reconectar o propagar el error
  }
}

class _Sample {
  final DateTime t;
  final double mean;
  final double max;
  _Sample(this.t, this.mean, this.max);
}
