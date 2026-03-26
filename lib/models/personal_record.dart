import 'dart:convert';

class PersonalRecord {
  final String id;
  final String exerciseId;
  final DateTime date;
  final double maxWeight;
  final int reps;
  final double estimatedOneRM;

  PersonalRecord({
    required this.id,
    required this.exerciseId,
    required this.date,
    required this.maxWeight,
    required this.reps,
    required this.estimatedOneRM,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'maxWeight': maxWeight,
      'reps': reps,
      'estimatedOneRM': estimatedOneRM,
    };
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      maxWeight: (json['maxWeight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] as int? ?? 0,
      estimatedOneRM: (json['estimatedOneRM'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory PersonalRecord.fromJsonString(String s) =>
      PersonalRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
