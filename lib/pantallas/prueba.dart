import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:medi_master/models/clase_pregunta.dart' as modelo; // Use prefix 'modelo'
import 'pregunta.dart' as pantalla; // Use prefix 'pantalla'
import 'package:medi_master/widgets_personalizados/alternativa.dart' as widget_alt;
import 'package:medi_master/models/user_profile.dart'; // Import user profile

class PantallaPrueba extends StatefulWidget {
  const PantallaPrueba({super.key});

  @override
  PantallaPruebaState createState() => PantallaPruebaState(); // Changed to public
}

class PantallaPruebaState extends State<PantallaPrueba> { // Changed to public
  final PageController _pageController = PageController();
  List<modelo.Pregunta> _preguntas = []; // Use prefixed class
  int _currentIndex = 0;
  Map<int, UserResponse?> _userResponses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  // Función para cargar el JSON
  Future<void> _cargarPreguntas() async {
    setState(() => _isLoading = true);
    
    try {
      // Load questions from JSON
      String jsonString = await rootBundle.loadString('assets/db.json');
      List<dynamic> jsonList = json.decode(jsonString);
      List<modelo.Pregunta> questions = jsonList.map((json) => modelo.Pregunta.fromJson(json)).toList();
      
      // Load user responses for these questions
      Map<int, UserResponse?> responses = {};
      
      // For each question, try to get the user's response
      for (var pregunta in questions) {
        final response = await UserProfileService.getResponseForQuestion(pregunta.idPregunta);
        responses[pregunta.idPregunta] = response;
      }
      
      setState(() {
        _preguntas = questions;
        _userResponses = responses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions or responses: $e');
      setState(() {
        _preguntas = [];
        _isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _preguntas.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando preguntas...'),
                ],
              ),
            )
          : _preguntas.isEmpty
              ? Center(
                  child: Text('No se pudieron cargar las preguntas'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _preguntas.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          // Convert model Alternativa list to widget Alternativa list
                          List<widget_alt.Alternativa> widgetAlternativas = _preguntas[index].opciones.map((alt) =>
                            widget_alt.Alternativa(
                              idAlternativa: alt.idAlternativa,
                              texto: alt.texto,
                              explicacion: alt.explicacion,
                              correcta: alt.correcta,
                            )
                          ).toList();
                          
                          return pantalla.Pregunta( // Use prefixed class
                            idPregunta: _preguntas[index].idPregunta,
                            enunciado: _preguntas[index].enunciado,
                            opciones: widgetAlternativas,
                          );
                        },
                      ),
                    ),
                    BarraNavegacion( // Use pantalla prefix for BarraNavegacion
                      onListPressed: () {
                        // Show question statistics
                        _mostrarEstadisticas(context);
                      },
                      onNext: _nextQuestion,
                      onPrevious: _previousQuestion,
                    ),
                  ],
                ),
    );
  }
  
  void _mostrarEstadisticas(BuildContext context) {
    // Calculate statistics
    int totalAnswered = _userResponses.values.where((r) => r != null).length;
    int correctAnswers = _userResponses.values
        .where((r) => r != null && r!.esCorrecta)
        .length;
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estadísticas de la Prueba', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Preguntas respondidas: $totalAnswered de ${_preguntas.length}'),
              SizedBox(height: 8),
              Text('Respuestas correctas: $correctAnswers'),
              SizedBox(height: 8),
              Text('Respuestas incorrectas: ${totalAnswered - correctAnswers}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BarraNavegacion extends StatelessWidget {
  final VoidCallback onListPressed;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const BarraNavegacion({
    super.key,
    required this.onListPressed,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onPrevious, // Aquí agregamos la función correcta
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: onListPressed,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: onNext, // Aquí agregamos la función correcta
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
