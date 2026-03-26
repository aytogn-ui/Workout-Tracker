import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/body_info.dart';
import '../models/personal_record.dart';
import '../models/routine.dart';
import '../models/exercise_definition.dart';

class StorageService {
  static const _keyWorkouts = 'workouts';
  static const _keyBodyInfo = 'bodyInfo';
  static const _keyPersonalRecords = 'personalRecords';
  static const _keyRoutines = 'routines';
  static const _keyExercises = 'exercises';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 5));
  }

  SharedPreferences get _p {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // ── Workouts ──────────────────────────────────────────────
  Future<List<Workout>> loadWorkouts() async {
    final list = _p.getStringList(_keyWorkouts) ?? [];
    return list.map((s) => Workout.fromJsonString(s)).toList();
  }

  Future<void> saveWorkouts(List<Workout> workouts) async {
    await _p.setStringList(
      _keyWorkouts,
      workouts.map((w) => w.toJsonString()).toList(),
    );
  }

  // ── BodyInfo ──────────────────────────────────────────────
  Future<List<BodyInfo>> loadBodyInfo() async {
    final list = _p.getStringList(_keyBodyInfo) ?? [];
    return list.map((s) => BodyInfo.fromJsonString(s)).toList();
  }

  Future<void> saveBodyInfo(List<BodyInfo> items) async {
    await _p.setStringList(
      _keyBodyInfo,
      items.map((b) => b.toJsonString()).toList(),
    );
  }

  // ── PersonalRecords ───────────────────────────────────────
  Future<List<PersonalRecord>> loadPersonalRecords() async {
    final list = _p.getStringList(_keyPersonalRecords) ?? [];
    return list.map((s) => PersonalRecord.fromJsonString(s)).toList();
  }

  Future<void> savePersonalRecords(List<PersonalRecord> records) async {
    await _p.setStringList(
      _keyPersonalRecords,
      records.map((r) => r.toJsonString()).toList(),
    );
  }

  // ── Routines ──────────────────────────────────────────────
  Future<List<Routine>> loadRoutines() async {
    final list = _p.getStringList(_keyRoutines) ?? [];
    return list.map((s) => Routine.fromJsonString(s)).toList();
  }

  Future<void> saveRoutines(List<Routine> routines) async {
    await _p.setStringList(
      _keyRoutines,
      routines.map((r) => r.toJsonString()).toList(),
    );
  }

  // ── ExerciseDefinitions ───────────────────────────────────
  Future<List<ExerciseDefinition>> loadExercises() async {
    final list = _p.getStringList(_keyExercises) ?? [];
    return list.map((s) => ExerciseDefinition.fromJsonString(s)).toList();
  }

  Future<void> saveExercises(List<ExerciseDefinition> exercises) async {
    await _p.setStringList(
      _keyExercises,
      exercises.map((e) => e.toJsonString()).toList(),
    );
  }
}
