import 'package:flutter/material.dart';

class BodyVisualization extends StatelessWidget {
  final Map<String, double> bodyPartVolume;

  const BodyVisualization({super.key, required this.bodyPartVolume});

  Color _getColor(String part) {
    final vol = bodyPartVolume[part] ?? 0;
    if (vol <= 0) return const Color(0xFF2C2C3E);
    final max = bodyPartVolume.values.fold(0.0, (a, b) => a > b ? a : b);
    final ratio = max > 0 ? (vol / max).clamp(0.0, 1.0) : 0.0;
    return Color.lerp(
      const Color(0xFF2C5364),
      const Color(0xFFFF6B35),
      ratio,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 左の部位ラベル
          _buildSideLabels(['胸', '肩', '腕'], true),
          const SizedBox(width: 12),
          // 人体シルエット
          _buildSilhouette(),
          const SizedBox(width: 12),
          // 右の部位ラベル
          _buildSideLabels(['背中', 'お腹', '足'], false),
        ],
      ),
    );
  }

  Widget _buildSideLabels(List<String> parts, bool isLeft) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: parts.map((part) {
        final vol = bodyPartVolume[part] ?? 0;
        final hasVol = vol > 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isLeft)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColor(part),
                ),
              ),
            if (!isLeft) const SizedBox(width: 4),
            Column(
              crossAxisAlignment: isLeft
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  part,
                  style: TextStyle(
                    color: hasVol ? Colors.white : Colors.white38,
                    fontSize: 12,
                    fontWeight:
                        hasVol ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (hasVol)
                  Text(
                    '${vol.toStringAsFixed(0)}kg',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            if (isLeft) const SizedBox(width: 4),
            if (isLeft)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColor(part),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSilhouette() {
    return SizedBox(
      width: 120,
      height: 260,
      child: CustomPaint(
        painter: _BodyPainter(
          chestColor: _getColor('胸'),
          shoulderColor: _getColor('肩'),
          armColor: _getColor('腕'),
          backColor: _getColor('背中'),
          absColor: _getColor('お腹'),
          legColor: _getColor('足'),
          cardioColor: _getColor('有酸素'),
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final Color chestColor;
  final Color shoulderColor;
  final Color armColor;
  final Color backColor;
  final Color absColor;
  final Color legColor;
  final Color cardioColor;

  _BodyPainter({
    required this.chestColor,
    required this.shoulderColor,
    required this.armColor,
    required this.backColor,
    required this.absColor,
    required this.legColor,
    required this.cardioColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 輪郭線用ペイント
    final outlinePaint = Paint()
      ..color = const Color(0xFF4A4A6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 頭
    final headPaint = Paint()
      ..color = const Color(0xFF3A3A5C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.07), w * 0.12, headPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.07), w * 0.12, outlinePaint);

    // 首
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.13, w * 0.16, h * 0.05),
      const Radius.circular(4),
    );
    canvas.drawRRect(neckRect, Paint()..color = const Color(0xFF3A3A5C));

    // 肩（左右）
    final shoulderPaint = Paint()
      ..color = shoulderColor
      ..style = PaintingStyle.fill;
    // 左肩
    canvas.drawOval(
      Rect.fromLTWH(w * 0.05, h * 0.16, w * 0.22, h * 0.1),
      shoulderPaint,
    );
    // 右肩
    canvas.drawOval(
      Rect.fromLTWH(w * 0.73, h * 0.16, w * 0.22, h * 0.1),
      shoulderPaint,
    );

    // 胸
    final chestPath = Path()
      ..moveTo(w * 0.25, h * 0.18)
      ..lineTo(w * 0.75, h * 0.18)
      ..lineTo(w * 0.78, h * 0.35)
      ..lineTo(w * 0.22, h * 0.35)
      ..close();
    canvas.drawPath(chestPath, Paint()..color = chestColor);
    canvas.drawPath(chestPath, outlinePaint);

    // お腹
    final absPath = Path()
      ..moveTo(w * 0.25, h * 0.35)
      ..lineTo(w * 0.75, h * 0.35)
      ..lineTo(w * 0.72, h * 0.52)
      ..lineTo(w * 0.28, h * 0.52)
      ..close();
    canvas.drawPath(absPath, Paint()..color = absColor);
    canvas.drawPath(absPath, outlinePaint);

    // 腕（左右）
    final armPaint = Paint()
      ..color = armColor
      ..style = PaintingStyle.fill;
    // 左腕
    final leftArmPath = Path()
      ..moveTo(w * 0.08, h * 0.2)
      ..lineTo(w * 0.24, h * 0.2)
      ..lineTo(w * 0.2, h * 0.52)
      ..lineTo(w * 0.05, h * 0.5)
      ..close();
    canvas.drawPath(leftArmPath, armPaint);
    canvas.drawPath(leftArmPath, outlinePaint);
    // 右腕
    final rightArmPath = Path()
      ..moveTo(w * 0.76, h * 0.2)
      ..lineTo(w * 0.92, h * 0.2)
      ..lineTo(w * 0.95, h * 0.5)
      ..lineTo(w * 0.8, h * 0.52)
      ..close();
    canvas.drawPath(rightArmPath, armPaint);
    canvas.drawPath(rightArmPath, outlinePaint);

    // 腰
    final hipPath = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.72, h * 0.52)
      ..lineTo(w * 0.7, h * 0.6)
      ..lineTo(w * 0.3, h * 0.6)
      ..close();
    canvas.drawPath(
        hipPath, Paint()..color = const Color(0xFF3A3A5C));
    canvas.drawPath(hipPath, outlinePaint);

    // 足（左右）
    final legPaint = Paint()
      ..color = legColor
      ..style = PaintingStyle.fill;
    // 左足
    final leftLegPath = Path()
      ..moveTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.5, h * 0.6)
      ..lineTo(w * 0.48, h * 1.0)
      ..lineTo(w * 0.28, h * 1.0)
      ..close();
    canvas.drawPath(leftLegPath, legPaint);
    canvas.drawPath(leftLegPath, outlinePaint);
    // 右足
    final rightLegPath = Path()
      ..moveTo(w * 0.5, h * 0.6)
      ..lineTo(w * 0.7, h * 0.6)
      ..lineTo(w * 0.72, h * 1.0)
      ..lineTo(w * 0.52, h * 1.0)
      ..close();
    canvas.drawPath(rightLegPath, legPaint);
    canvas.drawPath(rightLegPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) =>
      old.chestColor != chestColor ||
      old.shoulderColor != shoulderColor ||
      old.armColor != armColor ||
      old.absColor != absColor ||
      old.legColor != legColor;
}
