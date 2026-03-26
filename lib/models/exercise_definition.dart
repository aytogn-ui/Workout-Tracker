import 'dart:convert';

class ExerciseDefinition {
  final String id;
  final String name;
  final String bodyPart;
  final bool isDefault;
  final bool isTimeBased;
  final bool isBodyWeight;
  final double? bodyWeightRatio;

  ExerciseDefinition({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.isDefault = true,
    this.isTimeBased = false,
    this.isBodyWeight = false,
    this.bodyWeightRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'isDefault': isDefault,
      'isTimeBased': isTimeBased,
      'isBodyWeight': isBodyWeight,
      'bodyWeightRatio': bodyWeightRatio,
    };
  }

  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return ExerciseDefinition(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? true,
      isTimeBased: json['isTimeBased'] as bool? ?? false,
      isBodyWeight: json['isBodyWeight'] as bool? ?? false,
      bodyWeightRatio: (json['bodyWeightRatio'] as num?)?.toDouble(),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory ExerciseDefinition.fromJsonString(String s) =>
      ExerciseDefinition.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// デフォルト種目データ
List<ExerciseDefinition> getDefaultExercises() {
  return [
    // 胸
    ExerciseDefinition(id: 'chest-1', name: 'ベンチプレス', bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-2', name: 'ダンベルプレス', bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-3', name: 'インクラインベンチ', bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-4', name: 'ダンベルフライ', bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-5', name: 'ケーブルクロスオーバー', bodyPart: '胸'),
    ExerciseDefinition(id: 'chest-6', name: 'プッシュアップ', bodyPart: '胸', isBodyWeight: true, bodyWeightRatio: 0.65),
    ExerciseDefinition(id: 'chest-7', name: 'ディップス', bodyPart: '胸', isBodyWeight: true, bodyWeightRatio: 0.8),
    ExerciseDefinition(id: 'chest-8', name: 'デクラインベンチ', bodyPart: '胸'),

    // 肩
    ExerciseDefinition(id: 'shoulder-1', name: 'ショルダープレス', bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-2', name: 'ダンベルショルダープレス', bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-3', name: 'ラテラルレイズ', bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-4', name: 'フロントレイズ', bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-5', name: 'リアデルトフライ', bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-6', name: 'アップライトロー', bodyPart: '肩'),
    ExerciseDefinition(id: 'shoulder-7', name: 'アーノルドプレス', bodyPart: '肩'),

    // 腕
    ExerciseDefinition(id: 'arm-1', name: 'バーベルカール', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-2', name: 'ダンベルカール', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-3', name: 'ハンマーカール', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-4', name: 'プリーチャーカール', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-5', name: 'トライセプスプレスダウン', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-6', name: 'スカルクラッシャー', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-7', name: 'キックバック', bodyPart: '腕'),
    ExerciseDefinition(id: 'arm-8', name: 'コンセントレーションカール', bodyPart: '腕'),

    // 背中
    ExerciseDefinition(id: 'back-1', name: 'デッドリフト', bodyPart: '背中'),
    ExerciseDefinition(id: 'back-2', name: 'ラットプルダウン', bodyPart: '背中'),
    ExerciseDefinition(id: 'back-3', name: 'ベントオーバーロー', bodyPart: '背中'),
    ExerciseDefinition(id: 'back-4', name: 'シーテッドロー', bodyPart: '背中'),
    ExerciseDefinition(id: 'back-5', name: 'プルアップ', bodyPart: '背中', isBodyWeight: true, bodyWeightRatio: 1.0),
    ExerciseDefinition(id: 'back-6', name: 'チンニング', bodyPart: '背中', isBodyWeight: true, bodyWeightRatio: 1.0),
    ExerciseDefinition(id: 'back-7', name: 'シュラッグ', bodyPart: '背中'),
    ExerciseDefinition(id: 'back-8', name: 'ハイパーエクステンション', bodyPart: '背中'),

    // お腹
    ExerciseDefinition(id: 'abs-1', name: 'クランチ', bodyPart: 'お腹', isBodyWeight: true, bodyWeightRatio: 0.3),
    ExerciseDefinition(id: 'abs-2', name: 'レッグレイズ', bodyPart: 'お腹', isBodyWeight: true, bodyWeightRatio: 0.3),
    ExerciseDefinition(id: 'abs-3', name: 'プランク', bodyPart: 'お腹', isTimeBased: true),
    ExerciseDefinition(id: 'abs-4', name: 'ロシアンツイスト', bodyPart: 'お腹', isBodyWeight: true, bodyWeightRatio: 0.3),
    ExerciseDefinition(id: 'abs-5', name: 'シットアップ', bodyPart: 'お腹', isBodyWeight: true, bodyWeightRatio: 0.35),
    ExerciseDefinition(id: 'abs-6', name: 'ハンギングレッグレイズ', bodyPart: 'お腹', isBodyWeight: true, bodyWeightRatio: 0.3),

    // 足
    ExerciseDefinition(id: 'leg-1', name: 'スクワット', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-2', name: 'レッグプレス', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-3', name: 'ランジ', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-4', name: 'レッグエクステンション', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-5', name: 'レッグカール', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-6', name: 'カーフレイズ', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-7', name: 'ヒップスラスト', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-8', name: 'ブルガリアンスクワット', bodyPart: '足'),
    ExerciseDefinition(id: 'leg-9', name: 'ボディウェイトスクワット', bodyPart: '足', isBodyWeight: true, bodyWeightRatio: 0.7),

    // 有酸素
    ExerciseDefinition(id: 'cardio-1', name: 'ランニング', bodyPart: '有酸素', isTimeBased: true),
    ExerciseDefinition(id: 'cardio-2', name: 'ウォーキング', bodyPart: '有酸素', isTimeBased: true),
    ExerciseDefinition(id: 'cardio-3', name: 'エアロバイク', bodyPart: '有酸素', isTimeBased: true),
    ExerciseDefinition(id: 'cardio-4', name: 'ローイング', bodyPart: '有酸素', isTimeBased: true),
    ExerciseDefinition(id: 'cardio-5', name: 'ステップマシン', bodyPart: '有酸素', isTimeBased: true),
  ];
}
