import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

/// 進捗タブ – 週間統計 + 人体画像（放射状ライン＋部位総重量）+ 月別履歴
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(child: _buildBody(context, provider)),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutProvider provider) {
    final volMap = provider.recentBodyPartVolume;
    final maxVol = volMap.values.fold(0.0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ヘッダー ──────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
            child: Text('進捗',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('直近7日間のトレーニング分析',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          ),

          // ── 週間統計カード（3つ）────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Expanded(child: _statCard(
                '合計ボリューム',
                '${provider.recentTotalVolumeTons.toStringAsFixed(2)}t',
                Icons.trending_up,
                const Color(0xFFFF6B35),
              )),
              const SizedBox(width: 8),
              Expanded(child: _statCard(
                '部位カバー',
                '${provider.recentBodyPartCount}/7',
                Icons.accessibility_new,
                const Color(0xFF00CFFF),
              )),
              const SizedBox(width: 8),
              Expanded(child: _statCard(
                '今月セッション',
                '${provider.thisMonthWorkoutCount}回',
                Icons.calendar_today,
                const Color(0xFFFFD93D),
              )),
            ]),
          ),
          const SizedBox(height: 24),

          // ── 人体マップ（放射状ライン + 部位ラベル）──────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _BodyRadarWidget(volMap: volMap, maxVol: maxVol),
          ),
          const SizedBox(height: 24),

          // ── 部位別ボリュームバー ─────────────────────────
          _buildBodyPartBars(provider),
          const SizedBox(height: 24),

          // ── 月別トレーニング履歴 ───────────────────────────
          _buildMonthlySection(provider),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(
            color: Color(0xFF666666), fontSize: 9)),
        ],
      ),
    );
  }

  // 部位別ボリュームバー
  Widget _buildBodyPartBars(WorkoutProvider provider) {
    final volMap = provider.recentBodyPartVolume;
    final maxVol = volMap.values.fold(0.0, (a, b) => a > b ? a : b);

    const parts = ['胸', '肩', '腕', '背中', 'お腹', '足', '有酸素'];
    const colors = {
      '胸':    Color(0xFF00CFFF),
      '肩':    Color(0xFFFF8C00),
      '腕':    Color(0xFFFFE600),
      '背中':  Color(0xFFBF5FFF),
      'お腹':  Color(0xFF00E676),
      '足':    Color(0xFFFF3D3D),
      '有酸素': Color(0xFFFF6B35),
    };
    const icons = {
      '胸':    Icons.fitness_center,
      '肩':    Icons.accessibility_new,
      '腕':    Icons.sports_handball,
      '背中':  Icons.airline_seat_flat,
      'お腹':  Icons.circle_outlined,
      '足':    Icons.directions_walk,
      '有酸素': Icons.directions_run,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('部位別ボリューム (直近7日)',
            style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        ...parts.map((part) {
          final vol = volMap[part] ?? 0;
          final ratio = maxVol > 0 ? (vol / maxVol).clamp(0.0, 1.0) : 0.0;
          final color = colors[part] ?? const Color(0xFFAFAFAF);
          final icon  = icons[part] ?? Icons.sports_gymnastics;
          final volLabel = vol > 0
              ? (vol >= 1000
                  ? '${(vol / 1000).toStringAsFixed(1)}t'
                  : '${vol.toStringAsFixed(0)}kg')
              : '-';

          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: vol > 0
                    ? color.withValues(alpha: 0.3)
                    : const Color(0xFF1E1E1E),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: vol > 0 ? 0.15 : 0.05),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon,
                    color: vol > 0 ? color : const Color(0xFF333333),
                    size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(part,
                            style: TextStyle(
                              color: vol > 0 ? Colors.white : const Color(0xFF555555),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                          Text(volLabel,
                            style: TextStyle(
                              color: vol > 0 ? color : const Color(0xFF333333),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 4,
                          backgroundColor: const Color(0xFF1E1E1E),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            vol > 0 ? color : const Color(0xFF2A2A2A)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlySection(WorkoutProvider provider) {
    final now = DateTime.now();
    final thisMonth = provider.workouts
        .where((w) => w.date.year == now.year && w.date.month == now.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('今月の記録 (${thisMonth.length}セッション)',
            style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        if (thisMonth.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('まだ記録がありません',
              style: TextStyle(color: Color(0xFF444444), fontSize: 13)),
          )
        else
          ...thisMonth.take(5).map((w) => _workoutHistoryTile(w)),
      ],
    );
  }

  Widget _workoutHistoryTile(dynamic w) {
    final dateStr = DateFormat('M/d(E)', 'ja').format(w.date as DateTime);
    final parts = (w.exercises as List)
        .map((e) => e.bodyPart as String)
        .toSet()
        .join(' • ');
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                DateFormat('d').format(w.date as DateTime),
                style: const TextStyle(
                  color: Color(0xFFFF6B35), fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                if (parts.isNotEmpty)
                  Text(parts,
                    style: const TextStyle(color: Color(0xFF666666), fontSize: 11)),
              ],
            ),
          ),
          Text('${(w.exercises as List).length}種目',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
        ],
      ),
    );
  }
}

// ── 人体画像中央 + 放射状ライン ウィジェット ────────────────
class _BodyRadarWidget extends StatelessWidget {
  final Map<String, double> volMap;
  final double maxVol;

  const _BodyRadarWidget({required this.volMap, required this.maxVol});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        children: [
          const Text('部位別トレーニングボリューム (直近7日)',
            style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
          const SizedBox(height: 12),
          SizedBox(
            height: 520,
            child: CustomPaint(
              painter: _RadarPainter(volMap: volMap, maxVol: maxVol),
              child: Stack(
                children: [
                  // 中央: 人体画像
                  Center(
                    child: SizedBox(
                      width: 160,
                      height: 285,
                      child: Image.asset(
                        'assets/images/body_map.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ペインター: 固定位置ラインとラベル ────────────────────────
// ・全部位を常に表示（データなし = グレー）
// ・ライン長・ラベル位置は完全固定（ボリューム連動なし）
// ・折れ線スタイル: 筋肉エッジ → 水平引き出し → ラベル
class _RadarPainter extends CustomPainter {
  final Map<String, double> volMap;
  final double maxVol;

  static const _parts = ['胸', '肩', '腕', '背中', 'お腹', '足', '有酸素'];

  static const Map<String, Color> _colors = {
    '胸':    Color(0xFF00CFFF),
    '肩':    Color(0xFFFF8C00),
    '腕':    Color(0xFFFFE600),
    '背中':  Color(0xFFBF5FFF),
    'お腹':  Color(0xFF00E676),
    '足':    Color(0xFFFF3D3D),
    '有酸素': Color(0xFFFF6B35),
  };

  // ── アンカー座標（画像内の正規化 0〜1）────────────────────
  // 画像分析結果を元に各筋肉部位のエッジ位置を設定
  static const Map<String, Offset> _anchors = {
    '胸':    Offset(0.28, 0.30),  // 左大胸筋エッジ
    '肩':    Offset(0.78, 0.22),  // 右三角筋外側
    '腕':    Offset(0.82, 0.38),  // 右上腕外側
    '背中':  Offset(0.30, 0.18),  // 左僧帽筋エッジ
    'お腹':  Offset(0.30, 0.48),  // 左腹直筋エッジ
    '足':    Offset(0.72, 0.65),  // 右大腿外側
    '有酸素': Offset(0.28, 0.82), // 左ふくらはぎ外側
  };

  // ── 引き出し方向（-1=左, +1=右）────────────────────────────
  static const Map<String, double> _side = {
    '胸':    -1.0,
    '肩':     1.0,
    '腕':     1.0,
    '背中':  -1.0,
    'お腹':  -1.0,
    '足':     1.0,
    '有酸素': -1.0,
  };

  const _RadarPainter({required this.volMap, required this.maxVol});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 画像の描画エリア（ウィジェット側の width:160, height:285 と合わせる）
    const imgW = 160.0;
    const imgH = 285.0;
    final imgL = cx - imgW / 2;
    final imgT = cy - imgH / 2;

    for (final part in _parts) {
      final vol      = volMap[part] ?? 0;
      final color    = _colors[part] ?? const Color(0xFFFF6B35);
      final hasData  = vol > 0;
      final side     = _side[part]!;          // -1=左  +1=右
      final anchor   = _anchors[part]!;

      // アンカー絶対座標
      final ax = imgL + anchor.dx * imgW;
      final ay = imgT + anchor.dy * imgH;

      // ── ライン端点（水平固定長）──────────────────────────────
      final p2x = ax + side * 55;   // 固定長さ 55px
      final p2y = ay;

      final lineColor  = hasData ? color.withValues(alpha: 0.9)  : const Color(0xFF2E2E2E);
      final glowColor  = hasData ? color.withValues(alpha: 0.3)  : Colors.transparent;
      final dotColor   = hasData ? color                          : const Color(0xFF2E2E2E);
      final strokeW    = hasData ? 1.6 : 0.8;

      if (hasData) {
        // グロウ（太め・ぼかし）
        final glowPaint = Paint()
          ..color = glowColor
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawLine(Offset(ax, ay), Offset(p2x, p2y), glowPaint);
      }

      // メインライン
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(ax, ay), Offset(p2x, p2y), linePaint);

      // アンカードット（起点）
      canvas.drawCircle(Offset(ax, ay), hasData ? 3.0 : 1.5,
        Paint()..color = dotColor);
      if (hasData) {
        canvas.drawCircle(Offset(ax, ay), 5.0,
          Paint()
            ..color = color.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }

      // 端点ドット（ライン先端）
      canvas.drawCircle(Offset(p2x, p2y), hasData ? 2.5 : 1.5,
        Paint()..color = dotColor);

      _drawLabel(canvas, part, vol, color, p2x, p2y, side, hasData);
    }
  }

  void _drawLabel(
    Canvas canvas,
    String part,
    double vol,
    Color color,
    double x,
    double y,
    double side,   // -1=左  +1=右
    bool hasData,
  ) {
    final nameColor = hasData ? color              : const Color(0xFF3A3A3A);
    final volColor  = hasData ? color.withValues(alpha: 0.75) : const Color(0xFF282828);

    final volText = vol > 0
        ? (vol >= 1000
            ? '${(vol / 1000).toStringAsFixed(1)}t'
            : '${vol.toStringAsFixed(0)}kg')
        : '0kg';

    final namePainter = TextPainter(
      text: TextSpan(
        text: part,
        style: TextStyle(
          color: nameColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final volPainter = TextPainter(
      text: TextSpan(
        text: volText,
        style: TextStyle(
          color: volColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    const gap   = 5.0;   // ライン端点とテキストの隙間
    const lineH = 2.0;   // 部位名と重量の行間

    final totalH = namePainter.height + lineH + volPainter.height;
    final baseY  = y - totalH / 2;

    double nameX, volX;
    if (side < 0) {
      // 左側 → 右揃え
      nameX = x - gap - namePainter.width;
      volX  = x - gap - volPainter.width;
    } else {
      // 右側 → 左揃え
      nameX = x + gap;
      volX  = x + gap;
    }

    namePainter.paint(canvas, Offset(nameX, baseY));
    volPainter.paint(canvas, Offset(volX, baseY + namePainter.height + lineH));
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.volMap.toString() != volMap.toString() || old.maxVol != maxVol;
}
