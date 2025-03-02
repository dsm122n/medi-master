import 'package:flutter/material.dart';

class TooltipShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

class QuestionNavigator extends StatelessWidget {
  final int totalQuestions;
  final Function(int) onQuestionSelected;

  const QuestionNavigator({
    super.key,
    required this.totalQuestions, // Ensure totalQuestions is required
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.grid_view),
      offset: const Offset(0, 50),
      shape: TooltipShape(),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            enabled: false,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.4,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onQuestionSelected(index + 1);
                    },
                    child: Text('${index + 1}'),
                  );
                },
              ),
            ),
          ),
        ];
      },
    );
  }
}
