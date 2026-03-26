import 'dart:convert';

class BodyInfo {
  final String id;
  final DateTime date;
  final double? weight;
  final double? bodyFat;
  final double? muscleMass;
  final String? notes;

  BodyInfo({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFat,
    this.muscleMass,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
      'notes': notes,
    };
  }

  factory BodyInfo.fromJson(Map<String, dynamic> json) {
    return BodyInfo(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory BodyInfo.fromJsonString(String s) =>
      BodyInfo.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
