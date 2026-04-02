import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/exercise_definition.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ワークアウト追加画面（3ステップ）
// ══════════════════════════════════════════════════════════════════════════════
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
  final _repsCtrl   = TextEditingController();
  final _timeCtrl   = TextEditingController();

  static const _bodyParts = ['胸', '肩', '腕', '背中', 'お腹', '足', '有酸素', 'その他'];

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
      case 0:  return '部位を選ぶ';
      case 1:  return '種目を選ぶ';
      case 2:  return 'セットを入力';
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
      case 0:  return _buildBodyPartStep();
      case 1:  return _buildExerciseStep();
      case 2:  return _buildSetStep();
      default: return const SizedBox();
    }
  }

  // ── Step 0: 部位選択 ─────────────────────────────────────────────────────
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

  // ── Step 1: 種目選択 ─────────────────────────────────────────────────────
  Widget _buildExerciseStep() {
    final provider  = context.watch<WorkoutProvider>();
    final exercises = provider.getExercisesByBodyPart(_selectedBodyPart!);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: exercises.length,
            itemBuilder: (context, i) {
              final ex = exercises[i];
              return _exerciseTile(ex, provider);
            },
          ),
        ),
        // ── ＋ 種目を追加 ボタン ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: GestureDetector(
            onTap: () => _openExerciseSheet(context, provider, existing: null),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: Color(0xFFFF6B35), size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '種目を追加',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exerciseTile(ExerciseDefinition ex, WorkoutProvider provider) {
    final isCustom = !ex.isDefault;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedExercise = ex;
        _sets.clear();
        _step = 2;
      }),
      onLongPress: isCustom
          ? () => _openExerciseSheet(context, provider, existing: ex)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCustom
              ? const Color(0xFF1A1A2E)
              : const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCustom
                ? _bodyPartColor(_selectedBodyPart!).withValues(alpha: 0.35)
                : const Color(0xFF3A3A5C),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bodyPartColor(_selectedBodyPart!).withValues(alpha: 0.2),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ex.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // カスタム種目バッジ
                      if (isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: const Color(0xFFFF6B35).withValues(alpha: 0.4)),
                          ),
                          child: const Text('カスタム',
                            style: TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            )),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (ex.exerciseType == ExerciseType.bodyWeight)
                        _badge('自重', const Color(0xFF4ECDC4)),
                      if (ex.exerciseType == ExerciseType.cardio)
                        _badge('時間', const Color(0xFFFFD93D)),
                      if (ex.bodyWeightRatio != null)
                        _badge('${(ex.bodyWeightRatio! * 100).toInt()}%',
                            const Color(0xFF4ECDC4)),
                      if (ex.notes != null && ex.notes!.isNotEmpty)
                        _badge('メモ', const Color(0xFF888888)),
                    ],
                  ),
                ],
              ),
            ),
            // カスタム種目は編集アイコン表示
            if (isCustom)
              GestureDetector(
                onTap: () => _openExerciseSheet(context, provider, existing: ex),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.edit_outlined,
                      color: _bodyPartColor(_selectedBodyPart!).withValues(alpha: 0.6),
                      size: 18),
                ),
              )
            else
              const Icon(Icons.chevron_right,
                  color: Color(0xFF3A3A5C), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  // ── 種目追加・編集 BottomSheet を開く ────────────────────────────────────
  Future<void> _openExerciseSheet(
    BuildContext context,
    WorkoutProvider provider, {
    ExerciseDefinition? existing,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseEditSheet(
        provider:        provider,
        existing:        existing,
        defaultBodyPart: _selectedBodyPart ?? '胸',
      ),
    );
    // シート閉じた後に再描画
    if (mounted) setState(() {});
  }

  // ── Step 2: セット入力 ───────────────────────────────────────────────────
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
                      Text(ex.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          )),
                      Text(ex.bodyPart,
                          style: TextStyle(
                            color: _bodyPartColor(ex.bodyPart),
                            fontSize: 12,
                          )),
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
            const Text('記録済みセット',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._sets.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        child: Text('${s.setNumber}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ex.isTimeBased
                            ? '${s.timeSeconds}秒'
                            : '${s.weight}kg × ${s.reps}回',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0xFF3A3A5C), size: 16),
                      onPressed: () => setState(() => _sets.removeAt(i)),
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
                child: const Text('ワークアウトを保存',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
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
                style: const TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
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
              const Text('回数',
                  style:
                      TextStyle(color: Color(0xFFAFAFAF), fontSize: 12)),
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
        const Text('時間 (秒)',
            style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12)),
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
        borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
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
      final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0.0;
      final reps   = int.tryParse(_repsCtrl.text.trim());
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
      id:              _uuid.v4(),
      exerciseId:      ex.id,
      name:            ex.name,
      bodyPart:        ex.bodyPart,
      sets:            List.from(_sets),
      isTimeBased:     ex.isTimeBased,
      isBodyWeight:    ex.isBodyWeight,
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
      case '胸':   return const Color(0xFFFF6B35);
      case '肩':   return const Color(0xFF4ECDC4);
      case '腕':   return const Color(0xFF45B7D1);
      case '背中': return const Color(0xFFFFD93D);
      case 'お腹': return const Color(0xFF6BCB77);
      case '足':   return const Color(0xFFFF6B6B);
      case '有酸素': return const Color(0xFFDA77FF);
      default:    return const Color(0xFFAFAFAF);
    }
  }

  IconData _bodyPartIcon(String bodyPart) {
    switch (bodyPart) {
      case '胸':   return Icons.fitness_center;
      case '肩':   return Icons.accessibility_new;
      case '腕':   return Icons.sports_handball;
      case '背中': return Icons.airline_seat_flat;
      case 'お腹': return Icons.circle_outlined;
      case '足':   return Icons.directions_walk;
      case '有酸素': return Icons.directions_run;
      default:    return Icons.sports_gymnastics;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 種目追加・編集 BottomSheet
// ══════════════════════════════════════════════════════════════════════════════
class _ExerciseEditSheet extends StatefulWidget {
  final WorkoutProvider provider;
  final ExerciseDefinition? existing;   // null = 新規追加
  final String defaultBodyPart;

  const _ExerciseEditSheet({
    required this.provider,
    required this.existing,
    required this.defaultBodyPart,
  });

  @override
  State<_ExerciseEditSheet> createState() => _ExerciseEditSheetState();
}

class _ExerciseEditSheetState extends State<_ExerciseEditSheet> {
  final _uuid    = const Uuid();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl  = TextEditingController();
  final _ratioCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String        _bodyPart    = '胸';
  ExerciseType  _type        = ExerciseType.weight;
  bool          _isSaving    = false;

  static const _bodyParts = ['胸', '背中', '肩', '腕', '腹', '脚', '有酸素', 'その他'];

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _nameCtrl.text  = ex.name;
      _bodyPart       = ex.bodyPart;
      _type           = ex.exerciseType;
      _ratioCtrl.text = ex.bodyWeightRatio != null
          ? (ex.bodyWeightRatio! * 100).toStringAsFixed(0)
          : '';
      _notesCtrl.text = ex.notes ?? '';
    } else {
      _bodyPart = widget.defaultBodyPart;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ratioCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.existing != null;

  // ── 保存 ───────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameCtrl.text.trim();

    // 重複チェック
    if (widget.provider.exerciseNameExists(
        name, excludeId: widget.existing?.id)) {
      _showMsg('同じ名前の種目が既に存在します', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    double? ratio;
    if (_type == ExerciseType.bodyWeight) {
      final v = double.tryParse(_ratioCtrl.text.trim());
      ratio = (v != null && v > 0) ? v / 100 : null;
    }

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name:            name,
        bodyPart:        _bodyPart,
        exerciseType:    _type,
        isDefault:       false,
        bodyWeightRatio: ratio,
        clearBodyWeightRatio: _type != ExerciseType.bodyWeight,
        notes:           _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        clearNotes:      _notesCtrl.text.trim().isEmpty,
      );
      await widget.provider.updateExerciseDefinition(updated);
      _showMsg('種目を更新しました');
    } else {
      final newDef = ExerciseDefinition(
        id:              _uuid.v4(),
        name:            name,
        bodyPart:        _bodyPart,
        isDefault:       false,
        isTimeBased:     _type == ExerciseType.cardio,
        isBodyWeight:    _type == ExerciseType.bodyWeight,
        bodyWeightRatio: ratio,
        exerciseType:    _type,
        notes:           _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await widget.provider.addExerciseDefinition(newDef);
      _showMsg('種目を追加しました');
    }

    if (mounted) Navigator.pop(context);
  }

  // ── 削除 ───────────────────────────────────────────────────────────────
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('種目を削除しますか？',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          '「${widget.existing!.name}」を削除します。\nこの操作は元に戻せません。',
          style: const TextStyle(color: Color(0xFFAFAFAF), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除',
                style: TextStyle(
                    color: Color(0xFFFF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await widget.provider.deleteExerciseDefinition(widget.existing!.id);
    if (mounted) Navigator.pop(context);
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? const Color(0xFFFF4444)
            : const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A5C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── タイトル ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? '種目を編集' : '種目を追加',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // 削除ボタン（編集モード時のみ）
                  if (_isEdit)
                    GestureDetector(
                      onTap: _delete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFF4444).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline,
                                color: Color(0xFFFF4444), size: 14),
                            SizedBox(width: 4),
                            Text('削除',
                                style: TextStyle(
                                    color: Color(0xFFFF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 種目名 ───────────────────────────────────────────────
              _label('種目名', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('例: スミスマシンベンチプレス'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '種目名を入力してください';
                  if (v.trim().length > 30) return '30文字以内で入力してください';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── 部位 ────────────────────────────────────────────────
              _label('部位', required: true),
              const SizedBox(height: 10),
              _bodyPartSelector(),
              const SizedBox(height: 20),

              // ── 種目タイプ ───────────────────────────────────────────
              _label('種目タイプ', required: true),
              const SizedBox(height: 10),
              _typeSelector(),
              const SizedBox(height: 20),

              // ── 自重反映率（自重トレーニング時のみ）──────────────────
              if (_type == ExerciseType.bodyWeight) ...[
                _label('体重反映率 (%)'),
                const SizedBox(height: 6),
                _ratioField(),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '例: 腕立て伏せ=65、懸垂=100、ディップス=90\n'
                    '総重量 = 体重 × 反映率 × 回数 × セット数',
                    style: TextStyle(
                      color: const Color(0xFF888888).withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── メモ ────────────────────────────────────────────────
              _label('メモ（任意）'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                decoration: _inputDeco('フォームのポイント、器具の設定など'),
              ),
              const SizedBox(height: 28),

              // ── 保存ボタン ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isEdit ? '変更を保存' : '種目を追加',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 部位セレクター ──────────────────────────────────────────────────────
  Widget _bodyPartSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _bodyParts.map((part) {
        final isSelected = _bodyPart == part;
        final color = _partColor(part);
        return GestureDetector(
          onTap: () => setState(() => _bodyPart = part),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? color
                    : const Color(0xFF3A3A5C),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              part,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF888888),
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 種目タイプセレクター ────────────────────────────────────────────────
  Widget _typeSelector() {
    const types = [
      (ExerciseType.weight,     '重量', Icons.fitness_center),
      (ExerciseType.bodyWeight, '自重', Icons.accessibility_new),
      (ExerciseType.cardio,     '有酸素', Icons.directions_run),
    ];
    return Row(
      children: types.map((t) {
        final isSelected = _type == t.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _type = t.$1;
              // タイプ変更時は反映率をリセット
              if (_type != ExerciseType.bodyWeight) _ratioCtrl.clear();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                    : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF3A3A5C),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(t.$3,
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF555555),
                      size: 20),
                  const SizedBox(height: 4),
                  Text(
                    t.$2,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 反映率フィールド ────────────────────────────────────────────────────
  Widget _ratioField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _ratioCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('65'),
            validator: (_) {
              if (_type != ExerciseType.bodyWeight) return null;
              final v = double.tryParse(_ratioCtrl.text.trim());
              if (v != null && (v < 1 || v > 200)) return '1〜200を入力';
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        const Text('%',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── ヘルパー ────────────────────────────────────────────────────────────
  Widget _label(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF3A3A5C), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF4444)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Color _partColor(String part) {
    switch (part) {
      case '胸':   return const Color(0xFFFF6B35);
      case '肩':   return const Color(0xFF4ECDC4);
      case '腕':   return const Color(0xFF45B7D1);
      case '背中': return const Color(0xFFFFD93D);
      case 'お腹':
      case '腹':   return const Color(0xFF6BCB77);
      case '足':
      case '脚':   return const Color(0xFFFF6B6B);
      case '有酸素': return const Color(0xFFDA77FF);
      default:    return const Color(0xFFAFAFAF);
    }
  }
}
