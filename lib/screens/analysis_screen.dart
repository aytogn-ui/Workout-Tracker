import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/body_visualization.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  static const _bodyParts = ['胸', '肩', '腕', '背中', 'お腹', '足', '有酸素'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final volumeMap = provider.recentBodyPartVolume;
    final maxVol = volumeMap.values.fold(0.0, (a, b) => a > b ? a : b);

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
          'トレーニング分析',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 直近7日間の統計
              _buildWeeklyStats(provider),
              const SizedBox(height: 20),

              // 人体可視化
              const Text(
                '部位別トレーニング (直近7日間)',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C1C2E), Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3A3A5C)),
                ),
                child: BodyVisualization(bodyPartVolume: volumeMap),
              ),
              const SizedBox(height: 20),

              // 部位別ボリュームリスト
              const Text(
                '部位別ボリューム詳細',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (volumeMap.isEmpty)
                _buildEmptyState()
              else
                ..._bodyParts.map((part) {
                  final vol = volumeMap[part] ?? 0;
                  final ratio = maxVol > 0 ? vol / maxVol : 0.0;
                  return _buildBodyPartBar(part, vol, ratio);
                }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStats(WorkoutProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: '合計ボリューム',
            value: '${provider.recentTotalVolumeTons.toStringAsFixed(2)}t',
            subtitle: '直近7日間',
            icon: Icons.trending_up,
            color: const Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'トレーニング部位',
            value: '${provider.recentBodyPartCount}',
            subtitle: '部位',
            icon: Icons.accessibility_new,
            color: const Color(0xFF4ECDC4),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(
                    color: Color(0xFFAFAFAF), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Color(0xFFAFAFAF), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPartBar(String part, double vol, double ratio) {
    final color = _bodyPartColor(part);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3A3A5C)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_bodyPartIcon(part), color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  part,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                vol > 0 ? '${vol.toStringAsFixed(0)}kg' : '-',
                style: TextStyle(
                  color: vol > 0 ? color : const Color(0xFF3A3A5C),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFF2C2C3E),
              valueColor: AlwaysStoppedAnimation<Color>(
                  vol > 0 ? color : const Color(0xFF2C2C3E)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart, color: Color(0xFF3A3A5C), size: 48),
          SizedBox(height: 12),
          Text(
            '直近7日間のデータなし',
            style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'トレーニングを記録すると分析が表示されます',
            style: TextStyle(color: Color(0xFF3A3A5C), fontSize: 12),
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
}
