import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class RotaCap extends StatelessWidget {
  const RotaCap({super.key, this.size = 128});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CapPainter()),
    );
  }
}

class RotaWordmark extends StatelessWidget {
  const RotaWordmark({super.key, this.fontSize = 56});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w800,
      fontSize: fontSize,
      color: AppColors.text,
      height: 1,
      letterSpacing: 2,
    );
    final radarSize = fontSize * 0.82;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('R', style: style),
        SizedBox(width: fontSize * 0.06),
        Padding(
          padding: EdgeInsets.only(bottom: fontSize * 0.08),
          child: SizedBox(
            width: radarSize,
            height: radarSize,
            child: CustomPaint(painter: _RadarPainter()),
          ),
        ),
        SizedBox(width: fontSize * 0.06),
        Text('T', style: style),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text('A', style: style),
            Positioned(
              right: -fontSize * 0.18,
              top: -fontSize * 0.28,
              child: Transform.rotate(
                angle: 0.18,
                child: Icon(
                  Icons.school_rounded,
                  color: AppColors.text,
                  size: fontSize * 0.42,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RotaSplashMark extends StatelessWidget {
  const RotaSplashMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotaCap(size: 168),
        SizedBox(height: 28),
        RotaWordmark(fontSize: 52),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;
    canvas.drawCircle(center, size.width * 0.46, paint);
    canvas.drawCircle(center, size.width * 0.28, paint..strokeWidth = size.width * 0.055);
    canvas.drawCircle(
      center,
      size.width * 0.08,
      Paint()
        ..color = AppColors.text
        ..style = PaintingStyle.fill,
    );
    final sweep = Paint()
      ..color = AppColors.text.withValues(alpha: 0.9)
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + size.width * 0.22, center.dy - size.height * 0.22), sweep);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.46;
    final cy = size.height * 0.42;
    final board = size.width * 0.42;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 4);

    final left = Path()
      ..moveTo(-board, -board)
      ..lineTo(6, -board)
      ..lineTo(6, -18)
      ..arcToPoint(const Offset(6, 18), radius: const Radius.circular(18), clockwise: true)
      ..lineTo(6, board)
      ..lineTo(-board, board)
      ..close();

    final right = Path()
      ..moveTo(board, -board)
      ..lineTo(-6, -board)
      ..lineTo(-6, -18)
      ..arcToPoint(const Offset(-6, 18), radius: const Radius.circular(18), clockwise: false)
      ..lineTo(-6, board)
      ..lineTo(board, board)
      ..close();

    final shadow = Path()
      ..addPath(left, Offset.zero)
      ..addPath(right, Offset.zero);
    canvas.drawShadow(shadow, Colors.black54, 10, false);
    canvas.drawPath(right, Paint()..color = AppColors.primary);
    canvas.drawPath(left, Paint()..color = AppColors.text);
    canvas.restore();

    final tassel = Paint()
      ..color = AppColors.success
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final start = Offset(size.width * 0.62, size.height * 0.34);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.38,
        size.width * 0.84,
        size.height * 0.55,
        size.width * 0.80,
        size.height * 0.78,
      );
    canvas.drawPath(path, tassel);
    canvas.drawCircle(
      Offset(size.width * 0.80, size.height * 0.82),
      size.width * 0.055,
      Paint()..color = AppColors.success,
    );
    canvas.drawCircle(start, size.width * 0.035, Paint()..color = AppColors.success);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
