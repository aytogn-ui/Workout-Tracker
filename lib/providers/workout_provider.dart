import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

import '../models/exercise_definition.dart';
import '../models/body_info.dart';
import '../models/personal_record.dart';
import '../models/routine.dart';
import '../services/storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  List<Workout> _workouts = [];
  List<ExerciseDefinition> _exercises = [];
  List<BodyInfo> _bodyInfoList = [];
  List<PersonalRecord> _personalRecords = [];
  List<Routine> _routines = [];

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;

  // ── Getters ───────────────────────────────────────────────
  List<Workout> get workouts => _workouts;
  List<ExerciseDefinition> get exercises => _exercises;
  List<BodyInfo> get bodyInfoList => _bodyInfoList;
  List<PersonalRecord> get personalRecords => _personalRecords;
  List<Routine> get routines => _routines;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 選択日のワークアウト
  Workout? get selectedDateWorkout {
    try {
      return _workouts.firstWhere(
        (w) => _isSameDay(w.date, _selectedDate),
      );
    } catch (_) {
      return null;
    }
  }

  // トレーニングのある日付セット
  Set<DateTime> get workoutDates {
    return _workouts.map((w) => DateTime(w.date.year, w.date.month, w.date.day)).toSet();
  }

  // 今月の統計
  int get thisMonthWorkoutCount {
    final now = DateTime.now();
    return _workouts
        .where((w) => w.date.year == now.year && w.date.month == now.month)
        .length;
  }

  double get thisMonthTotalVolume {
    final now = DateTime.now();
    return _workouts
        .where((w) => w.date.year == now.year && w.date.month == now.month)
        .fold(0.0, (sum, w) => sum + w.totalWeight);
  }

  // 直近7日間の部位別ボリューム
  Map<String, double> get recentBodyPartVolume {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final map = <String, double>{};
    for (final w in _workouts.where((w) => w.date.isAfter(cutoff))) {
      for (final e in w.exercises) {
        map[e.bodyPart] = (map[e.bodyPart] ?? 0) + e.totalVolume;
      }
    }
    return map;
  }

  // 直近7日間の合計ボリューム (トン単位)
  double get recentTotalVolumeTons {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final total = _workouts
        .where((w) => w.date.isAfter(cutoff))
        .fold(0.0, (sum, w) => sum + w.totalWeight);
    return total / 1000;
  }

  int get recentBodyPartCount {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final parts = <String>{};
    for (final w in _workouts.where((w) => w.date.isAfter(cutoff))) {
      for (final e in w.exercises) {
        parts.add(e.bodyPart);
      }
    }
    return parts.length;
  }

  // ── 初期化 ────────────────────────────────────────────────
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    try {
      await _storage.init();

      // 種目定義を読み込み
      final savedExercises = await _storage.loadExercises();
      if (savedExercises.isEmpty) {
        _exercises = getDefaultExercises();
        await _storage.saveExercises(_exercises);
      } else {
        _exercises = savedExercises;
      }

      // ルーティンを読み込み
      final savedRoutines = await _storage.loadRoutines();
      if (savedRoutines.isEmpty) {
        _routines = getDefaultRoutines();
        await _storage.saveRoutines(_routines);
      } else {
        _routines = savedRoutines;
      }

      _workouts = await _storage.loadWorkouts();
      _bodyInfoList = await _storage.loadBodyInfo();
      _personalRecords = await _storage.loadPersonalRecords();
    } catch (e) {
      _error = 'データの読み込みに失敗しました: $e';
      if (kDebugMode) debugPrint('WorkoutProvider init error: $e');
      // フォールバック: デフォルトデータを使用
      if (_exercises.isEmpty) _exercises = getDefaultExercises();
      if (_routines.isEmpty) _routines = getDefaultRoutines();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 日付選択 ──────────────────────────────────────────────
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // ── ワークアウト操作 ──────────────────────────────────────
  Future<void> addExerciseToDate(DateTime date, Exercise exercise) async {
    try {
      final idx = _workouts.indexWhere((w) => _isSameDay(w.date, date));
      if (idx >= 0) {
        // 既存ワークアウトにマージ
        final existing = _workouts[idx];
        _workouts[idx] = existing.copyWith(
          exercises: [...existing.exercises, exercise],
        );
      } else {
        // 新規ワークアウト作成
        _workouts.add(Workout(
          id: _uuid.v4(),
          date: date,
          exercises: [exercise],
        ));
      }
      await _storage.saveWorkouts(_workouts);
      _updatePersonalRecords(exercise);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('addExerciseToDate error: $e');
    }
  }

  Future<void> deleteExercise(String workoutId, String exerciseId) async {
    try {
      final idx = _workouts.indexWhere((w) => w.id == workoutId);
      if (idx < 0) return;
      final workout = _workouts[idx];
      final newExercises =
          workout.exercises.where((e) => e.id != exerciseId).toList();
      if (newExercises.isEmpty) {
        _workouts.removeAt(idx);
      } else {
        _workouts[idx] = workout.copyWith(exercises: newExercises);
      }
      await _storage.saveWorkouts(_workouts);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('deleteExercise error: $e');
    }
  }

  // ── BodyInfo ──────────────────────────────────────────────
  Future<void> addBodyInfo(BodyInfo info) async {
    try {
      _bodyInfoList.insert(0, info);
      await _storage.saveBodyInfo(_bodyInfoList);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('addBodyInfo error: $e');
    }
  }

  BodyInfo? get latestBodyInfo =>
      _bodyInfoList.isNotEmpty ? _bodyInfoList.first : null;

  // ── Personal Records ──────────────────────────────────────
  void _updatePersonalRecords(Exercise exercise) {
    for (final set in exercise.sets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      final oneRM = set.weight * (1 + set.reps / 30);
      final existing = _personalRecords
          .where((pr) => pr.exerciseId == exercise.exerciseId)
          .toList();
      if (existing.isEmpty || existing.first.estimatedOneRM < oneRM) {
        _personalRecords.removeWhere(
            (pr) => pr.exerciseId == exercise.exerciseId);
        _personalRecords.insert(
          0,
          PersonalRecord(
            id: _uuid.v4(),
            exerciseId: exercise.exerciseId,
            date: DateTime.now(),
            maxWeight: set.weight,
            reps: set.reps,
            estimatedOneRM: oneRM,
          ),
        );
      }
    }
    _storage.savePersonalRecords(_personalRecords);
  }

  PersonalRecord? getPersonalRecord(String exerciseId) {
    try {
      return _personalRecords.firstWhere((pr) => pr.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }

  // ── 種目定義 ──────────────────────────────────────────────
  List<ExerciseDefinition> getExercisesByBodyPart(String bodyPart) {
    return _exercises.where((e) => e.bodyPart == bodyPart).toList();
  }

  // ── Helper ────────────────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool hasWorkout(DateTime date) =>
      _workouts.any((w) => _isSameDay(w.date, date));

  String generateId() => _uuid.v4();
}
