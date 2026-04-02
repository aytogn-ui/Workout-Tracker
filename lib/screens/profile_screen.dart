import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/workout_provider.dart';
import '../models/body_info.dart';
import 'analysis_screen.dart';
import 'tools_screen.dart';

/// プロフィールタブ – ユーザー情報・体重記録・ツールへのアクセス
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ヘッダー ────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'プロフィール',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── ユーザーカード ──────────────────────────────
              _UserCard(provider: provider),
              const SizedBox(height: 20),

              // ── 体組成パネル ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BodyCompositionPanel(provider: provider),
              ),
              const SizedBox(height: 20),

              // ── 体組成記録ボタン ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showBodyInfoSheet(context),
                    icon: const Icon(Icons.monitor_weight, size: 18),
                    label: const Text('体重・体組成を記録'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BCB77),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── メニュー ────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(
                  'ツール & 分析',
                  style: TextStyle(
                    color: Color(0xFFAFAFAF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _menuItem(
                context,
                icon: Icons.bar_chart,
                label: 'トレーニング分析',
                subtitle: '部位別ボリュームを確認',
                color: const Color(0xFFFF6B35),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalysisScreen()),
                ),
              ),
              _menuItem(
                context,
                icon: Icons.timer,
                label: 'トレーニングツール',
                subtitle: 'タイマー・RM計算・ウォームアップ',
                color: const Color(0xFF4ECDC4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ToolsScreen()),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                    )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF3A3A3A)),
          ],
        ),
      ),
    );
  }

  void _showBodyInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BodyInfoSheet(),
    );
  }
}

// ── ユーザーカード ───────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final WorkoutProvider provider;
  const _UserCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // アバター
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'トレーニーユーザー',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '今月 ${provider.thisMonthWorkoutCount} 回トレーニング',
                  style: const TextStyle(
                    color: Color(0xFFAFAFAF),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _badge('${provider.workouts.length}', 'セッション', const Color(0xFFFF6B35)),
                    const SizedBox(width: 8),
                    _badge(
                      provider.personalRecords.isNotEmpty
                          ? '${provider.personalRecords.length}'
                          : '0',
                      'PR',
                      const Color(0xFF4ECDC4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            )),
          const SizedBox(width: 4),
          Text(label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 11,
            )),
        ],
      ),
    );
  }
}

// ── 体組成パネル ────────────────────────────────────────────
class _BodyCompositionPanel extends StatelessWidget {
  final WorkoutProvider provider;
  const _BodyCompositionPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    final latest = provider.latestBodyInfo;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6BCB77).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_weight, color: Color(0xFF6BCB77), size: 18),
              const SizedBox(width: 8),
              const Text(
                '最新の体組成',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (latest == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'まだ記録がありません',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 13),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _compositionItem('体重',
                  latest.weight != null ? '${latest.weight!.toStringAsFixed(1)}kg' : '-',
                  const Color(0xFF6BCB77)),
                if (latest.bodyFat != null)
                  _compositionItem('体脂肪率',
                    '${latest.bodyFat!.toStringAsFixed(1)}%',
                    const Color(0xFF45B7D1)),
                if (latest.muscleMass != null)
                  _compositionItem('筋量',
                    '${latest.muscleMass!.toStringAsFixed(1)}kg',
                    const Color(0xFFFFD93D)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _compositionItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          )),
        const SizedBox(height: 2),
        Text(label,
          style: const TextStyle(
            color: Color(0xFFAFAFAF),
            fontSize: 11,
          )),
      ],
    );
  }
}

// ── 体組成記録シート ─────────────────────────────────────────
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
        const SnackBar(
          content: Text('体重を入力してください'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
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
                  width: 36, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('体重・体組成記録',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )),
              const SizedBox(height: 20),
              _field('体重 (kg) *', _weightCtrl, '70.0'),
              const SizedBox(height: 12),
              _field('体脂肪率 (%)', _fatCtrl, '15.0'),
              const SizedBox(height: 12),
              _field('筋量 (kg)', _muscleCtrl, '55.0'),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(color: Color(0xFFAFAFAF), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3A3A3A)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6BCB77), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
