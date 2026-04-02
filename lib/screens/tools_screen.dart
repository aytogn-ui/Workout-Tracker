import 'dart:async';
import 'package:flutter/material.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text('ツール',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  ],
                ),
              ),
              const SizedBox(height: 100),
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

}

// ── タイマー BottomSheet ────────────────────────────────────
class _TimerSheet extends StatefulWidget {
  const _TimerSheet();

  @override
  State<_TimerSheet> createState() => _TimerSheetState();
}

class _TimerSheetState extends State<_TimerSheet> {
  // -1 = カスタム選択中
  static const _presets = [60, 90, 120, 180];
  int _selected  = 90;
  int _remaining = 90;
  bool _running  = false;
  bool _customMode = false; // カスタム入力モード

  // カスタム入力用コントローラ
  final _minCtrl = TextEditingController();
  final _secCtrl = TextEditingController();

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _minCtrl.dispose();
    _secCtrl.dispose();
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
      _running   = false;
    });
  }

  void _applyCustom() {
    final m = int.tryParse(_minCtrl.text.trim()) ?? 0;
    final s = int.tryParse(_secCtrl.text.trim()) ?? 0;
    final total = m * 60 + s;
    if (total <= 0) return;
    _timer?.cancel();
    setState(() {
      _selected   = total;
      _remaining  = total;
      _running    = false;
      _customMode = false;
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
          // ── プリセット + カスタムボタン ───────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // プリセット
              ..._presets.map((p) {
                final isSelected = !_customMode && _selected == p;
                return GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    setState(() {
                      _selected   = p;
                      _remaining  = p;
                      _running    = false;
                      _customMode = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)])
                          : null,
                      color: isSelected ? null : const Color(0xFF2C2C3E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p < 60 ? '${p}s' : '${p ~/ 60}分',
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFAFAFAF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }),
              // カスタムボタン
              GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  setState(() {
                    _running    = false;
                    _customMode = !_customMode;
                    // 初期値を現在の選択時間で埋める
                    if (_customMode) {
                      _minCtrl.text = (_selected ~/ 60).toString();
                      _secCtrl.text = (_selected % 60).toString().padLeft(2, '0');
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _customMode
                        ? const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)])
                        : null,
                    color: _customMode ? null : const Color(0xFF2C2C3E),
                    borderRadius: BorderRadius.circular(20),
                    border: _customMode
                        ? null
                        : Border.all(color: const Color(0xFF3A3A5C)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune,
                        color: _customMode ? Colors.white : const Color(0xFFAFAFAF),
                        size: 14),
                      const SizedBox(width: 4),
                      Text('カスタム',
                        style: TextStyle(
                          color: _customMode ? Colors.white : const Color(0xFFAFAFAF),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── カスタム入力フォーム ──────────────────────────
          if (_customMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('時間を入力',
                    style: TextStyle(color: Color(0xFF9F67FA), fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('分', style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 11)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _minCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: const TextStyle(color: Color(0xFF3A3A5C), fontSize: 20),
                                filled: true,
                                fillColor: const Color(0xFF2C2C3E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 18, left: 8, right: 8),
                        child: Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('秒', style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 11)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _secCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '00',
                                hintStyle: const TextStyle(color: Color(0xFF3A3A5C), fontSize: 20),
                                filled: true,
                                fillColor: const Color(0xFF2C2C3E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
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
                      onPressed: _applyCustom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('セット', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── 円形タイマー ─────────────────────────────────
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
                      style: const TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
                    ),
                    // カスタム時間表示
                    if (_selected != 60 && _selected != 90 &&
                        _selected != 120 && _selected != 180)
                      Text(
                        '(${_selected ~/ 60}分${_selected % 60 > 0 ? "${_selected % 60}秒" : ""})',
                        style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── ボタン ────────────────────────────────────────
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
  final _repsCtrl   = TextEditingController();
  double? _oneRM;
  int?    _inputReps; // 入力した回数（ハイライト計算用）

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
      setState(() {
        _oneRM     = w * (1 + r / 30);
        _inputReps = r;
      });
    }
  }

  // RM表のデータ定義
  // (表示ラベル, 下限回数, 上限回数)  ← 両端を含む
  static const _rows = [
    (label: '1回',       lo: 1,  hi: 1),
    (label: '2回',       lo: 2,  hi: 2),
    (label: '3回',       lo: 3,  hi: 3),
    (label: '4回',       lo: 4,  hi: 4),
    (label: '5回',       lo: 5,  hi: 5),
    (label: '6回',       lo: 6,  hi: 6),
    (label: '7回',       lo: 7,  hi: 7),
    (label: '8回',       lo: 8,  hi: 8),
    (label: '9回',       lo: 9,  hi: 9),
    (label: '10〜12回',  lo: 10, hi: 12),
    (label: '12〜15回',  lo: 12, hi: 15),
    (label: '15〜18回',  lo: 15, hi: 18),
    (label: '18〜20回',  lo: 18, hi: 20),
    (label: '20〜25回',  lo: 20, hi: 25),
  ];

  // カテゴリ判定
  String _category(int lo) {
    if (lo <= 3)  return 'strength';   // 神経系・筋力強化
    if (lo <= 12) return 'hypertrophy'; // 筋肥大・筋力強化
    return 'endurance';                 // 筋持久力強化
  }

  // カテゴリ色
  Color _catColor(String cat) {
    switch (cat) {
      case 'strength':    return const Color(0xFFFF4D4D);
      case 'hypertrophy': return const Color(0xFF4D9AFF);
      default:            return const Color(0xFF4DCC77);
    }
  }

  // カテゴリラベル
  String _catLabel(String cat) {
    switch (cat) {
      case 'strength':    return '神経系・筋力強化';
      case 'hypertrophy': return '筋肥大・筋力強化';
      default:            return '筋持久力強化';
    }
  }

  double _rmWeight(int reps) => _oneRM! / (1 + reps / 30);

  // ハイライト判定：入力した回数に最も近い行
  bool _isHighlight(int lo, int hi) {
    if (_inputReps == null) return false;
    final r = _inputReps!;
    return r >= lo && r <= hi;
  }

  @override
  Widget build(BuildContext context) {
    return _buildSheet(
      title: 'RM計算 (Epley公式)',
      color: const Color(0xFFFFD93D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 入力エリア ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('重量 (kg)',
                      style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12)),
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
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),

          if (_oneRM != null) ...[
            const SizedBox(height: 20),

            // ── 推定1RM バナー ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD93D), Color(0xFFFFA500)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('推定1RM  ',
                    style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '${_oneRM!.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 凡例（目的説明）────────────────────────────
            _buildLegend(),
            const SizedBox(height: 16),

            // ── RM表ヘッダー ───────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 78, child: Text('回数',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('重量',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 11, fontWeight: FontWeight.w700))),
                  SizedBox(width: 110, child: Text('目的',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 11, fontWeight: FontWeight.w700))),
                ],
              ),
            ),

            // ── RM表本体 ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A2A2A)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Column(
                children: _rows.asMap().entries.map((entry) {
                  final i   = entry.key;
                  final row = entry.value;
                  final cat = _category(row.lo);
                  final color = _catColor(cat);
                  final hl  = _isHighlight(row.lo, row.hi);

                  // 重量文字列
                  final wLo = _rmWeight(row.hi); // 回数大 → 重量小
                  final wHi = _rmWeight(row.lo); // 回数小 → 重量大
                  final weightLabel = row.lo == row.hi
                      ? '${wHi.toStringAsFixed(1)} kg'
                      : '${wLo.toStringAsFixed(1)}〜${wHi.toStringAsFixed(1)} kg';

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: hl
                          ? color.withValues(alpha: 0.18)
                          : (i.isEven ? const Color(0xFF0F0F0F) : const Color(0xFF111111)),
                      border: Border(
                        bottom: BorderSide(
                          color: i < _rows.length - 1
                              ? const Color(0xFF1E1E1E)
                              : Colors.transparent,
                        ),
                        left: hl
                            ? BorderSide(color: color, width: 3)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 回数
                        SizedBox(
                          width: 78,
                          child: Row(
                            children: [
                              if (hl)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.arrow_right, color: Colors.white, size: 14),
                                ),
                              Flexible(
                                child: Text(row.label,
                                  style: TextStyle(
                                    color: hl ? Colors.white : const Color(0xFFDDDDDD),
                                    fontSize: 12,
                                    fontWeight: hl ? FontWeight.w800 : FontWeight.normal,
                                  )),
                              ),
                            ],
                          ),
                        ),
                        // 重量
                        Expanded(
                          child: Text(weightLabel,
                            style: TextStyle(
                              color: hl ? color : const Color(0xFFDDDDDD),
                              fontSize: 12,
                              fontWeight: hl ? FontWeight.w800 : FontWeight.w600,
                            )),
                        ),
                        // 目的
                        SizedBox(
                          width: 110,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: hl ? 0.25 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_catLabel(cat),
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              )),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (_inputReps != null)
              Center(
                child: Text(
                  '→ 入力した${_inputReps}回はハイライト表示されています',
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    const items = [
      (cat: 'strength',    range: '1〜3回',   desc: '神経系・最大筋力向上に適しています'),
      (cat: 'hypertrophy', range: '4〜12回',  desc: '筋肥大・筋力向上に適しています'),
      (cat: 'endurance',   range: '12回以上', desc: '筋持久力向上に適しています'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: items.map((item) {
          final color = _catColor(item.cat);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(item.range,
                    style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.desc,
                    style: const TextStyle(color: Color(0xFFAFAFAF), fontSize: 11)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
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
