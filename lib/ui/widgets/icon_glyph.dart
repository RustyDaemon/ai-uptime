import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens.dart';

enum IconGlyphKind { refresh, close, chevronDown, check }

class IconGlyph extends StatelessWidget {
  final IconGlyphKind kind;
  final double size;
  final Color? color;
  final double strokeWidth;

  const IconGlyph({
    super.key,
    required this.kind,
    this.size = 14,
    this.color,
    this.strokeWidth = 1.4,
  });

  const IconGlyph.refresh({
    super.key,
    this.size = 14,
    this.color,
    this.strokeWidth = 1.4,
  }) : kind = IconGlyphKind.refresh;

  const IconGlyph.close({
    super.key,
    this.size = 14,
    this.color,
    this.strokeWidth = 1.4,
  }) : kind = IconGlyphKind.close;

  const IconGlyph.chevronDown({
    super.key,
    this.size = 14,
    this.color,
    this.strokeWidth = 1.4,
  }) : kind = IconGlyphKind.chevronDown;

  const IconGlyph.check({
    super.key,
    this.size = 14,
    this.color,
    this.strokeWidth = 1.4,
  }) : kind = IconGlyphKind.check;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          kind: kind,
          color: color ?? AppColors.text,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final IconGlyphKind kind;
  final Color color;
  final double strokeWidth;

  _GlyphPainter({
    required this.kind,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (kind) {
      case IconGlyphKind.refresh:
        _paintRefresh(canvas, size, paint);
        break;
      case IconGlyphKind.close:
        _paintClose(canvas, size, paint);
        break;
      case IconGlyphKind.chevronDown:
        _paintChevron(canvas, size, paint);
        break;
      case IconGlyphKind.check:
        _paintCheck(canvas, size, paint);
        break;
    }
  }

  void _paintRefresh(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi * 0.5;
    const sweep = math.pi * 1.55;
    canvas.drawArc(rect, start, sweep, false, paint);

    final end = Offset(
      center.dx + radius * math.cos(start + sweep),
      center.dy + radius * math.sin(start + sweep),
    );
    final tangent = Offset(-math.sin(start + sweep), math.cos(start + sweep));
    final normal = Offset(math.cos(start + sweep), math.sin(start + sweep));
    final headLen = size.width * 0.22;
    final p1 = end + tangent * -headLen + normal * headLen * 0.5;
    final p2 = end + tangent * -headLen - normal * headLen * 0.5;
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo(p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  void _paintClose(Canvas canvas, Size size, Paint paint) {
    final p = size.width * 0.28;
    canvas.drawLine(
      Offset(p, p),
      Offset(size.width - p, size.height - p),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - p, p),
      Offset(p, size.height - p),
      paint,
    );
  }

  void _paintChevron(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.75, size.height * 0.4);
    canvas.drawPath(path, paint);
  }

  void _paintCheck(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.32);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.kind != kind || old.color != color || old.strokeWidth != strokeWidth;
}
