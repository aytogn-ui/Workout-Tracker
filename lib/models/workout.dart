import 'dart:convert';
import 'exercise.dart';

class Workout {
  final String id;
  final DateTime date;
  final List<Exercise> exercises;
  final String? notes;

  Workout({
    required this.id,
    required this.date,
    this.exercises = const [],
    this.notes,
  });

  double get totalWeight {
    return exercises.fold(0.0, (sum, e) => sum + e.totalVolume);
  }

  Workout copyWith({
    String? id,
    DateTime? date,
    List<Exercise>? exercises,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory Workout.fromJsonString(String s) =>
      Workout.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
