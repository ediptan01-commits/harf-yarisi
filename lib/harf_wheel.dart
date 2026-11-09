import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visual alphabet wheel. The winning letter is determined by the room server,
/// not by the local animation, so all players share the same round letter.
class HarfWheel extends StatelessWidget {
  const HarfWheel({super.key, this.spinning = false, this.size = 170});
  final bool spinning;
  final double size;

  static const letters = <String>[
    'A','B','C','Ç','D','E','F','G','H','İ','K',
    'L','M','N','O','P','R','S','T','U','Y','Z',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 12,
      child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          key: ValueKey(spinning),
          tween: Tween<double>(begin: 0, end: spinning ? 8 * math.pi : 0),
          duration: Duration(milliseconds: spinning ? 2900 : 0),
          curve: Curves.easeOutCubic,
          builder: (_, angle, child) => Transform.rotate(
            angle: angle,
            child: child,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _AlphabetWheelPainter(letters)),
          ),
        ),
        Positioned(
          top: 0,
          child: Icon(Icons.arrow_drop_down, color: const Color(0xFF7B3900),
            size: size * 0.21),
        ),
        Container(
          width: size * 0.24,
          height: size * 0.24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF4),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB35B00), width: 2),
          ),
          child: Icon(Icons.auto_awesome, color: const Color(0xFFF57C00),
            size: size * 0.13),
        ),
      ]),
    );
  }
}

class _AlphabetWheelPainter extends CustomPainter {
  const _AlphabetWheelPainter(this.letters);
  final List<String> letters;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.46;
    final angle = 2 * math.pi / letters.length;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < letters.length; index++) {
      paint.color = index.isEven
          ? const Color(0xFFFF8C11)
          : const Color(0xFFFFDBAD);
      canvas.drawArc(bounds, -math.pi / 2 + index * angle,
          angle, true, paint);
      final theta = -math.pi / 2 + (index + 0.5) * angle;
      final point = center + Offset(
        math.cos(theta) * radius * 0.77,
        math.sin(theta) * radius * 0.77,
      );
      final label = TextPainter(
        text: TextSpan(
          text: letters[index],
          style: TextStyle(
            color: index.isEven ? Colors.white : const Color(0xFF774000),
            fontSize: radius * 0.15,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas,
          point - Offset(label.width / 2, label.height / 2));
    }
    canvas.drawCircle(center, radius, Paint()
      ..color = const Color(0xFFAA5400)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant _AlphabetWheelPainter oldDelegate) =>
      oldDelegate.letters != letters;
}
