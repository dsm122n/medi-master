import 'package:flutter/material.dart';

class Alternativa extends StatelessWidget {
  final String idAlternativa;
  final String texto;
  final String explicacion;
  final bool correcta;
  final bool isSelected;
  final bool showResult;

  const Alternativa({
    super.key,
    required this.idAlternativa,
    required this.texto,
    required this.explicacion,
    required this.correcta,
    this.isSelected = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    
    if (showResult) {
      if (correcta) {
        // Correct answer should always show as green when showing results
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (isSelected && !correcta) {
        // Selected wrong answer
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      } else {
        // Other non-selected, incorrect options
        backgroundColor = Colors.transparent;
        borderColor = Colors.grey;
      }
    } else {
      // Normal state (before submitting)
      backgroundColor = isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent;
      borderColor = isSelected ? Colors.blue : Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texto,
              style: const TextStyle(fontSize: 16),
            ),
            if (showResult && (correcta || isSelected)) ...[
              const Divider(),
              Text(
                explicacion,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
