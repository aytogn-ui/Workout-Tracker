import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/body_data_screen.dart';
import 'screens/add_workout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja', null);
  final provider = WorkoutProvider();
  await provider.initialize();
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const RootScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B35),
        secondary: Color(0xFF00CFFF),
        surface: Color(0xFF111111),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

// ── ボトムナビゲーション ルート ───────────────────────────────
// タブ構成:
//   0: ホーム     – カレンダー + ワークアウト記録
//   1: 進捗      – 人体マップ（放射状ライン）+ 分析 + 履歴
//  [中央FAB]     – ワークアウト追加
//   2: ツール     – タイマー / RM計算 / ウォームアップ
//   3: 身体データ – 性別・年齢・体重・身長
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  // 実際のタブ画面（FABは別扱い）
  static const _screens = [
    HomeScreen(),     // 0: ホーム（ワークアウト）
    ProgressScreen(), // 1: 進捗（統合分析）
    ToolsScreen(),    // 2: ツール
    BodyDataScreen(), // 3: 身体データ
  ];

  // タブ定義（左2つ + 右2つ / 中央はFABプレースホルダー）
  static const _tabs = [
    _TabItem(
      icon: Icons.fitness_center_outlined,
      activeIcon: Icons.fitness_center,
      label: 'ホーム',
    ),
    _TabItem(
      icon: Icons.show_chart_outlined,
      activeIcon: Icons.show_chart,
      label: '進捗',
    ),
    _TabItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      label: 'ツール',
    ),
    _TabItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '身体データ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
      ),
      backgroundColor: const Color(0xFFFF6B35),
      elevation: 6,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: const Color(0xFF0D0D0D),
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E1E1E), width: 0.5)),
        ),
        height: 56,
        child: Row(
          children: [
            // 左2タブ
            ..._buildTabItems([0, 1]),
            // 中央FABスペース
            const Expanded(child: SizedBox()),
            // 右2タブ
            ..._buildTabItems([2, 3]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabItems(List<int> indices) {
    return indices.map((i) {
      final tab    = _tabs[i];
      final active = _index == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _index = i),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  active ? tab.activeIcon : tab.icon,
                  color: active ? const Color(0xFFFF6B35) : const Color(0xFF444444),
                  size: 22,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 9,
                  color: active ? const Color(0xFFFF6B35) : const Color(0xFF444444),
                  fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
