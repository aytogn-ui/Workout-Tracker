import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final selected = provider.selectedDate;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A5C), width: 1),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildDayLabels(),
          _buildGrid(provider, selected),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            onPressed: () => setState(() {
              _displayMonth =
                  DateTime(_displayMonth.year, _displayMonth.month - 1);
            }),
          ),
          Text(
            DateFormat('yyyy年 M月', 'ja').format(_displayMonth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: () => setState(() {
              _displayMonth =
                  DateTime(_displayMonth.year, _displayMonth.month + 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      color: d == '日'
                          ? const Color(0xFFFF6B6B)
                          : d == '土'
                              ? const Color(0xFF4ECDC4)
                              : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGrid(WorkoutProvider provider, DateTime selected) {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    // 月曜始まりに調整 (weekday: 1=月 7=日)
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;

    final cells = <Widget>[];

    // 空白セル
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    // 日付セル
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayMonth.year, _displayMonth.month, day);
      final isSelected = _isSameDay(date, selected);
      final isToday = _isSameDay(date, DateTime.now());
      final hasWorkout = provider.hasWorkout(date);

      cells.add(
        GestureDetector(
          onTap: () => provider.selectDate(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                    )
                  : isToday
                      ? null
                      : null,
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFFFF6B35), width: 1.5)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFFFF6B35)
                            : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
                if (hasWorkout && !isSelected)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cells,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
