import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/calendar_widget.dart';
import 'add_workout_screen.dart';

/// ホームタブ – カレンダー + 選択日の記録
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
            : _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ヘッダー ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'ホーム',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _statBadge(
                  '今月',
                  '${provider.thisMonthWorkoutCount}日',
                  const Color(0xFFFF6B35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── カレンダー ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const CalendarWidget(),
          ),
          const SizedBox(height: 16),

          // ── 選択日のセクション ─────────────────────────────
          _buildDaySection(context, provider),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _statBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
          const SizedBox(width: 4),
          Text(value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            )),
        ],
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, WorkoutProvider provider) {
    final workout = provider.selectedDateWorkout;
    final selected = provider.selectedDate;
    final isToday = _sameDay(selected, DateTime.now());
    final label = isToday ? '今日' : DateFormat('M月d日(E)', 'ja').format(selected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付ラベル
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              if (workout != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '${workout.exercises.length}種目',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // コンテンツ
          workout == null
              ? _emptyState(context)
              : _workoutList(context, provider, workout),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFF2A2A2A), size: 40),
          const SizedBox(height: 10),
          const Text(
            'この日のトレーニングなし',
            style: TextStyle(color: Color(0xFF555555), fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add, color: Color(0xFFFF6B35), size: 16),
            label: const Text(
              'トレーニングを追加',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workoutList(
      BuildContext context, WorkoutProvider provider, dynamic workout) {
    return Column(
      children: [
        ...workout.exercises.map<Widget>((exercise) {
          final color = _partColor(exercise.bodyPart as String);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Icon(_partIcon(exercise.bodyPart as String),
                      color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(exercise.sets as List).length}セット'
                        ' • ${exercise.bodyPart}'
                        '${(exercise.totalVolume as double) > 0 ? " • ${(exercise.totalVolume as double).toStringAsFixed(0)}kg" : ""}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFF3A3A3A), size: 18),
                  onPressed: () => _confirmDelete(
                      context, provider, workout.id as String, exercise.id as String),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add, color: Color(0xFFFF6B35), size: 16),
            label: const Text(
              '種目を追加',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6B35)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
    );
  }

  void _confirmDelete(BuildContext context, WorkoutProvider provider,
      String workoutId, String exerciseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('削除確認',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('この種目を削除しますか？',
            style: TextStyle(color: Color(0xFFAFAFAF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル',
                style: TextStyle(color: Color(0xFFAFAFAF))),
          ),
          TextButton(
            onPressed: () {
              provider.deleteExercise(workoutId, exerciseId);
              Navigator.pop(ctx);
            },
            child: const Text('削除',
                style: TextStyle(color: Color(0xFFFF3D3D))),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _partColor(String part) {
    switch (part) {
      case '胸':    return const Color(0xFF00CFFF);
      case '肩':    return const Color(0xFFFF8C00);
      case '腕':    return const Color(0xFFFFE600);
      case '背中':  return const Color(0xFFBF5FFF);
      case 'お腹':  return const Color(0xFF00E676);
      case '足':    return const Color(0xFFFF3D3D);
      case '有酸素': return const Color(0xFFFF6B35);
      default:      return const Color(0xFFAFAFAF);
    }
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
