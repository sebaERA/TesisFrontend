import 'package:test/features/historial/models/resultado.dart';

import '../evaluacion/models/resultado.dart';

class HistorialController {
  static List<ResultadoEvaluacion> obtenerHistorialPorPaciente(
    String pacienteId,
  ) {
    return [
      ResultadoEvaluacion(
        id: 'r1',
        fecha: '2024-05-01',
        resultado: 'Depresión leve',
        estado: 'aprobado',
      ),
      ResultadoEvaluacion(
        id: 'r2',
        fecha: '2024-04-15',
        resultado: 'Sin indicios',
        estado: 'pendiente',
      ),
    ];
  }

  static void actualizarEstado(
    ResultadoEvaluacion resultado,
    String nuevoEstado,
  ) {
    resultado.estado = nuevoEstado;
    // Aquí luego agregarías una petición PUT al backend
  }
}
