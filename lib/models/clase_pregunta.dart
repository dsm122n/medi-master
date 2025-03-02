import 'dart:convert';

// Clase Alternativa
class Alternativa {
  final String idAlternativa;
  final String texto;
  final String explicacion;
  final bool correcta;

  Alternativa({
    required this.idAlternativa,
    required this.texto,
    required this.explicacion,
    required this.correcta,
  });

  // Convertir JSON a objeto Alternativa
  factory Alternativa.fromJson(Map<String, dynamic> json) {
    return Alternativa(
      idAlternativa: json['idAlternativa'],
      texto: json['texto'],
      explicacion: json['explicacion'],
      correcta: json['correcta'],
    );
  }
}

// Clase Pregunta
class Pregunta {
  final int idPregunta;
  final String enunciado;
  final List<Alternativa> opciones;

  Pregunta({
    required this.idPregunta,
    required this.enunciado,
    required this.opciones,
  });

  // Convertir JSON a objeto Pregunta
  factory Pregunta.fromJson(Map<String, dynamic> json) {
    var opcionesJson = json['opciones'] as List;
    List<Alternativa> opciones =
        opcionesJson.map((alt) => Alternativa.fromJson(alt)).toList();

    return Pregunta(
      idPregunta: json['idPregunta'],
      enunciado: json['enunciado'],
      opciones: opciones,
    );
  }
}
