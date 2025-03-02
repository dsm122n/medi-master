import 'package:flutter/material.dart';
import 'package:medi_master/widgets_personalizados/alternativa.dart';
import 'package:medi_master/widgets_personalizados/lista_preguntas.dart'; // Import the QuestionNavigator
import 'dart:developer'; // Import the developer package
import 'package:medi_master/models/user_profile.dart'; // Import the user profile model

class Pregunta extends StatefulWidget {
  final int idPregunta;
  final String enunciado;
  final List<Alternativa> opciones;

  const Pregunta({
    super.key,
    required this.idPregunta,
    required this.enunciado,
    required this.opciones,
  });

  @override
  State<Pregunta> createState() => _PreguntaState();
}

class _PreguntaState extends State<Pregunta> {
  final TextEditingController _textController = TextEditingController();
  final List<HighlightedText> _highlightedParts = [];
  int totalQuestions = 20;
  String? _selectedAlternativaId;
  bool _answerSubmitted = false;
  UserResponse? _userResponse;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.enunciado;
    _loadUserResponse();
  }

  Future<void> _loadUserResponse() async {
    final response = await UserProfileService.getResponseForQuestion(widget.idPregunta);
    if (response != null) {
      setState(() {
        _userResponse = response;
        _selectedAlternativaId = response.idAlternativaSeleccionada;
        _answerSubmitted = true;
      });
    }
  }

  Future<void> _saveResponse(String alternativaId, bool esCorrecta) async {
    if (_answerSubmitted) return; // Don't save if already answered

    final response = UserResponse(
      idPregunta: widget.idPregunta,
      idAlternativaSeleccionada: alternativaId,
      esCorrecta: esCorrecta,
      fechaRespuesta: DateTime.now(),
    );

    await UserProfileService.addResponse(response);
    setState(() {
      _userResponse = response;
      _answerSubmitted = true;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addHighlight(int start, int end) {
    setState(() {
      _highlightedParts.add(HighlightedText(start, end));
    });
  }

  TextSpan _buildTextSpan(String text) {
    if (_highlightedParts.isEmpty) {
      return TextSpan(text: text);
    }

    // Sort highlighted parts to process them in order
    _highlightedParts.sort((a, b) => a.start.compareTo(b.start));

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (var highlight in _highlightedParts) {
      // Add non-highlighted text before this highlight
      if (currentIndex < highlight.start) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, highlight.start),
        ));
      }

      // Add the highlighted text
      spans.add(TextSpan(
        text: text.substring(highlight.start, highlight.end),
        style: const TextStyle(backgroundColor: Colors.yellow),
      ));

      currentIndex = highlight.end;
    }

    // Add any remaining non-highlighted text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
      ));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${widget.idPregunta}'),
        
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText.rich(
                        _buildTextSpan(widget.enunciado),
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        contextMenuBuilder: (context, editableTextState) {
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: editableTextState.contextMenuAnchors,
                            buttonItems: [
                              // Copy option
                              ContextMenuButtonItem(
                                onPressed: () {
                                  editableTextState.copySelection(SelectionChangedCause.tap);
                                  editableTextState.hideToolbar();
                                },
                                label: 'Copiar',
                              ),
                              // Select all option
                              ContextMenuButtonItem(
                                onPressed: () {
                                  editableTextState.selectAll(SelectionChangedCause.tap);
                                  editableTextState.hideToolbar();
                                },
                                label: 'Seleccionar todo',
                              ),
                              // Highlight option
                              ContextMenuButtonItem(
                                onPressed: () {
                                  final TextSelection selection = editableTextState.textEditingValue.selection;
                                  if (selection.isValid && !selection.isCollapsed) {
                                    _addHighlight(selection.start, selection.end);
                                  }
                                  editableTextState.hideToolbar();
                                },
                                label: 'Destacar',
                              ),
                            ],
                          );
                        },
                        onSelectionChanged: (selection, cause) {
                          _textController.selection = selection;
                        },
                        showCursor: true,
                        cursorWidth: 2,
                      ),
                    ),
                    const Divider(),
                    Column(
                      children: widget.opciones.map((alternativa) {
                        final bool isSelected = _selectedAlternativaId == alternativa.idAlternativa;
                        final bool showResult = _answerSubmitted;
                        
                        return GestureDetector(
                          onTap: _answerSubmitted ? null : () {
                            setState(() {
                              _selectedAlternativaId = alternativa.idAlternativa;
                            });
                            _saveResponse(alternativa.idAlternativa, alternativa.correcta);
                          },
                          child: Alternativa(
                            texto: alternativa.texto,
                            explicacion: alternativa.explicacion,
                            idAlternativa: alternativa.idAlternativa,
                            correcta: alternativa.correcta,
                            isSelected: isSelected,
                            showResult: showResult,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}

class HighlightedText {
  final int start;
  final int end;

  HighlightedText(this.start, this.end);
}
