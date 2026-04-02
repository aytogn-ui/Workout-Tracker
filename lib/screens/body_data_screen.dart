import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/workout_provider.dart';
import '../models/body_info.dart';

// ══════════════════════════════════════════════════════════════════════════════
// 身体データ タブ
// ══════════════════════════════════════════════════════════════════════════════
class BodyDataScreen extends StatefulWidget {
  const BodyDataScreen({super.key});

  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

class _BodyDataScreenState extends State<BodyDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── ヘッダー ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('身体データ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      )),
                  ),
                  // HealthKitインポートボタン
                  _headerButton(
                    icon: Icons.ios_share,
                    label: 'HealthKit',
                    color: const Color(0xFF4ECDC4),
                    onTap: () => _openImportSheet(context),
                  ),
                  const SizedBox(width: 8),
                  // 手動追加ボタン
                  _headerButton(
                    icon: Icons.add,
                    label: '手動入力',
                    color: const Color(0xFFFF6B35),
                    onTap: () => _openManualSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── タブバー ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.5)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFFFF6B35),
                unselectedLabelColor: const Color(0xFF555555),
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: '最新データ'),
                  Tab(text: '推移グラフ'),
                  Tab(text: '履歴'),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── タブコンテンツ ─────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: const [
                  _LatestDataTab(),
                  _TrendGraphTab(),
                  _HistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _openImportSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HealthKitImportSheet(
        provider: ctx.read<WorkoutProvider>(),
      ),
    );
  }

  void _openManualSheet(BuildContext ctx) {
    final provider = ctx.read<WorkoutProvider>();
    final latest   = provider.latestBodyInfo;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualEntrySheet(
        provider: provider,
        prefill: latest,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 0: 最新データ
// ══════════════════════════════════════════════════════════════════════════════
class _LatestDataTab extends StatelessWidget {
  const _LatestDataTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final info     = provider.latestBodyInfo;

    if (info == null) {
      return _emptyState(context);
    }

    final bmi = info.bmi;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最終更新 + ソース
          Row(children: [
            Text('最終更新: ${_fmt(info.date)}',
                style: const TextStyle(
                    color: Color(0xFF555555), fontSize: 12)),
            const SizedBox(width: 8),
            _sourceBadge(info.source),
          ]),
          const SizedBox(height: 16),

          // 基本データカード群
          Row(children: [
            Expanded(child: _statCard(
              icon: Icons.person,
              label: '性別',
              value: _genderLabel(info.gender ?? 'male'),
              color: const Color(0xFF4ECDC4),
            )),
            const SizedBox(width: 10),
            Expanded(child: _statCard(
              icon: Icons.cake_outlined,
              label: '年齢',
              value: info.age != null ? '${info.age}歳' : '—',
              color: const Color(0xFFFFD93D),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _statCard(
              icon: Icons.straighten,
              label: '身長',
              value: info.height != null
                  ? '${info.height!.toStringAsFixed(1)} cm' : '—',
              color: const Color(0xFF45B7D1),
            )),
            const SizedBox(width: 10),
            Expanded(child: _statCard(
              icon: Icons.monitor_weight_outlined,
              label: '体重',
              value: info.weight != null
                  ? '${info.weight!.toStringAsFixed(1)} kg' : '—',
              color: const Color(0xFFFF6B35),
            )),
          ]),

          if (bmi != null) ...[
            const SizedBox(height: 10),
            _bmiCard(bmi),
          ],

          if (info.bodyFat != null || info.muscleMass != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E1E1E)),
            const SizedBox(height: 10),
            const Text('詳細データ',
                style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
            const SizedBox(height: 10),
            Row(children: [
              if (info.bodyFat != null)
                Expanded(child: _statCard(
                  icon: Icons.water_drop_outlined,
                  label: '体脂肪率',
                  value: '${info.bodyFat!.toStringAsFixed(1)} %',
                  color: const Color(0xFF6BCB77),
                )),
              if (info.bodyFat != null && info.muscleMass != null)
                const SizedBox(width: 10),
              if (info.muscleMass != null)
                Expanded(child: _statCard(
                  icon: Icons.fitness_center,
                  label: '筋肉量',
                  value: '${info.muscleMass!.toStringAsFixed(1)} kg',
                  color: const Color(0xFFBF5FFF),
                )),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: Color(0xFF2A2A2A), size: 64),
          const SizedBox(height: 16),
          const Text('身体データが未登録です',
              style: TextStyle(color: Color(0xFF555555), fontSize: 15)),
          const SizedBox(height: 8),
          const Text('右上の「手動入力」または「HealthKit」から\nデータを追加してください',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF3A3A3A), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF888888), fontSize: 11)),
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                color: value == '—'
                    ? const Color(0xFF3A3A3A)
                    : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }

  Widget _bmiCard(double bmi) {
    final color = _bmiColor(bmi);
    final label = _bmiLabel(bmi);
    final ratio = ((bmi - 10) / 30).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.analytics_outlined, color: color, size: 13),
                const SizedBox(width: 5),
                const Text('BMI',
                    style: TextStyle(
                        color: Color(0xFF888888), fontSize: 11)),
              ]),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(bmi.toStringAsFixed(1),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E1E1E),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('低体重',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 9)),
              Text('標準',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 9)),
              Text('肥満',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 1: 推移グラフ
// ══════════════════════════════════════════════════════════════════════════════
class _TrendGraphTab extends StatefulWidget {
  const _TrendGraphTab();

  @override
  State<_TrendGraphTab> createState() => _TrendGraphTabState();
}

class _TrendGraphTabState extends State<_TrendGraphTab> {
  // 0=体重, 1=体脂肪率, 2=BMI
  int _selectedMetric = 0;

  static const _metrics = ['体重', '体脂肪率', 'BMI'];
  static const _units   = ['kg', '%', ''];
  static const _colors  = [
    Color(0xFFFF6B35),
    Color(0xFF6BCB77),
    Color(0xFF45B7D1),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final List<BodyInfo> data;
    switch (_selectedMetric) {
      case 1:  data = provider.bodyFatHistory; break;
      case 2:  data = provider.bmiHistory;     break;
      default: data = provider.weightHistory;  break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // メトリクス選択タブ
          Row(
            children: List.generate(_metrics.length, (i) {
              final isSelected = _selectedMetric == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMetric = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _colors[i].withValues(alpha: 0.15)
                          : const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? _colors[i]
                            : const Color(0xFF2A2A2A),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      _metrics[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? _colors[i]
                            : const Color(0xFF555555),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // グラフ or 空状態
          if (data.length < 2)
            _notEnoughData()
          else ...[
            _buildLineChart(data, _selectedMetric),
            const SizedBox(height: 20),
            // 統計サマリー
            _buildStats(data, _selectedMetric),
          ],
        ],
      ),
    );
  }

  Widget _notEnoughData() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: const Column(
        children: [
          Icon(Icons.show_chart, color: Color(0xFF2A2A2A), size: 48),
          SizedBox(height: 12),
          Text('グラフを表示するには\n2件以上のデータが必要です',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
          SizedBox(height: 8),
          Text('手動入力またはHealthKitで\nデータを追加してください',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF3A3A3A), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<BodyInfo> data, int metric) {
    final values = data.map((b) {
      switch (metric) {
        case 1:  return b.bodyFat!;
        case 2:  return b.bmi!;
        default: return b.weight!;
      }
    }).toList();

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range  = (maxVal - minVal).abs();
    final color  = _colors[metric];

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          // グラフ本体
          Expanded(
            child: CustomPaint(
              painter: _LinePainter(
                values: values,
                dates:  data.map((b) => b.date).toList(),
                color:  color,
                minVal: minVal - (range * 0.1).clamp(0.5, 5.0),
                maxVal: maxVal + (range * 0.1).clamp(0.5, 5.0),
                unit:   _units[metric],
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 6),
          // X軸ラベル（最大5点）
          _buildXLabels(data),
        ],
      ),
    );
  }

  Widget _buildXLabels(List<BodyInfo> data) {
    final count = data.length;
    final step  = (count / 5).ceil().clamp(1, count);
    final indices = <int>[];
    for (int i = 0; i < count; i += step) { indices.add(i); }
    if (!indices.contains(count - 1)) indices.add(count - 1);

    return Row(
      children: List.generate(indices.length, (j) {
        final idx = indices[j];
        final isLast = j == indices.length - 1;
        final label =
            '${data[idx].date.month}/${data[idx].date.day}';
        return Expanded(
          child: Text(
            label,
            textAlign: isLast ? TextAlign.end : TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF444444), fontSize: 9),
          ),
        );
      }),
    );
  }

  Widget _buildStats(List<BodyInfo> data, int metric) {
    final values = data.map((b) {
      switch (metric) {
        case 1:  return b.bodyFat!;
        case 2:  return b.bmi!;
        default: return b.weight!;
      }
    }).toList();

    final latest = values.last;
    final first  = values.first;
    final diff   = latest - first;
    final color  = _colors[metric];
    final unit   = _units[metric];

    return Row(children: [
      Expanded(child: _miniStat(
        label: '最新',
        value: latest.toStringAsFixed(1),
        unit: unit,
        color: color,
      )),
      const SizedBox(width: 8),
      Expanded(child: _miniStat(
        label: '変化',
        value: '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
        unit: unit,
        color: diff < 0 ? const Color(0xFF6BCB77) : const Color(0xFFFF6B6B),
      )),
      const SizedBox(width: 8),
      Expanded(child: _miniStat(
        label: '記録数',
        value: data.length.toString(),
        unit: '件',
        color: const Color(0xFF888888),
      )),
    ]);
  }

  Widget _miniStat({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF666666), fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 折れ線グラフ CustomPainter ─────────────────────────────────────────────
class _LinePainter extends CustomPainter {
  final List<double> values;
  final List<DateTime> dates;
  final Color color;
  final double minVal;
  final double maxVal;
  final String unit;

  _LinePainter({
    required this.values,
    required this.dates,
    required this.color,
    required this.minVal,
    required this.maxVal,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final range = (maxVal - minVal).abs();
    if (range == 0) return;

    final w = size.width;
    final h = size.height;

    // グリッド線（横3本）
    final gridPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = h * i / 3;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Y軸ラベル
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 3; i++) {
      final v = maxVal - (range * i / 3);
      tp.text = TextSpan(
        text: v.toStringAsFixed(1),
        style: const TextStyle(color: Color(0xFF444444), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, h * i / 3 + 2));
    }

    // データポイントの座標計算
    List<Offset> pts = [];
    for (int i = 0; i < values.length; i++) {
      final x = w * i / (values.length - 1);
      final y = h - h * (values[i] - minVal) / range;
      pts.add(Offset(x, y));
    }

    // グラデーション塗りつぶし（エリア）
    final path = Path()..moveTo(pts.first.dx, h);
    for (final p in pts) { path.lineTo(p.dx, p.dy); }
    path.lineTo(pts.last.dx, h);
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.25),
        color.withValues(alpha: 0.02),
      ],
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );

    // 折れ線
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      // ベジェ曲線でなめらかに
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // 最新ポイント強調
    final last = pts.last;
    canvas.drawCircle(
        last,
        5,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        last,
        8,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill);

    // 最新値ラベル
    tp.text = TextSpan(
      text: '${values.last.toStringAsFixed(1)}$unit',
      style: TextStyle(
          color: color, fontSize: 10, fontWeight: FontWeight.bold),
    );
    tp.layout();
    final labelX = (last.dx + tp.width + 4 > w)
        ? last.dx - tp.width - 4
        : last.dx + 6;
    final labelY = (last.dy - tp.height - 4 < 0) ? last.dy + 4 : last.dy - tp.height - 4;
    tp.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.color != color;
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 2: 履歴一覧
// ══════════════════════════════════════════════════════════════════════════════
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final history  = provider.bodyInfoHistory;

    if (history.isEmpty) {
      return const Center(
        child: Text('履歴がありません',
            style: TextStyle(color: Color(0xFF555555), fontSize: 14)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: history.length,
      itemBuilder: (context, i) {
        final info = history[i];
        return _historyTile(context, info, provider);
      },
    );
  }

  Widget _historyTile(
      BuildContext context, BodyInfo info, WorkoutProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付 + ソースバッジ + 削除
          Row(
            children: [
              Text(_fmt(info.date),
                  style: const TextStyle(
                      color: Color(0xFFAFAFAF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              _sourceBadge(info.source),
              const Spacer(),
              GestureDetector(
                onTap: () => _confirmDelete(context, info, provider),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFF444444), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // データチップ群
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (info.weight != null)
                _chip('体重', '${info.weight!.toStringAsFixed(1)} kg',
                    const Color(0xFFFF6B35)),
              if (info.bodyFat != null)
                _chip('体脂肪', '${info.bodyFat!.toStringAsFixed(1)} %',
                    const Color(0xFF6BCB77)),
              if (info.bmi != null)
                _chip('BMI', info.bmi!.toStringAsFixed(1),
                    const Color(0xFF45B7D1)),
              if (info.muscleMass != null)
                _chip('筋肉量',
                    '${info.muscleMass!.toStringAsFixed(1)} kg',
                    const Color(0xFFBF5FFF)),
              if (info.height != null)
                _chip('身長',
                    '${info.height!.toStringAsFixed(1)} cm',
                    const Color(0xFFFFD93D)),
            ],
          ),
          if (info.notes != null && info.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(info.notes!,
                style: const TextStyle(
                    color: Color(0xFF666666), fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                  color: Color(0xFF888888), fontSize: 10),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext ctx, BodyInfo info, WorkoutProvider provider) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('このデータを削除しますか？',
            style: TextStyle(color: Colors.white, fontSize: 15)),
        content: Text(
          '${_fmt(info.date)} のデータを削除します。',
          style: const TextStyle(
              color: Color(0xFFAFAFAF), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('キャンセル',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBodyInfo(info.id);
              Navigator.pop(dCtx);
            },
            child: const Text('削除',
                style: TextStyle(
                    color: Color(0xFFFF4444),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 手動入力 BottomSheet
// ══════════════════════════════════════════════════════════════════════════════
class _ManualEntrySheet extends StatefulWidget {
  final WorkoutProvider provider;
  final BodyInfo?       prefill;

  const _ManualEntrySheet({required this.provider, this.prefill});

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  final _uuid    = const Uuid();
  final _formKey = GlobalKey<FormState>();

  final _ageCtrl    = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _fatCtrl    = TextEditingController();
  final _muscleCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();

  String _gender       = 'male';
  bool   _genderLocked = false;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill ?? widget.provider.latestBodyInfo;
    if (p != null) {
      _gender       = p.gender ?? 'male';
      _genderLocked = p.gender != null;
      _ageCtrl.text    = p.age        != null ? p.age.toString()                    : '';
      _heightCtrl.text = p.height     != null ? p.height!.toStringAsFixed(1)        : '';
      _weightCtrl.text = p.weight     != null ? p.weight!.toStringAsFixed(1)        : '';
      _fatCtrl.text    = p.bodyFat    != null ? p.bodyFat!.toStringAsFixed(1)       : '';
      _muscleCtrl.text = p.muscleMass != null ? p.muscleMass!.toStringAsFixed(1)    : '';
    }
  }

  @override
  void dispose() {
    _ageCtrl.dispose(); _heightCtrl.dispose(); _weightCtrl.dispose();
    _fatCtrl.dispose(); _muscleCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final info = BodyInfo(
      id:         _uuid.v4(),
      date:       DateTime.now(),
      gender:     _gender,
      age:        int.tryParse(_ageCtrl.text.trim()),
      height:     double.tryParse(_heightCtrl.text.trim()),
      weight:     double.tryParse(_weightCtrl.text.trim()),
      bodyFat:    double.tryParse(_fatCtrl.text.trim()),
      muscleMass: double.tryParse(_muscleCtrl.text.trim()),
      notes:      _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      source:     BodyInfoSource.manual,
    );

    widget.provider.addBodyInfo(info);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('身体データを保存しました'),
        backgroundColor: const Color(0xFF6BCB77),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ハンドル
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A5C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('手動入力',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),

              // 性別
              _lbl('性別'),
              const SizedBox(height: 8),
              _genderSelector(),
              const SizedBox(height: 16),

              // 年齢
              _lbl('年齢'),
              const SizedBox(height: 6),
              _field(_ageCtrl, '25', '歳', TextInputType.number,
                  validator: (v) {
                if (v == null || v.isEmpty) return null;
                final n = int.tryParse(v);
                if (n == null || n < 1 || n > 120) return '1〜120';
                return null;
              }),
              const SizedBox(height: 16),

              // 身長・体重
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('身長'),
                    const SizedBox(height: 6),
                    _field(_heightCtrl, '170.0', 'cm',
                        const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = double.tryParse(v);
                      if (n == null || n < 50 || n > 300) return '50〜300cm';
                      return null;
                    }),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('体重'),
                    const SizedBox(height: 6),
                    _field(_weightCtrl, '70.0', 'kg',
                        const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = double.tryParse(v);
                      if (n == null || n < 20 || n > 300) return '20〜300kg';
                      return null;
                    }),
                  ],
                )),
              ]),
              const SizedBox(height: 16),

              // 体脂肪・筋肉量
              const Divider(color: Color(0xFF2A2A2A), height: 24),
              _lbl('詳細データ（オプション）'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLbl('体脂肪率'),
                    const SizedBox(height: 6),
                    _field(_fatCtrl, '15.0', '%',
                        const TextInputType.numberWithOptions(decimal: true)),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLbl('筋肉量'),
                    const SizedBox(height: 6),
                    _field(_muscleCtrl, '55.0', 'kg',
                        const TextInputType.numberWithOptions(decimal: true)),
                  ],
                )),
              ]),
              const SizedBox(height: 16),
              _lbl('メモ（任意）'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                decoration: _inputDeco('体調など'),
              ),
              const SizedBox(height: 24),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('保存する',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    const opts = [
      ('male', '男性', Icons.male),
      ('female', '女性', Icons.female),
      ('other', 'その他', Icons.person_outline),
    ];
    return Row(
      children: opts.map((opt) {
        final sel = _gender == opt.$1;
        const activeC = Color(0xFFFF6B35);
        const lockC   = Color(0xFF4ECDC4);
        final c = sel ? (_genderLocked ? lockC : activeC)
                      : const Color(0xFF2A2A2A);
        return Expanded(
          child: GestureDetector(
            onTap: _genderLocked
                ? _showLockDialog
                : () => setState(() => _gender = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? (_genderLocked
                        ? lockC.withValues(alpha: 0.15)
                        : activeC.withValues(alpha: 0.15))
                    : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel ? c : const Color(0xFF2A2A2A),
                    width: sel ? 1.5 : 1),
              ),
              child: Column(children: [
                Icon(opt.$3,
                    color: sel ? c : const Color(0xFF444444), size: 20),
                const SizedBox(height: 3),
                Text(opt.$2,
                    style: TextStyle(
                        color: sel ? c : const Color(0xFF666666),
                        fontSize: 11,
                        fontWeight: sel
                            ? FontWeight.w700
                            : FontWeight.normal)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.lock, color: Color(0xFF4ECDC4), size: 18),
          SizedBox(width: 8),
          Text('性別は変更できません',
              style: TextStyle(color: Colors.white, fontSize: 15)),
        ]),
        content: const Text('性別は最初の登録後は変更できません。',
            style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('わかりました',
                style: TextStyle(color: Color(0xFF4ECDC4))),
          ),
        ],
      ),
    );
  }

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700));

  Widget _subLbl(String t) => Text(t,
      style: const TextStyle(color: Color(0xFF888888), fontSize: 11));

  Widget _field(
    TextEditingController ctrl,
    String hint,
    String suffix,
    TextInputType kbType, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: kbType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _inputDeco(hint).copyWith(
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Color(0xFF666666), fontSize: 13),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF333333)),
    filled: true,
    fillColor: const Color(0xFF1A1A2E),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF4444))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// HealthKit XML インポート BottomSheet
// ══════════════════════════════════════════════════════════════════════════════
class _HealthKitImportSheet extends StatefulWidget {
  final WorkoutProvider provider;
  const _HealthKitImportSheet({required this.provider});

  @override
  State<_HealthKitImportSheet> createState() => _HealthKitImportSheetState();
}

class _HealthKitImportSheetState extends State<_HealthKitImportSheet> {
  final _xmlCtrl    = TextEditingController();
  bool  _processing = false;
  String? _result;
  bool    _isError  = false;

  // 抽出プレビュー
  List<Map<String, String>> _preview = [];

  @override
  void dispose() {
    _xmlCtrl.dispose();
    super.dispose();
  }

  // ── XMLをパースして BodyInfo リストに変換 ──────────────────────────────
  List<BodyInfo> _parseHealthXml(String xml) {
    final uuid = const Uuid();
    final Map<DateTime, Map<String, double>> dayMap = {};

    // HKQuantityTypeIdentifierBodyMass (体重: kg)
    final weightRe = RegExp(
      r'<Record[^>]+type="HKQuantityTypeIdentifierBodyMass"[^>]+'
      r'creationDate="([^"]+)"[^>]+value="([^"]+)"[^>]*/?>',
      dotAll: true,
    );
    for (final m in weightRe.allMatches(xml)) {
      final dt  = _parseDate(m.group(1));
      final val = double.tryParse(m.group(2) ?? '');
      if (dt != null && val != null) {
        final d = DateTime(dt.year, dt.month, dt.day);
        dayMap[d] ??= {};
        // 同日複数レコードは最新を保持
        dayMap[d]!['weight'] = val;
      }
    }

    // HKQuantityTypeIdentifierBodyFatPercentage (体脂肪: 0〜1)
    final fatRe = RegExp(
      r'<Record[^>]+type="HKQuantityTypeIdentifierBodyFatPercentage"[^>]+'
      r'creationDate="([^"]+)"[^>]+value="([^"]+)"[^>]*/?>',
      dotAll: true,
    );
    for (final m in fatRe.allMatches(xml)) {
      final dt  = _parseDate(m.group(1));
      final val = double.tryParse(m.group(2) ?? '');
      if (dt != null && val != null) {
        final d = DateTime(dt.year, dt.month, dt.day);
        dayMap[d] ??= {};
        dayMap[d]!['bodyFat'] = val * 100; // 0〜1 → 0〜100%
      }
    }

    // HKQuantityTypeIdentifierHeight (身長: m)
    final heightRe = RegExp(
      r'<Record[^>]+type="HKQuantityTypeIdentifierHeight"[^>]+'
      r'creationDate="([^"]+)"[^>]+value="([^"]+)"[^>]*/?>',
      dotAll: true,
    );
    double? latestHeight;
    for (final m in heightRe.allMatches(xml)) {
      final val = double.tryParse(m.group(2) ?? '');
      if (val != null) latestHeight = val * 100; // m → cm
    }

    // HKQuantityTypeIdentifierLeanBodyMass (除脂肪体重/筋肉量: kg)
    final leanRe = RegExp(
      r'<Record[^>]+type="HKQuantityTypeIdentifierLeanBodyMass"[^>]+'
      r'creationDate="([^"]+)"[^>]+value="([^"]+)"[^>]*/?>',
      dotAll: true,
    );
    for (final m in leanRe.allMatches(xml)) {
      final dt  = _parseDate(m.group(1));
      final val = double.tryParse(m.group(2) ?? '');
      if (dt != null && val != null) {
        final d = DateTime(dt.year, dt.month, dt.day);
        dayMap[d] ??= {};
        dayMap[d]!['muscleMass'] = val;
      }
    }

    // BodyInfo リストへ変換
    final result = <BodyInfo>[];
    for (final entry in dayMap.entries) {
      final d   = entry.key;
      final val = entry.value;
      result.add(BodyInfo(
        id:         uuid.v4(),
        date:       d,
        weight:     val['weight'],
        bodyFat:    val['bodyFat'],
        muscleMass: val['muscleMass'],
        height:     latestHeight,
        source:     BodyInfoSource.healthKit,
      ));
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  DateTime? _parseDate(String? s) {
    if (s == null) return null;
    // 例: "2024-03-15 08:23:11 +0900"
    try {
      return DateTime.parse(s.replaceFirst(' ', 'T').split(' ').first);
    } catch (_) {
      return null;
    }
  }

  // ── プレビュー生成 ─────────────────────────────────────────────────────
  void _buildPreview(String xml) {
    try {
      final items = _parseHealthXml(xml);
      if (items.isEmpty) {
        setState(() {
          _preview = [];
          _result  = '体重・体脂肪・身長のデータが見つかりませんでした。\nエクスポートXMLの内容を確認してください。';
          _isError = true;
        });
        return;
      }
      setState(() {
        _preview = items.take(5).map((b) => {
          '日付': _fmt(b.date),
          '体重': b.weight != null
              ? '${b.weight!.toStringAsFixed(1)} kg' : '—',
          '体脂肪': b.bodyFat != null
              ? '${b.bodyFat!.toStringAsFixed(1)} %' : '—',
        }).toList();
        _result  = '${items.length}件のデータを検出しました（上位5件プレビュー）';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _preview = [];
        _result  = 'パースエラー: XMLの形式を確認してください。';
        _isError = true;
      });
    }
  }

  // ── インポート実行 ────────────────────────────────────────────────────
  Future<void> _doImport() async {
    final xml = _xmlCtrl.text.trim();
    if (xml.isEmpty) {
      setState(() {
        _result  = 'XMLを貼り付けてください。';
        _isError = true;
      });
      return;
    }

    setState(() => _processing = true);

    try {
      final items = _parseHealthXml(xml);
      if (items.isEmpty) {
        setState(() {
          _result  = '有効なデータが見つかりませんでした。';
          _isError = true;
        });
        return;
      }
      final added = await widget.provider.importBodyInfoBatch(items);
      setState(() {
        _result  = '$added件の新規データをインポートしました。';
        _isError = false;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A5C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // タイトル
            Row(children: [
              const Icon(Icons.ios_share,
                  color: Color(0xFF4ECDC4), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('HealthKitデータ取込み',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
              ),
            ]),
            const SizedBox(height: 20),

            // 手順説明カード
            _instructionCard(),
            const SizedBox(height: 20),

            // XML入力
            const Text('XMLデータを貼り付け',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _xmlCtrl,
              maxLines: 8,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText:
                    '<?xml version="1.0" ...\n<HealthData ...',
                hintStyle: const TextStyle(
                    color: Color(0xFF333333), fontSize: 11),
                filled: true,
                fillColor: const Color(0xFF0A0A15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF2A2A3A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF2A2A3A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF4ECDC4), width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: _xmlCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Color(0xFF555555), size: 16),
                        onPressed: () => setState(() {
                          _xmlCtrl.clear();
                          _preview = [];
                          _result  = null;
                        }),
                      )
                    : null,
              ),
              onChanged: (v) {
                if (v.length > 200) _buildPreview(v);
              },
            ),
            const SizedBox(height: 12),

            // プレビュー
            if (_preview.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('プレビュー（上位5件）',
                        style: TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ..._preview.map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        SizedBox(
                          width: 80,
                          child: Text(row['日付']!,
                              style: const TextStyle(
                                  color: Color(0xFF888888), fontSize: 11)),
                        ),
                        Text('体重: ${row['体重']}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                        const SizedBox(width: 10),
                        Text('体脂肪: ${row['体脂肪']}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ]),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 結果メッセージ
            if (_result != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isError
                      ? const Color(0xFFFF4444).withValues(alpha: 0.08)
                      : const Color(0xFF6BCB77).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isError
                        ? const Color(0xFFFF4444).withValues(alpha: 0.3)
                        : const Color(0xFF6BCB77).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _result!,
                  style: TextStyle(
                    color: _isError
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF6BCB77),
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // インポートボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processing ? null : _doImport,
                icon: _processing
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(_processing ? '処理中...' : 'データをインポート'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _instructionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline, color: Color(0xFF4ECDC4), size: 14),
            SizedBox(width: 6),
            Text('エクスポート手順',
                style: TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          ..._steps([
            'iPhoneの「ヘルスケア」アプリを開く',
            '右上のプロフィールアイコンをタップ',
            '「すべてのヘルスケアデータを書き出す」を選択',
            'ZIP を解凍 → export.xml の中身をコピー',
            '上のテキストエリアに貼り付けて「インポート」',
          ]),
          const SizedBox(height: 8),
          const Text(
            '取込対象: 体重・体脂肪率・身長・除脂肪体重',
            style: TextStyle(
                color: Color(0xFF555555), fontSize: 10),
          ),
        ],
      ),
    );
  }

  List<Widget> _steps(List<String> items) {
    return items.asMap().entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18, height: 18,
            margin: const EdgeInsets.only(right: 8, top: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${e.key + 1}',
                  style: const TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          Expanded(
            child: Text(e.value,
                style: const TextStyle(
                    color: Color(0xFFAFAFAF), fontSize: 11)),
          ),
        ],
      ),
    )).toList();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 共通ヘルパー関数
// ══════════════════════════════════════════════════════════════════════════════
String _fmt(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

String _genderLabel(String g) {
  switch (g) {
    case 'male':   return '男性';
    case 'female': return '女性';
    default:       return 'その他';
  }
}

Widget _sourceBadge(BodyInfoSource src) {
  final isHK = src == BodyInfoSource.healthKit;
  final color = isHK ? const Color(0xFF4ECDC4) : const Color(0xFF888888);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isHK ? Icons.favorite : Icons.edit,
          color: color, size: 9,
        ),
        const SizedBox(width: 3),
        Text(
          src.label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

Color _bmiColor(double bmi) {
  if (bmi < 18.5) return const Color(0xFF45B7D1);
  if (bmi < 25.0) return const Color(0xFF6BCB77);
  if (bmi < 30.0) return const Color(0xFFFFD93D);
  return const Color(0xFFFF3D3D);
}

String _bmiLabel(double bmi) {
  if (bmi < 18.5) return '低体重';
  if (bmi < 25.0) return '標準';
  if (bmi < 30.0) return '過体重';
  return '肥満';
}
