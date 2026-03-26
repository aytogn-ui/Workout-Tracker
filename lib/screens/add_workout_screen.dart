import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/exercise_definition.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _uuid = const Uuid();
  int _step = 0; // 0: 部位選択, 1: 種目選択, 2: セット入力

  String? _selectedBodyPart;
  ExerciseDefinition? _selectedExercise;
  final List<ExerciseSet> _sets = [];

  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  static const _bodyParts = ['胸', '肩', '腕', '背中', 'お腹', '足', '有酸素'];

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _stepTitle(),
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0: return '部位を選ぶ';
      case 1: return '種目を選ぶ';
      case 2: return 'セットを入力';
      default: return '';
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)])
                          : null,
                      color: isActive ? null : const Color(0xFF3A3A5C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0: return _buildBodyPartStep();
      case 1: return _buildExerciseStep();
      case 2: return _buildSetStep();
      default: return const SizedBox();
    }
  }

  // ── Step 0: 部位選択 ─────────────────────────────────────
  Widget _buildBodyPartStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: _bodyParts.map((part) {
          return GestureDetector(
            onTap: () => setState(() {
              _selectedBodyPart = part;
              _step = 1;
            }),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _bodyPartColor(part).withValues(alpha: 0.3),
                    _bodyPartColor(part).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _bodyPartColor(part).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_bodyPartIcon(part),
                      color: _bodyPartColor(part), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    part,
                    style: TextStyle(
                      color: _bodyPartColor(part),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Step 1: 種目選択 ─────────────────────────────────────
  Widget _buildExerciseStep() {
    final provider = context.read<WorkoutProvider>();
    final exercises = provider.getExercisesByBodyPart(_selectedBodyPart!);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, i) {
        final ex = exercises[i];
        return GestureDetector(
          onTap: () => setState(() {
            _selectedExercise = ex;
            _sets.clear();
            _step = 2;
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
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
                    color: _bodyPartColor(_selectedBodyPart!)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _bodyPartIcon(_selectedBodyPart!),
                    color: _bodyPartColor(_selectedBodyPart!),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ex.isBodyWeight || ex.isTimeBased)
                        Row(
                          children: [
                            if (ex.isBodyWeight)
                              _buildBadge('自重', const Color(0xFF4ECDC4)),
                            if (ex.isTimeBased)
                              _buildBadge('時間', const Color(0xFFFFD93D)),
                          ],
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF3A3A5C), size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 4, right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Step 2: セット入力 ────────────────────────────────────
  Widget _buildSetStep() {
    final ex = _selectedExercise!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 種目ヘッダー
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _bodyPartColor(ex.bodyPart).withValues(alpha: 0.3),
                  _bodyPartColor(ex.bodyPart).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _bodyPartColor(ex.bodyPart).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(_bodyPartIcon(ex.bodyPart),
                    color: _bodyPartColor(ex.bodyPart), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ex.bodyPart,
                        style: TextStyle(
                          color: _bodyPartColor(ex.bodyPart),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 入力フォーム
          if (ex.isTimeBased)
            _buildTimeInput()
          else
            _buildWeightRepsInput(ex),
          const SizedBox(height: 12),

          // セット追加ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('セットを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // セット一覧
          if (_sets.isNotEmpty) ...[
            const Text(
              '記録済みセット',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._sets.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3A3A5C)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${s.setNumber}',
                          style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ex.isTimeBased
                            ? '${s.timeSeconds}秒'
                            : '${s.weight}kg × ${s.reps}回',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0xFF3A3A5C), size: 16),
                      onPressed: () =>
                          setState(() => _sets.removeAt(i)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // 保存ボタン
          if (_sets.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'ワークアウトを保存',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWeightRepsInput(ExerciseDefinition ex) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ex.isBodyWeight ? '追加重量 (kg)' : '重量 (kg)',
                style: const TextStyle(
                    color: Color(0xFFAFAFAF), fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: _inputDecoration('0.0'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '回数',
                style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: _inputDecoration('0'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '時間 (秒)',
          style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _timeCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: _inputDecoration('60'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF3A3A5C)),
      filled: true,
      fillColor: const Color(0xFF2C2C3E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  void _addSet() {
    final ex = _selectedExercise!;
    if (ex.isTimeBased) {
      final time = int.tryParse(_timeCtrl.text.trim());
      if (time == null || time <= 0) {
        _showError('時間を入力してください');
        return;
      }
      setState(() {
        _sets.add(ExerciseSet(
          id: _uuid.v4(),
          setNumber: _sets.length + 1,
          weight: 0,
          reps: 0,
          timeSeconds: time,
        ));
        _timeCtrl.clear();
      });
    } else {
      final weight =
          double.tryParse(_weightCtrl.text.trim()) ?? 0.0;
      final reps = int.tryParse(_repsCtrl.text.trim());
      if (reps == null || reps <= 0) {
        _showError('回数を入力してください');
        return;
      }
      setState(() {
        _sets.add(ExerciseSet(
          id: _uuid.v4(),
          setNumber: _sets.length + 1,
          weight: weight,
          reps: reps,
        ));
        _weightCtrl.clear();
        _repsCtrl.clear();
      });
    }
  }

  void _saveWorkout() {
    if (_sets.isEmpty) return;
    final provider = context.read<WorkoutProvider>();
    final ex = _selectedExercise!;

    final exercise = Exercise(
      id: _uuid.v4(),
      exerciseId: ex.id,
      name: ex.name,
      bodyPart: ex.bodyPart,
      sets: List.from(_sets),
      isTimeBased: ex.isTimeBased,
      isBodyWeight: ex.isBodyWeight,
      bodyWeightRatio: ex.bodyWeightRatio,
    );

    provider.addExerciseToDate(provider.selectedDate, exercise);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ex.name} を保存しました'),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}
