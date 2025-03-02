import 'package:flutter/material.dart';
import 'dart:math';

class ListadoPruebas extends StatelessWidget {
  const ListadoPruebas({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
      for (int i = 0; i < 15; i++)
        PruebaCard(title: 'Prueba $i', subtitle: 'Descripción de la prueba $i', route: '/prueba$i'),]
    );
      
  }
}

class PruebaCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String route;

  const PruebaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  State<PruebaCard> createState() => _PruebaCardState();
}

class _PruebaCardState extends State<PruebaCard> {
  final int totalQuestions = Random().nextInt(90); // Placeholder total number of questions
  late int correct;
  late int incorrect;
  late int unanswered;
  late double correctProgress;
  late double incorrectProgress;
  late double unansweredProgress;

  @override
  void initState() {
    super.initState();
    _generateProgress();
  }

  void _generateProgress() {
    setState(() {
      correct = Random().nextInt(totalQuestions);
      correctProgress = (correct / totalQuestions) * 100;
      incorrect = Random().nextInt(totalQuestions - correct);
      incorrectProgress = (incorrect / totalQuestions) * 100;
      unanswered = totalQuestions - (correct + incorrect);
      unansweredProgress = (unanswered / totalQuestions) * 100;
    });
  }

  int get answeredQuestions => (correct + incorrect);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.title),
            subtitle: Text(widget.subtitle),
            onTap: () => Navigator.of(context).pushNamed(widget.route),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (correctProgress * 100).toInt(),
                          child: Container(color: Colors.blue),
                        ),
                        Expanded(
                          flex: (incorrectProgress * 100).toInt(),
                          child: Container(color: Colors.yellow),
                        ),
                        Expanded(
                          flex: (unansweredProgress * 100).toInt(),
                          child: Container(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text('Total respondidas: $answeredQuestions/$totalQuestions',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
