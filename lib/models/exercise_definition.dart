import 'dart:convert';

/// 種目タイプ
enum ExerciseType {
  weight,     // 重量トレーニング
  bodyWeight, // 自重トレーニング
  cardio,     // 有酸素
}

extension ExerciseTypeExt on ExerciseType {
  String get label {
    switch (this) {
      case ExerciseType.weight:     return '重量トレーニング';
      case ExerciseType.bodyWeight: return '自重トレーニング';
      case ExerciseType.cardio:     return '有酸素';
    }
  }

  String get key {
    switch (this) {
      case ExerciseType.weight:     return 'weight';
      case ExerciseType.bodyWeight: return 'bodyWeight';
      case ExerciseType.cardio:     return 'cardio';
    }
  }

  static ExerciseType fromKey(String? key) {
    switch (key) {
      case 'bodyWeight': return ExerciseType.bodyWeight;
      case 'cardio':     return ExerciseType.cardio;
      default:           return ExerciseType.weight;
    }
  }
}

class ExerciseDefinition {
  final String id;
  final String name;
  final String bodyPart;
  final bool isDefault;
  final bool isTimeBased;
  final bool isBodyWeight;
  final double? bodyWeightRatio;
  // 追加フィールド
  final ExerciseType exerciseType;
  final String? notes;

  ExerciseDefinition({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.isDefault = true,
    this.isTimeBased = false,
    this.isBodyWeight = false,
    this.bodyWeightRatio,
    ExerciseType? exerciseType,
    this.notes,
  }) : exerciseType = exerciseType ?? _inferType(isBodyWeight, isTimeBased);

  /// isBodyWeight / isTimeBased から exerciseType を自動推定
  static ExerciseType _inferType(bool isBodyWeight, bool isTimeBased) {
    if (isBodyWeight) return ExerciseType.bodyWeight;
    if (isTimeBased)  return ExerciseType.cardio;
    return ExerciseType.weight;
  }

  /// exerciseType から isBodyWeight / isTimeBased を同期させた copyWith
  ExerciseDefinition copyWith({
    String? id,
    String? name,
    String? bodyPart,
    bool? isDefault,
    bool? isTimeBased,
    bool? isBodyWeight,
    double? bodyWeightRatio,
    ExerciseType? exerciseType,
    String? notes,
    bool clearNotes = false,
    bool clearBodyWeightRatio = false,
  }) {
    final newType = exerciseType ?? this.exerciseType;
    return ExerciseDefinition(
      id:              id         ?? this.id,
      name:            name       ?? this.name,
      bodyPart:        bodyPart   ?? this.bodyPart,
      isDefault:       isDefault  ?? this.isDefault,
      isTimeBased:     newType == ExerciseType.cardio,
      isBodyWeight:    newType == ExerciseType.bodyWeight,
      bodyWeightRatio: clearBodyWeightRatio
          ? null
          : (bodyWeightRatio ?? this.bodyWeightRatio),
      exerciseType:    newType,
      notes:           clearNotes ? null : (notes ?? this.notes),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'isDefault': isDefault,
      'isTimeBased': isTimeBased,
      'isBodyWeight': isBodyWeight,
      'bodyWeightRatio': bodyWeightRatio,
      'exerciseType': exerciseType.key,
      'notes': notes,
    };
  }

  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    final isBodyWeight = json['isBodyWeight'] as bool? ?? false;
    final isTimeBased  = json['isTimeBased']  as bool? ?? false;
    final typeKey      = json['exerciseType'] as String?;
    final exerciseType = typeKey != null
        ? ExerciseTypeExt.fromKey(typeKey)
        : ExerciseDefinition._inferType(isBodyWeight, isTimeBased);

    return ExerciseDefinition(
      id:              json['id']              as String? ?? '',
      name:            json['name']            as String? ?? '',
      bodyPart:        json['bodyPart']        as String? ?? '',
      isDefault:       json['isDefault']       as bool?   ?? true,
      isTimeBased:     isTimeBased,
      isBodyWeight:    isBodyWeight,
      bodyWeightRatio: (json['bodyWeightRatio'] as num?)?.toDouble(),
      exerciseType:    exerciseType,
      notes:           json['notes']           as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory ExerciseDefinition.fromJsonString(String s) =>
      ExerciseDefinition.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// ── デフォルト種目データ ──────────────────────────────────────────
List<ExerciseDefinition> getDefaultExercises() {
  return [
    // 胸
    ExerciseDefinition(id: 'chest-1', name: 'ベンチプレス',           bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-2', name: 'ダンベルプレス',         bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-3', name: 'インクラインベンチ',      bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-4', name: 'ダンベルフライ',         bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-5', name: 'ケーブルクロスオーバー',  bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-6', name: 'プッシュアップ',         bodyPart: '胸',
        isBodyWeight: true, bodyWeightRatio: 0.65,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'chest-7', name: 'ディップス',            bodyPart: '胸',
        isBodyWeight: true, bodyWeightRatio: 0.8,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'chest-8', name: 'デクラインベンチ',       bodyPart: '胸'),

    // 肩
    ExerciseDefinition(id: 'shoulder-1', name: 'ショルダープレス',          bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-2', name: 'ダンベルショルダープレス',   bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-3', name: 'ラテラルレイズ',            bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-4', name: 'フロントレイズ',            bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-5', name: 'リアデルトフライ',          bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-6', name: 'アップライトロー',          bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-7', name: 'アーノルドプレス',          bodyPart: '肩'),

    // 腕
    ExerciseDefinition(id: 'arm-1', name: 'バーベルカール',           bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-2', name: 'ダンベルカール',           bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-3', name: 'ハンマーカール',           bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-4', name: 'プリーチャーカール',       bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-5', name: 'トライセプスプレスダウン', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-6', name: 'スカルクラッシャー',       bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-7', name: 'キックバック',            bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-8', name: 'コンセントレーションカール', bodyPart: '腕'),

    // 背中
    ExerciseDefinition(id: 'back-1', name: 'デッドリフト',           bodyPart: '背中'),
    ExerciseDefinition(id: 'back-2', name: 'ラットプルダウン',       bodyPart: '背中'),
    ExerciseDefinition(id: 'back-3', name: 'ベントオーバーロー',     bodyPart: '背中'),
    ExerciseDefinition(id: 'back-4', name: 'シーテッドロー',         bodyPart: '背中'),
    ExerciseDefinition(id: 'back-5', name: 'プルアップ',            bodyPart: '背中',
        isBodyWeight: true, bodyWeightRatio: 1.0,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'back-6', name: 'チンニング',            bodyPart: '背中',
        isBodyWeight: true, bodyWeightRatio: 1.0,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'back-7', name: 'シュラッグ',            bodyPart: '背中'),
    ExerciseDefinition(id: 'back-8', name: 'ハイパーエクステンション', bodyPart: '背中'),

    // お腹
    ExerciseDefinition(id: 'abs-1', name: 'クランチ',          bodyPart: 'お腹',
        isBodyWeight: true, bodyWeightRatio: 0.3,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'abs-2', name: 'レッグレイズ',      bodyPart: 'お腹',
        isBodyWeight: true, bodyWeightRatio: 0.3,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'abs-3', name: 'プランク',          bodyPart: 'お腹',
        isTimeBased: true, exerciseType: ExerciseType.cardio),
    ExerciseDefinition(id: 'abs-4', name: 'ロシアンツイスト',  bodyPart: 'お腹',
        isBodyWeight: true, bodyWeightRatio: 0.3,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'abs-5', name: 'シットアップ',      bodyPart: 'お腹',
        isBodyWeight: true, bodyWeightRatio: 0.35,
        exerciseType: ExerciseType.bodyWeight),
    ExerciseDefinition(id: 'abs-6', name: 'ハンギングレッグレイズ', bodyPart: 'お腹',
        isBodyWeight: true, bodyWeightRatio: 0.3,
        exerciseType: ExerciseType.bodyWeight),

    // 足
    ExerciseDefinition(id: 'leg-1', name: 'スクワット',           bodyPart: '足'),
    ExerciseDefinition(id: 'leg-2', name: 'レッグプレス',         bodyPart: '足'),
    ExerciseDefinition(id: 'leg-3', name: 'ランジ',               bodyPart: '足'),
    ExerciseDefinition(id: 'leg-4', name: 'レッグエクステンション', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-5', name: 'レッグカール',         bodyPart: '足'),
    ExerciseDefinition(id: 'leg-6', name: 'カーフレイズ',         bodyPart: '足'),
    ExerciseDefinition(id: 'leg-7', name: 'ヒップスラスト',       bodyPart: '足'),
    ExerciseDefinition(id: 'leg-8', name: 'ブルガリアンスクワット', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-9', name: 'ボディウェイトスクワット', bodyPart: '足',
        isBodyWeight: true, bodyWeightRatio: 0.7,
        exerciseType: ExerciseType.bodyWeight),

    // 有酸素
    ExerciseDefinition(id: 'cardio-1', name: 'ランニング',     bodyPart: '有酸素',
        isTimeBased: true, exerciseType: ExerciseType.cardio),
    ExerciseDefinition(id: 'cardio-2', name: 'ウォーキング',   bodyPart: '有酸素',
        isTimeBased: true, exerciseType: ExerciseType.cardio),
    ExerciseDefinition(id: 'cardio-3', name: 'エアロバイク',   bodyPart: '有酸素',
        isTimeBased: true, exerciseType: ExerciseType.cardio),
    ExerciseDefinition(id: 'cardio-4', name: 'ローイング',     bodyPart: '有酸素',
        isTimeBased: true, exerciseType: ExerciseType.cardio),
    ExerciseDefinition(id: 'cardio-5', name: 'ステップマシン', bodyPart: '有酸素',
        isTimeBased: true, exerciseType: ExerciseType.cardio),
  ];
}
