import 'package:flutter/material.dart';

/// 部位ごとのネオンカラー定義（スタイル2: サイバーパンク）
const Map<String, Color> kBodyPartColor = {
  '胸':    Color(0xFF00CFFF),   // シアン
  '肩':    Color(0xFFFF8C00),   // オレンジ
  '腕':    Color(0xFFFFE600),   // イエロー
  '背中':  Color(0xFFBF5FFF),   // パープル
  'お腹':  Color(0xFF00E676),   // グリーン
  '足':    Color(0xFFFF3D3D),   // レッド
  '有酸素': Color(0xFFFF6B35),  // ネオンオレンジ
};

/// 画像オーバーレイ方式 ネオン人体マップ
/// 素材画像の上に透明なタップ領域を重ねて部位選択を実現
class NeonBodyMap extends StatelessWidget {
  /// 部位名 → 0.0〜1.0 の強度マップ（記録があるほど1.0に近い）
  final Map<String, double> intensity;
  /// タップされた部位コールバック
  final void Function(String bodyPart)? onTap;

  const NeonBodyMap({
    super.key,
    required this.intensity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 768 / 1376, // 生成画像の実アスペクト比
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── ベース画像 ────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/body_map.png',
              fit: BoxFit.contain,
            ),
          ),

          // ── 強度ハイライトオーバーレイ ──────────────────────
          LayoutBuilder(builder: (ctx, box) {
            return Stack(children: [
              // 胸
              _highlight('胸',   box, 0.20, 0.20, 0.36, 0.14),
              // 肩(左右)
              _highlight('肩',   box, 0.56, 0.18, 0.14, 0.12),
              _highlight('肩',   box, 0.30, 0.18, 0.14, 0.12),
              // 腕(左右上腕+前腕)
              _highlight('腕',   box, 0.62, 0.28, 0.14, 0.30),
              _highlight('腕',   box, 0.24, 0.28, 0.14, 0.30),
              // お腹
              _highlight('お腹', box, 0.32, 0.34, 0.36, 0.24),
              // 背中（僧帽・上部）
              _highlight('背中', box, 0.36, 0.14, 0.28, 0.08),
              // 足(大腿+ふくらはぎ)
              _highlight('足',   box, 0.52, 0.60, 0.18, 0.40),
              _highlight('足',   box, 0.30, 0.60, 0.18, 0.40),
            ]);
          }),

          // ── タップ領域 ────────────────────────────────────
          LayoutBuilder(builder: (ctx, box) {
            return Stack(children: [
              _tapArea('胸',   box, 0.20, 0.18, 0.60, 0.18),
              _tapArea('肩',   box, 0.56, 0.16, 0.16, 0.14),
              _tapArea('肩',   box, 0.28, 0.16, 0.16, 0.14),
              _tapArea('腕',   box, 0.62, 0.26, 0.16, 0.32),
              _tapArea('腕',   box, 0.22, 0.26, 0.16, 0.32),
              _tapArea('お腹', box, 0.30, 0.33, 0.40, 0.26),
              _tapArea('背中', box, 0.34, 0.13, 0.32, 0.10),
              _tapArea('足',   box, 0.50, 0.58, 0.20, 0.42),
              _tapArea('足',   box, 0.30, 0.58, 0.20, 0.42),
            ]);
          }),
        ],
      ),
    );
  }

  /// 強度に応じたネオングロウオーバーレイ
  Widget _highlight(
    String part,
    BoxConstraints box,
    double left,
    double top,
    double width,
    double height,
  ) {
    final v = intensity[part] ?? 0.0;
    if (v <= 0) return const SizedBox.shrink();
    final color = kBodyPartColor[part] ?? const Color(0xFFFF6B35);
    final w = box.maxWidth;
    final h = box.maxHeight;

    return Positioned(
      left:   w * left,
      top:    h * top,
      width:  w * width,
      height: h * height,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: v * 0.25),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: v * 0.55),
                blurRadius: 16 * v,
                spreadRadius: 2 * v,
              ),
            ],
            border: Border.all(
              color: color.withValues(alpha: v * 0.7),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// 透明タップ領域
  Widget _tapArea(
    String part,
    BoxConstraints box,
    double left,
    double top,
    double width,
    double height,
  ) {
    final w = box.maxWidth;
    final h = box.maxHeight;
    return Positioned(
      left:   w * left,
      top:    h * top,
      width:  w * width,
      height: h * height,
      child: GestureDetector(
        onTap: () => onTap?.call(part),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
