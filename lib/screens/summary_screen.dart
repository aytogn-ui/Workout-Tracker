import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/neon_body_map.dart';
import 'add_workout_screen.dart';

// ── 部位カラー定義（ネオン）──────────────────────────────────
const Map<String, Color> kPartColor = {
  '胸':    Color(0xFF00CFFF),   // シアン
  '肩':    Color(0xFFFF8C00),   // オレンジ
  '腕':    Color(0xFFFFE600),   // イエロー
  '背中':  Color(0xFFBF5FFF),   // パープル
  'お腹':  Color(0xFF00E676),   // グリーン
  '足':    Color(0xFFFF3D3D),   // レッド
  '有酸素': Color(0xFFFF6B35),  // ネオンオレンジ
};

const List<String> kOrderedParts = ['胸', '肩', '腕', '背中', 'お腹', '足'];

/// ホームタブ – "TRAINING SUMMARY" スタイル
/// 左: ネオン発光人体マップ  右: 部位別カード（ネオンボーダー + 達成率バー）
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

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
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy/MM/dd HH:mm', 'ja').format(now);

    // 強度マップ（0〜1）
    final volMap = provider.recentBodyPartVolume;
    final maxVol = volMap.values.fold(0.0, (a, b) => a > b ? a : b);
    final intensityMap = <String, double>{};
    for (final e in volMap.entries) {
      intensityMap[e.key] = maxVol > 0 ? (e.value / maxVol).clamp(0.0, 1.0) : 0.0;
    }

    // 直近ワークアウト（サマリー用）
    final workout = provider.selectedDateWorkout
        ?? (provider.workouts.isNotEmpty ? provider.workouts.last : null);
    final byPart = <String, List<dynamic>>{};
    for (final ex in workout?.exercises ?? []) {
      byPart.putIfAbsent(ex.bodyPart, () => []).add(ex);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, provider, dateStr)),
        SliverToBoxAdapter(child: _buildMainContent(context, provider, intensityMap, volMap, maxVol, byPart)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ── ヘッダー ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, WorkoutProvider provider, String dateStr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // 日付・ステータス
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                ),
                const SizedBox(height: 2),
                const Text(
                  'TRAINING SUMMARY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // アバター
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.notifications_outlined, color: Color(0xFF777777), size: 22),
        ],
      ),
    );
  }

  // ── メインコンテンツ（人体マップ + 部位カード）────────────
  Widget _buildMainContent(
    BuildContext context,
    WorkoutProvider provider,
    Map<String, double> intensityMap,
    Map<String, double> volMap,
    double maxVol,
    Map<String, List<dynamic>> byPart,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 左: 人体マップ（〜40%幅）──────────────────────
          SizedBox(
            width: 148,
            child: Column(
              children: [
                NeonBodyMap(
                  intensity: intensityMap,
                  onTap: (part) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ── 右: 部位カードリスト（〜55%幅）───────────────
          Expanded(
            child: Column(
              children: [
                ...kOrderedParts.map((part) {
                  final exList = byPart[part] ?? [];
                  final vol = volMap[part] ?? 0;
                  final ratio = maxVol > 0 ? (vol / maxVol).clamp(0.0, 1.0) : 0.0;
                  return _NeonPartCard(
                    part: part,
                    exercises: exList,
                    ratio: ratio,
                    vol: vol,
                    onHistoryTap: () {},
                    onAddTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ネオン発光部位カード ────────────────────────────────────
class _NeonPartCard extends StatelessWidget {
  final String part;
  final List<dynamic> exercises;
  final double ratio;
  final double vol;
  final VoidCallback onHistoryTap;
  final VoidCallback onAddTap;

  const _NeonPartCard({
    required this.part,
    required this.exercises,
    required this.ratio,
    required this.vol,
    required this.onHistoryTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = kPartColor[part] ?? const Color(0xFFFF6B35);
    final hasData = exercises.isNotEmpty;
    final latestEx = hasData ? exercises.first : null;
    final setCount = latestEx?.sets.length ?? 0;
    final lastSet = (latestEx?.sets.isNotEmpty == true) ? latestEx!.sets.last : null;

    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: hasData ? 0.7 : 0.25),
            width: hasData ? 1.5 : 1.0,
          ),
          boxShadow: hasData
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル行
              Row(
                children: [
                  // アイコン
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: hasData ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: color.withValues(alpha: hasData ? 0.5 : 0.2),
                      ),
                    ),
                    child: Icon(_partIcon(part), color: color, size: 13),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      part,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // 履歴ボタン
                  GestureDetector(
                    onTap: onHistoryTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '履歴',
                        style: TextStyle(color: color, fontSize: 9),
                      ),
                    ),
                  ),
                ],
              ),

              // 種目名・セット情報
              if (hasData && latestEx != null) ...[
                const SizedBox(height: 3),
                Text(
                  latestEx.name as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lastSet != null)
                  Text(
                    latestEx.isTimeBased
                        ? '$setCount セット  ${lastSet.timeSeconds}秒'
                        : '$setCount セット  ${lastSet.weight}kg×${lastSet.reps}回',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 9,
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 3),
                const Text(
                  '記録なし  タップして追加',
                  style: TextStyle(color: Color(0xFF444444), fontSize: 9),
                ),
              ],

              const SizedBox(height: 6),

              // 達成率バー
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '達成率 ${(ratio * 100).toInt()}%',
                    style: const TextStyle(color: Color(0xFF444444), fontSize: 8),
                  ),
                  if (vol > 0)
                    Text(
                      '${vol.toStringAsFixed(0)}kg',
                      style: TextStyle(color: color, fontSize: 8),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _partIcon(String part) {
    switch (part) {
      case '胸':    return Icons.fitness_center;
      case '肩':    return Icons.accessibility_new;
      case '腕':    return Icons.sports_handball;
      case '背中':  return Icons.airline_seat_flat;
      case 'お腹':  return Icons.circle_outlined;
      case '足':    return Icons.directions_walk;
      case '有酸素': return Icons.directions_run;
      default:      return Icons.sports_gymnastics;
    }
  }
}
