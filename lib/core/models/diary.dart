/// 일기 데이터 모델
class Diary {
  final String id;
  final String userId;
  final String content;
  final String? title;
  final String? mood;
  final String? weather;
  final String? location;
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;

  Diary({
    required this.id,
    required this.userId,
    required this.content,
    this.title,
    this.mood,
    this.weather,
    this.location,
    this.isDraft = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 Diary 객체 생성
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      title: json['title'] as String?,
      mood: json['mood'] as String?,
      weather: json['weather'] as String?,
      location: json['location'] as String?,
      isDraft: json['is_draft'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Diary 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'title': title,
      'mood': mood,
      'weather': weather,
      'location': location,
      'is_draft': isDraft,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Diary 객체 복사 (일부 필드 수정)
  Diary copyWith({
    String? id,
    String? userId,
    String? content,
    String? title,
    String? mood,
    String? weather,
    String? location,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      title: title ?? this.title,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      location: location ?? this.location,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Diary(id: $id, userId: $userId, content: $content, title: $title, isDraft: $isDraft)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Diary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
