import 'dart:convert';

class ExerciseSet {
  final String id;
  final int setNumber;
  final double weight;
  final int reps;
  final String type; // normal, warmup, drop, failure
  final int? timeSeconds;
  final bool isCompleted;

  ExerciseSet({
    required this.id,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.type = 'normal',
    this.timeSeconds,
    this.isCompleted = false,
  });

  ExerciseSet copyWith({
    String? id,
    int? setNumber,
    double? weight,
    int? reps,
    String? type,
    int? timeSeconds,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      type: type ?? this.type,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'type': type,
      'timeSeconds': timeSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'] as String? ?? '',
      setNumber: json['setNumber'] as int? ?? 1,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] as int? ?? 0,
      type: json['type'] as String? ?? 'normal',
      timeSeconds: json['timeSeconds'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory ExerciseSet.fromJsonString(String s) =>
      ExerciseSet.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
