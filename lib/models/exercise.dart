import 'dart:convert';
import 'exercise_set.dart';

class Exercise {
  final String id;
  final String exerciseId;
  final String name;
  final String bodyPart;
  final List<ExerciseSet> sets;
  final bool isTimeBased;
  final bool isBodyWeight;
  final double? bodyWeightRatio;

  Exercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.bodyPart,
    this.sets = const [],
    this.isTimeBased = false,
    this.isBodyWeight = false,
    this.bodyWeightRatio,
  });

  Exercise copyWith({
    String? id,
    String? exerciseId,
    String? name,
    String? bodyPart,
    List<ExerciseSet>? sets,
    bool? isTimeBased,
    bool? isBodyWeight,
    double? bodyWeightRatio,
  }) {
    return Exercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      sets: sets ?? this.sets,
      isTimeBased: isTimeBased ?? this.isTimeBased,
      isBodyWeight: isBodyWeight ?? this.isBodyWeight,
      bodyWeightRatio: bodyWeightRatio ?? this.bodyWeightRatio,
    );
  }

  double get totalVolume {
    if (isTimeBased) return 0.0;
    return sets.fold(0.0, (sum, s) => sum + s.weight * s.reps);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'name': name,
      'bodyPart': bodyPart,
      'sets': sets.map((s) => s.toJson()).toList(),
      'isTimeBased': isTimeBased,
      'isBodyWeight': isBodyWeight,
      'bodyWeightRatio': bodyWeightRatio,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? '',
      sets: (json['sets'] as List<dynamic>?)
              ?.map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      isTimeBased: json['isTimeBased'] as bool? ?? false,
      isBodyWeight: json['isBodyWeight'] as bool? ?? false,
      bodyWeightRatio: (json['bodyWeightRatio'] as num?)?.toDouble(),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory Exercise.fromJsonString(String s) =>
      Exercise.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
