import 'diary.dart';
import 'comic.dart';

/// 일기와 만화를 함께 표현하는 모델
/// 메인 피드에서 일기와 해당 만화를 함께 표시하기 위해 사용
class DiaryComic {
  final Diary diary;
  final Comic? comic; // 만화가 없을 수도 있음

  DiaryComic({
    required this.diary,
    this.comic,
  });

  /// JSON에서 DiaryComic 객체 생성
  /// Supabase에서 diaries와 comics를 join하여 가져올 때 사용
  factory DiaryComic.fromJson(Map<String, dynamic> json) {
    return DiaryComic(
      diary: Diary.fromJson(json['diary'] as Map<String, dynamic>),
      comic: json['comic'] != null
          ? Comic.fromJson(json['comic'] as Map<String, dynamic>)
          : null,
    );
  }

  /// DiaryComic 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'diary': diary.toJson(),
      'comic': comic?.toJson(),
    };
  }

  /// 만화가 있는지 확인
  bool get hasComic => comic != null && comic!.status == ComicStatus.completed;

  /// 만화 썸네일 URL (만화가 있으면 반환, 없으면 null)
  String? get comicThumbnailUrl => hasComic ? comic!.imageUrl : null;

  @override
  String toString() {
    return 'DiaryComic(diary: $diary, comic: ${comic?.id ?? "none"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryComic && other.diary.id == diary.id;
  }

  @override
  int get hashCode => diary.id.hashCode;
}
