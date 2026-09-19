import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CoachClientProgressChart extends StatelessWidget {
  const CoachClientProgressChart({
    super.key,
    required this.dataPoints,
    required this.xLabels,
  });

  final List<double> dataPoints;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(dataPoints: dataPoints, xLabels: xLabels),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.dataPoints, required this.xLabels});

  final List<double> dataPoints;
  final List<String> xLabels;

  static const _yLabels = ['100%', '75%', '50%', '25%', '0%'];
  static const _leftPad = 44.0;
  static const _bottomPad = 22.0;
  static const _rightPad = 8.0;
  static const _topPad = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final ratio = i / (_yLabels.length - 1);
      final y = _topPad + chartH * ratio;
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + chartW, y),
        gridPaint,
      );
      _paintText(
        canvas,
        _yLabels[i],
        Offset(0, y - 7),
        const Color(0xFF9E9E9E),
        9.5,
      );
    }

    if (dataPoints.length < 2) return;

    // Gradient fill under the line
    final fillPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = _leftPad + chartW * i / (dataPoints.length - 1);
      final y = _topPad + chartH * (1 - dataPoints[i]);
      if (i == 0) {
        fillPath.moveTo(x, y);
      } else {
        final prevX = _leftPad + chartW * (i - 1) / (dataPoints.length - 1);
        final prevY = _topPad + chartH * (1 - dataPoints[i - 1]);
        final cpX = prevX + (x - prevX) / 2;
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    fillPath.lineTo(_leftPad + chartW, _topPad + chartH);
    fillPath.lineTo(_leftPad, _topPad + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5273E0).withValues(alpha: 0.3),
            const Color(0xFF5273E0).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(_leftPad, _topPad, chartW, chartH)),
    );

    // Smooth bezier line
    final linePath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = _leftPad + chartW * i / (dataPoints.length - 1);
      final y = _topPad + chartH * (1 - dataPoints[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = _leftPad + chartW * (i - 1) / (dataPoints.length - 1);
        final prevY = _topPad + chartH * (1 - dataPoints[i - 1]);
        final cpX = prevX + (x - prevX) / 2;
        linePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.streakPurple
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // X-axis labels
    _paintText(
      canvas,
      'Days',
      Offset(0, size.height - _bottomPad + 5),
      const Color(0xFF6B6B6B),
      9.0,
    );
    for (int i = 0; i < xLabels.length; i++) {
      final x = _leftPad + chartW * i / (xLabels.length - 1);
      _paintText(
        canvas,
        xLabels[i],
        Offset(x - xLabels[i].length * 2.8, size.height - _bottomPad + 5),
        const Color(0xFF9E9E9E),
        9.5,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.dataPoints != dataPoints || old.xLabels != xLabels;
}
