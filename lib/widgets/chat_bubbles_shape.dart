import 'package:flutter/material.dart';

class ChatBubblesShape extends CustomPainter {
  final Color bgColor;

  ChatBubblesShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 12);
    path.lineTo(8, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
