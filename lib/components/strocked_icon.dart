import 'package:flutter/material.dart';

class StrokedIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;
  final VoidCallback? onTap;

  const StrokedIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.strokeColor,
    required this.strokeWidth,
    required this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter:
            IconStrokePainter(icon, size, strokeColor, strokeWidth, fillColor),
      ),
    );
  }
}

class IconStrokePainter extends CustomPainter {
  final IconData icon;
  final double size;
  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;

  IconStrokePainter(
      this.icon, this.size, this.strokeColor, this.strokeWidth, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint fill
    final fillPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width,
          fontFamily: icon.fontFamily,
          color: fillColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    fillPainter.paint(canvas, Offset.zero);

    // Paint stroke
    final strokePainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width,
          fontFamily: icon.fontFamily,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = strokeColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    strokePainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
