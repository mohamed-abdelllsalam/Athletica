import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachLineChart extends StatelessWidget {
  const CoachLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 180.h,
        child: CustomPaint(
          painter: _LineChartPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  // Data values on a 0–4 y-axis scale, mirroring the monthly chart in designs
  static const List<double> _data = [1.2, 1.8, 2.0, 1.8, 2.5, 1.8, 3.8];
  static const double _yMin = 0.0;
  static const double _yMax = 4.0;

  static const double _leftPad = 28.0;
  static const double _bottomPad = 36.0;
  static const double _topPad = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double chartW = size.width - _leftPad;
    final double chartH = size.height - _bottomPad - _topPad;

    _drawGridLines(canvas, size, chartW, chartH);
    _drawYAxisLabels(canvas, size, chartH);
    _drawXAxisLabels(canvas, size, chartW);
    _drawCurve(canvas, chartW, chartH);
  }

  void _drawGridLines(Canvas canvas, Size size, double chartW, double chartH) {
    final paint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = _topPad + chartH - (i / 4) * chartH;
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double chartH) {
    for (int i = 1; i <= 4; i++) {
      final y = _topPad + chartH - ((i - _yMin) / (_yMax - _yMin)) * chartH;
      final label = i == 4 ? '4+' : '$i';
      _paintText(canvas, label, Offset(_leftPad - 26, y - 6));
    }
  }

  void _drawXAxisLabels(Canvas canvas, Size size, double chartW) {
    for (int i = 0; i < 7; i++) {
      final x = _leftPad + (i / 6) * chartW;
      _paintText(canvas, '${i + 1}', Offset(x - 4, size.height - 28));
    }

    // Bottom axis descriptors
    _paintText(canvas, 'WEEK', Offset(0, size.height - 14), fontSize: 9);
    _paintText(canvas, 'Days', Offset(_leftPad, size.height - 14), fontSize: 9);
  }

  void _drawCurve(Canvas canvas, double chartW, double chartH) {
    final linePaint = Paint()
      ..color = const Color(0xFF5C7CFA)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = List.generate(_data.length, (i) {
      return _toCanvas(i.toDouble(), _data[i], chartW, chartH);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    // Cardinal spline with tension 0.4 for smooth interpolation
    const double tension = 0.4;
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * tension / 2,
        p1.dy + (p2.dy - p0.dy) * tension / 2,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * tension / 2,
        p2.dy - (p3.dy - p1.dy) * tension / 2,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(path, linePaint);
  }

  Offset _toCanvas(double xIndex, double yValue, double chartW, double chartH) {
    final dx = _leftPad + (xIndex / (_data.length - 1)) * chartW;
    final dy = _topPad + chartH - ((yValue - _yMin) / (_yMax - _yMin)) * chartH;
    return Offset(dx, dy);
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 10,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF9E9E9E),
          fontSize: fontSize,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
