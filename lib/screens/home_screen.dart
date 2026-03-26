import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/calendar_widget.dart';
import 'add_workout_screen.dart';
import 'analysis_screen.dart';
import 'tools_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
            : _buildBody(context, provider),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'Workout Tracker',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.white70),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalysisScreen()),
          ),
          tooltip: '分析',
        ),
        IconButton(
          icon: const Icon(Icons.build_outlined, color: Colors.white70),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ToolsScreen()),
          ),
          tooltip: 'ツール',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WorkoutProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計カード
          _buildStatsRow(provider),
          const SizedBox(height: 16),
          // カレンダー
          const CalendarWidget(),
          const SizedBox(height: 16),
          // 選択日のワークアウト
          _buildSelectedDateSection(context, provider),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WorkoutProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            label: '今月のトレーニング',
            value: '${provider.thisMonthWorkoutCount}日',
            gradient: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
            accentColor: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.monitor_weight_outlined,
            label: '今月の合計重量',
            value: provider.thisMonthTotalVolume >= 1000
                ? '${(provider.thisMonthTotalVolume / 1000).toStringAsFixed(1)}t'
                : '${provider.thisMonthTotalVolume.toStringAsFixed(0)}kg',
            gradient: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
            accentColor: const Color(0xFFFF6B35),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A5C), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAFAFAF),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateSection(
      BuildContext context, WorkoutProvider provider) {
    final workout = provider.selectedDateWorkout;
    final selectedDate = provider.selectedDate;
    final isToday = _isSameDay(selectedDate, DateTime.now());
    final dateLabel = isToday
        ? '今日'
        : DateFormat('M月d日(E)', 'ja').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dateLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            if (workout != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${workout.exercises.length}種目',
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (workout == null)
          _buildEmptyState(context)
        else
          _buildWorkoutList(context, provider, workout),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF3A3A5C).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center,
              color: Color(0xFF3A3A5C), size: 40),
          const SizedBox(height: 12),
          const Text(
            'この日のトレーニングなし',
            style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _openAddWorkout(context),
            icon: const Icon(Icons.add, color: Color(0xFFFF6B35), size: 16),
            label: const Text('トレーニングを追加',
                style: TextStyle(color: Color(0xFFFF6B35))),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(
      BuildContext context, WorkoutProvider provider, workout) {
    return Column(
      children: [
        ...workout.exercises.map((exercise) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3A3A5C)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _bodyPartColor(exercise.bodyPart).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _bodyPartIcon(exercise.bodyPart),
                      color: _bodyPartColor(exercise.bodyPart),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${exercise.sets.length}セット'
                          ' • ${exercise.bodyPart}'
                          '${exercise.totalVolume > 0 ? ' • ${exercise.totalVolume.toStringAsFixed(0)}kg' : ''}',
                          style: const TextStyle(
                            color: Color(0xFFAFAFAF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFF3A3A5C), size: 18),
                    onPressed: () =>
                        _confirmDelete(context, provider, workout.id, exercise.id),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openAddWorkout(context),
            icon: const Icon(Icons.add, color: Color(0xFFFF6B35), size: 16),
            label: const Text('種目を追加',
                style: TextStyle(color: Color(0xFFFF6B35))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                  color: Color(0xFFFF6B35), width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _openAddWorkout(BuildContext context) {
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
        backgroundColor: const Color(0xFF1C1C2E),
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
                style: TextStyle(color: Color(0xFFFF6B35))),
          ),
        ],
      ),
    );
  }

  Color _bodyPartColor(String bodyPart) {
    switch (bodyPart) {
      case '胸': return const Color(0xFFFF6B35);
      case '肩': return const Color(0xFF4ECDC4);
      case '腕': return const Color(0xFF45B7D1);
      case '背中': return const Color(0xFFFFD93D);
      case 'お腹': return const Color(0xFF6BCB77);
      case '足': return const Color(0xFFFF6B6B);
      case '有酸素': return const Color(0xFFDA77FF);
      default: return const Color(0xFFAFAFAF);
    }
  }

  IconData _bodyPartIcon(String bodyPart) {
    switch (bodyPart) {
      case '胸': return Icons.fitness_center;
      case '肩': return Icons.accessibility_new;
      case '腕': return Icons.sports_handball;
      case '背中': return Icons.airline_seat_flat;
      case 'お腹': return Icons.circle_outlined;
      case '足': return Icons.directions_walk;
      case '有酸素': return Icons.directions_run;
      default: return Icons.sports_gymnastics;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openAddWorkout(context),
      backgroundColor: const Color(0xFFFF6B35),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
