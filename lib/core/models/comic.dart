import 'package:uuid/uuid.dart';

/// 만화 데이터 모델
class Comic {
  final String id;
  final String diaryId;
  final String userId;
  final String title;
  final String? description;
  final String imageUrl;
  final String style;
  final ComicStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? estimatedTimeSeconds;
  final String? errorMessage;

  Comic({
    String? id,
    required this.diaryId,
    required this.userId,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.style,
    required this.status,
    DateTime? createdAt,
    this.completedAt,
    this.estimatedTimeSeconds,
    this.errorMessage,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// JSON에서 Comic 객체 생성
  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'] as String,
      diaryId: json['diary_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      style: json['style'] as String,
      status: ComicStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      estimatedTimeSeconds: json['estimated_time_seconds'] as int?,
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Comic 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diary_id': diaryId,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'style': style,
      'status': status.toString(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'estimated_time_seconds': estimatedTimeSeconds,
      'error_message': errorMessage,
    };
  }

  /// Comic 객체 복사 (일부 필드 수정)
  Comic copyWith({
    String? id,
    String? diaryId,
    String? userId,
    String? title,
    String? description,
    String? imageUrl,
    String? style,
    ComicStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? estimatedTimeSeconds,
    String? errorMessage,
  }) {
    return Comic(
      id: id ?? this.id,
      diaryId: diaryId ?? this.diaryId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      style: style ?? this.style,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedTimeSeconds: estimatedTimeSeconds ?? this.estimatedTimeSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'Comic(id: $id, diaryId: $diaryId, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 만화 생성 상태
enum ComicStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  const ComicStatus(this.value);
  final String value;

  static ComicStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ComicStatus.pending;
      case 'processing':
        return ComicStatus.processing;
      case 'completed':
        return ComicStatus.completed;
      case 'failed':
        return ComicStatus.failed;
      default:
        return ComicStatus.pending;
    }
  }

  @override
  String toString() => value;
}

/// 만화 생성 요청
class ComicGenerationRequest {
  final String diaryId;
  final String content;
  final String? title;
  final String? mood;
  final String? weather;
  final String? location;
  final String style;

  ComicGenerationRequest({
    required this.diaryId,
    required this.content,
    this.title,
    this.mood,
    this.weather,
    this.location,
    this.style = 'cute',
  });

  Map<String, dynamic> toJson() {
    return {
      'diary_id': diaryId,
      'content': content,
      'title': title,
      'mood': mood,
      'weather': weather,
      'location': location,
      'style': style,
    };
  }
}

/// 만화 생성 응답
class ComicGenerationResponse {
  final String comicId;
  final ComicStatus status;
  final int? estimatedTimeSeconds;
  final String? message;

  ComicGenerationResponse({
    required this.comicId,
    required this.status,
    this.estimatedTimeSeconds,
    this.message,
  });

  factory ComicGenerationResponse.fromJson(Map<String, dynamic> json) {
    return ComicGenerationResponse(
      comicId: json['comic_id'] as String,
      status: ComicStatus.fromString(json['status'] as String),
      estimatedTimeSeconds: json['estimated_time_seconds'] as int?,
      message: json['message'] as String?,
    );
  }
}
