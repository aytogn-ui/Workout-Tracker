import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/workout_provider.dart';
import '../models/body_info.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'トレーニングツール',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildToolCard(
                context,
                icon: Icons.timer,
                title: 'インターバルタイマー',
                subtitle: '休憩時間を計測',
                color: const Color(0xFFFF6B35),
                onTap: () => _showTimerSheet(context),
              ),
              const SizedBox(height: 12),
              _buildToolCard(
                context,
                icon: Icons.calculate,
                title: 'ウォームアップ計算',
                subtitle: '目標重量からウォームアップを計算',
                color: const Color(0xFF4ECDC4),
                onTap: () => _showWarmupSheet(context),
              ),
              const SizedBox(height: 12),
              _buildToolCard(
                context,
                icon: Icons.bar_chart,
                title: 'RM計算',
                subtitle: '1RMと各レップ数の推定重量を計算',
                color: const Color(0xFFFFD93D),
                onTap: () => _showRMSheet(context),
              ),
              const SizedBox(height: 12),
              _buildToolCard(
                context,
                icon: Icons.monitor_weight,
                title: '体重・体組成記録',
                subtitle: '体重・体脂肪率・筋量を記録',
                color: const Color(0xFF6BCB77),
                onTap: () => _showBodyInfoSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFAFAFAF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF3A3A5C)),
          ],
        ),
      ),
    );
  }

  // ── タイマー ──────────────────────────────────────────────
  void _showTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TimerSheet(),
    );
  }

  // ── ウォームアップ計算 ────────────────────────────────────
  void _showWarmupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WarmupSheet(),
    );
  }

  // ── RM計算 ────────────────────────────────────────────────
  void _showRMSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RMSheet(),
    );
  }

  // ── 体重記録 ──────────────────────────────────────────────
  void _showBodyInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BodyInfoSheet(),
    );
  }
}

// ── タイマー BottomSheet ────────────────────────────────────
class _TimerSheet extends StatefulWidget {
  const _TimerSheet();

  @override
  State<_TimerSheet> createState() => _TimerSheetState();
}

class _TimerSheetState extends State<_TimerSheet> {
  static const _presets = [60, 90, 120, 180];
  int _selected = 90;
  int _remaining = 90;
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_remaining <= 0) _reset();
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_remaining > 0) {
          _remaining--;
        } else {
          _running = false;
          t.cancel();
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = _selected;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _selected > 0 ? _remaining / _selected : 0.0;
    final min = _remaining ~/ 60;
    final sec = _remaining % 60;

    return _buildSheet(
      title: 'インターバルタイマー',
      color: const Color(0xFFFF6B35),
      child: Column(
        children: [
          // プリセット選択
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _presets.map((p) {
              final isSelected = _selected == p;
              return GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  setState(() {
                    _selected = p;
                    _remaining = p;
                    _running = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)])
                        : null,
                    color: isSelected ? null : const Color(0xFF2C2C3E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${p}s',
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFAFAFAF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 円形タイマー
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFF2C2C3E),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _remaining <= 10
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFFFF6B35),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      _running ? '計測中' : (_remaining == 0 ? '完了！' : '停止中'),
                      style: const TextStyle(
                          color: Color(0xFFAFAFAF), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleButton(
                icon: Icons.refresh,
                color: const Color(0xFF2C2C3E),
                onTap: _reset,
              ),
              const SizedBox(width: 20),
              _circleButton(
                icon: _running ? Icons.pause : Icons.play_arrow,
                color: const Color(0xFFFF6B35),
                onTap: _running ? _stop : _start,
                size: 64,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

// ── ウォームアップ BottomSheet ──────────────────────────────
class _WarmupSheet extends StatefulWidget {
  const _WarmupSheet();

  @override
  State<_WarmupSheet> createState() => _WarmupSheetState();
}

class _WarmupSheetState extends State<_WarmupSheet> {
  final _ctrl = TextEditingController();
  double? _target;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sets = _target == null
        ? null
        : [
            (_target! * 0.4, 10, '40%'),
            (_target! * 0.6, 6, '60%'),
            (_target! * 0.8, 3, '80%'),
          ];

    return _buildSheet(
      title: 'ウォームアップ計算',
      color: const Color(0xFF4ECDC4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('目標重量 (kg)',
              style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: _inputDec('100'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => setState(() {
                  _target = double.tryParse(_ctrl.text.trim());
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('計算'),
              ),
            ],
          ),
          if (sets != null) ...[
            const SizedBox(height: 24),
            const Text(
              'ウォームアップセット',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...sets.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.$3,
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${s.$1.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '× ${s.$2}回',
                        style: const TextStyle(
                            color: Color(0xFFAFAFAF), fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── RM計算 BottomSheet ────────────────────────────────────
class _RMSheet extends StatefulWidget {
  const _RMSheet();

  @override
  State<_RMSheet> createState() => _RMSheetState();
}

class _RMSheetState extends State<_RMSheet> {
  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  double? _oneRM;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    final w = double.tryParse(_weightCtrl.text.trim());
    final r = int.tryParse(_repsCtrl.text.trim());
    if (w != null && r != null && w > 0 && r > 0) {
      setState(() => _oneRM = w * (1 + r / 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    const repList = [1, 2, 3, 5, 8, 10, 12];

    return _buildSheet(
      title: 'RM計算 (Epley公式)',
      color: const Color(0xFFFFD93D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('重量 (kg)',
                        style: TextStyle(
                            color: Color(0xFFAFAFAF), fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDec('100'),
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
                        style: TextStyle(
                            color: Color(0xFFAFAFAF), fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _repsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDec('5'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD93D),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('計算する',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          if (_oneRM != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD93D), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('推定1RM',
                      style: TextStyle(color: Colors.black87, fontSize: 12)),
                  Text(
                    '${_oneRM!.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('各レップ数の推定重量',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...repList.map((rep) {
              final w = _oneRM! / (1 + rep / 30);
              final pct = (w / _oneRM! * 100).round();
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3A3A5C)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$rep RM',
                        style: const TextStyle(
                          color: Color(0xFFFFD93D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${w.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                          color: Color(0xFFAFAFAF), fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── 体重記録 BottomSheet ──────────────────────────────────
class _BodyInfoSheet extends StatefulWidget {
  const _BodyInfoSheet();

  @override
  State<_BodyInfoSheet> createState() => _BodyInfoSheetState();
}

class _BodyInfoSheetState extends State<_BodyInfoSheet> {
  final _uuid = const Uuid();
  final _weightCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _muscleCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _fatCtrl.dispose();
    _muscleCtrl.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('体重を入力してください'),
            backgroundColor: Color(0xFFFF6B6B)),
      );
      return;
    }
    final info = BodyInfo(
      id: _uuid.v4(),
      date: DateTime.now(),
      weight: weight,
      bodyFat: double.tryParse(_fatCtrl.text.trim()),
      muscleMass: double.tryParse(_muscleCtrl.text.trim()),
    );
    context.read<WorkoutProvider>().addBodyInfo(info);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('体組成を記録しました'),
        backgroundColor: Color(0xFF6BCB77),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final latest = provider.latestBodyInfo;

    return _buildSheet(
      title: '体重・体組成記録',
      color: const Color(0xFF6BCB77),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latest != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6BCB77).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6BCB77).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem('体重', '${latest.weight?.toStringAsFixed(1) ?? '-'}kg'),
                  if (latest.bodyFat != null)
                    _infoItem('体脂肪率', '${latest.bodyFat!.toStringAsFixed(1)}%'),
                  if (latest.muscleMass != null)
                    _infoItem('筋量', '${latest.muscleMass!.toStringAsFixed(1)}kg'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildField('体重 (kg) *', _weightCtrl, '70.0'),
          const SizedBox(height: 12),
          _buildField('体脂肪率 (%)', _fatCtrl, '15.0'),
          const SizedBox(height: 12),
          _buildField('筋量 (kg)', _muscleCtrl, '55.0'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _save(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BCB77),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('記録する',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                color: Color(0xFFAFAFAF), fontSize: 11)),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFAFAFAF), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDec(hint),
        ),
      ],
    );
  }
}

// ── 共通シートビルダー ────────────────────────────────────
Widget _buildSheet({
  required String title,
  required Color color,
  required Widget child,
}) {
  return DraggableScrollableSheet(
    initialChildSize: 0.75,
    maxChildSize: 0.95,
    minChildSize: 0.4,
    builder: (context, scrollCtrl) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A5C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.build, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    ),
  );
}

InputDecoration _inputDec(String hint) {
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
