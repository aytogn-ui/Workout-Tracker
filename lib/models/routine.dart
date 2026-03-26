import 'dart:convert';

class Routine {
  final String id;
  final String name;
  final String description;
  final List<String> exerciseIds;
  final String color;

  Routine({
    required this.id,
    required this.name,
    required this.description,
    this.exerciseIds = const [],
    this.color = '#FF6B35',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exerciseIds': exerciseIds,
      'color': color,
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      exerciseIds: (json['exerciseIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      color: json['color'] as String? ?? '#FF6B35',
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory Routine.fromJsonString(String s) =>
      Routine.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// デフォルトルーティン
List<Routine> getDefaultRoutines() {
  return [
    Routine(
      id: 'routine-push',
      name: 'Push Day',
      description: '胸・肩・三頭筋',
      exerciseIds: ['chest-1', 'chest-2', 'shoulder-1', 'shoulder-3', 'arm-5'],
      color: '#FF6B35',
    ),
    Routine(
      id: 'routine-pull',
      name: 'Pull Day',
      description: '背中・二頭筋',
      exerciseIds: ['back-2', 'back-1', 'back-3', 'arm-3'],
      color: '#4ECDC4',
    ),
    Routine(
      id: 'routine-leg',
      name: 'Leg Day',
      description: '脚・腹',
      exerciseIds: ['leg-1', 'leg-2', 'leg-4', 'leg-6'],
      color: '#45B7D1',
    ),
  ];
}
