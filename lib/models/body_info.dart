import 'dart:convert';

/// データソース種別
enum BodyInfoSource {
  manual,    // 手動入力
  healthKit, // Apple HealthKit XMLインポート
}

extension BodyInfoSourceExt on BodyInfoSource {
  String get key {
    switch (this) {
      case BodyInfoSource.manual:    return 'manual';
      case BodyInfoSource.healthKit: return 'healthKit';
    }
  }

  String get label {
    switch (this) {
      case BodyInfoSource.manual:    return '手動入力';
      case BodyInfoSource.healthKit: return 'HealthKit';
    }
  }

  static BodyInfoSource fromKey(String? key) =>
      key == 'healthKit' ? BodyInfoSource.healthKit : BodyInfoSource.manual;
}

class BodyInfo {
  final String id;
  final DateTime date;
  // 基本身体データ
  final String? gender;      // 'male' | 'female' | 'other'
  final int?    age;
  final double? height;      // cm
  final double? weight;      // kg
  // 追加データ（オプション）
  final double? bodyFat;     // %
  final double? muscleMass;  // kg
  final String? notes;
  // データソース
  final BodyInfoSource source;

  BodyInfo({
    required this.id,
    required this.date,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.bodyFat,
    this.muscleMass,
    this.notes,
    this.source = BodyInfoSource.manual,
  });

  BodyInfo copyWith({
    String? id,
    DateTime? date,
    String? gender,
    int? age,
    double? height,
    double? weight,
    double? bodyFat,
    double? muscleMass,
    String? notes,
    BodyInfoSource? source,
  }) {
    return BodyInfo(
      id:          id          ?? this.id,
      date:        date        ?? this.date,
      gender:      gender      ?? this.gender,
      age:         age         ?? this.age,
      height:      height      ?? this.height,
      weight:      weight      ?? this.weight,
      bodyFat:     bodyFat     ?? this.bodyFat,
      muscleMass:  muscleMass  ?? this.muscleMass,
      notes:       notes       ?? this.notes,
      source:      source      ?? this.source,
    );
  }

  /// BMI 計算（身長・体重が揃っている場合）
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final h = height! / 100;
    return weight! / (h * h);
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'date':       date.toIso8601String(),
    'gender':     gender,
    'age':        age,
    'height':     height,
    'weight':     weight,
    'bodyFat':    bodyFat,
    'muscleMass': muscleMass,
    'notes':      notes,
    'source':     source.key,
  };

  factory BodyInfo.fromJson(Map<String, dynamic> json) => BodyInfo(
    id:          json['id']          as String?   ?? '',
    date:        DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    gender:      json['gender']      as String?,
    age:         json['age']         as int?,
    height:      (json['height']     as num?)?.toDouble(),
    weight:      (json['weight']     as num?)?.toDouble(),
    bodyFat:     (json['bodyFat']    as num?)?.toDouble(),
    muscleMass:  (json['muscleMass'] as num?)?.toDouble(),
    notes:       json['notes']       as String?,
    source:      BodyInfoSourceExt.fromKey(json['source'] as String?),
  );

  String toJsonString() => jsonEncode(toJson());
  factory BodyInfo.fromJsonString(String s) =>
      BodyInfo.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
